<#
    .SYNOPSIS
        Führt Befehle auf Hyver-V-basierten VMs mit "Invoke-Command" aus und protokolliert System-Angaben in einer Microsoft SQL-Datenbank.
        Optimal: VM mit Prepare-VM.ps1 erstellen, Datenbank mit Artifacts.sql vorbereiten.

    .DESCRIPTION
        Befehle in Szenarien zusammenfassen.

    .EXAMPLE
        Run-Scenario.ps1

    .LINK
        https://github.com/tistephan/HyperV-Run-Scenario
#>

function Invoke-Scenario($w10_version_name, $scenario) {

    Write-Host ""
    Write-Host "=> Szenario $($scenario) mit VM ""$($w10_version_name)"" gestartet: $((Get-Date -Format "dd.MM.yyyy HH:mm:ss"))"
    Write-Host ""

    $SecureString = ConvertTo-SecureString $password -AsPlainText -Force # Für Powershell-Szenarien benötigt
    $credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist "Administrator", $SecureString    
    $artifacts_directory="$($artifacts_root_directory )\$($w10_version_name)"
    New-Item -ItemType Directory $artifacts_directory -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null

    Start-VM -VMName "$($w10_version_name)" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

    Write-Host -NoNewline "   VM starten und warten bis WinRM-Dienst zur Verfügung steht..."
    for (;;) {
        $checkWinRM = Test-NetConnection  "$($w10_version_name)" -Port 5985 -WarningAction SilentlyContinue
        If ($checkWinRM.tcpTestSucceeded -eq $true) {
            Write-Host "fertig."
            break;
        }
    }

    # USB-Stick-Emulation auf Hyper-V-Host starten
    # Sichertellen: USB-Datenträger auf dem Host vorsorglich schreibschützen
    #               HKLM\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies\WriteProtect=1
    Start-Process -FilePath "$($tools_path_host)\Tools\vhusbdwindk64.exe"

    # Szenario-ID aus der Datenbank auslesen
    $sc_devicetype=$scenario.Substring(0,1)
    $sc_action=$scenario.Substring(1,1)
    $sc_version=$($w10_version_name).Substring(4,4)

    $query="SELECT
        MainScenario.ID
    FROM
        MainScenario
    INNER JOIN
        Scenario_Template ON MainScenario.Scenario_Template_ID = Scenario_Template.ID
    INNER JOIN
        W10_Version ON W10_Version_ID = W10_Version.ID
    INNER JOIN
        Device_Type ON Scenario_Template.Device_Type_ID = Device_Type.ID
    INNER JOIN
        Action ON Scenario_Template.Action_ID = Action.ID
    WHERE
        W10_Version.Version='$($sc_version)' AND Device_Type.ID=$($sc_devicetype) AND Scenario_Template.Action_ID=$($sc_action)"
    $scenario_id=Invoke-SqlCmd -ServerInstance "$($db_server_address)" -Database "Artifacts" -Query $query -Username "sa" -Password "$($password)" | Select-Object -ExpandProperty ID

    Write-Host -NoNewline "   Szenario ausführen..."

    $starttime_sql = (Get-Date -Format "yyyy.MM.dd HH:mm:ss") -replace "\.", "/" # Zeitstempel formatieren
    $starttime = $starttime_sql -replace "\/", "" -replace "\s+", "_" -replace ":", ""
    $starttime_gci = $starttime.Substring(4,2) + "/" + $starttime.Substring(6,2) + "/" + $starttime.Substring(0,4) + " " + $starttime.Substring(9,2) + ":" + $starttime.Substring(11,2) + ":" + $starttime.Substring(11,2)

    # Befehle des Szenarios auf der VM per Invoke-Command ausführen
    $endtime_sql = Invoke-Command -ComputerName "$($w10_version_name)" -ScriptBlock {

        # USB-Stick-Emulation auf VM starten - kein USB-Schreibschutz auf VM!
        Start-Process -FilePath "$($using:tools_path_vm)\vhui64.exe" -ArgumentList "--config=$($tools_path_vm)\config.ini"

        # Process Monitor: Zur Sammlung der Laufzeit-Daten starten als SYSTEM-Benutzer
        Start-Process "C:\_INSTALL\Tools\psexec64.exe" -ArgumentList "-s -i ""c:\_INSTALL\Tools\procmon64.exe"" /accepteula /quiet /backingfile D:\$($env:ComputerName)_$($using:scenario)_$($using:starttime).pml /LoadConfig $($using:tools_path_vm)\ProcmonConfiguration.pmc" -NoNewWindow

        # Einzelne Schritte der Szenarien auf der VM remote ausführen
        switch ($using:scenario) {
            {   ($_ -eq "11")
            }
            {
                if ($($env:ComputerName) -eq "W10_1507") {
                    $encryption_method="Aes256"
                } else {
                    $encryption_method="XtsAes256"
                }

                # Hier deklarieren, da keine SecureString-Variablen an Invoke-Command übergeben werden dürfen
                $secure_string_password = ConvertTo-SecureString $($using:password) -AsPlainText -Force

                $bitlocker_drive="C"
                Enable-BitLocker -MountPoint "$($bitlocker_drive):" -EncryptionMethod $($encryption_method) -RecoveryPasswordProtector -SkipHardwareTest -UsedSpaceOnly -WarningAction SilentlyContinue | Out-Null
                
                # Warten bis Verschlüsselung vollständig abgeschlossen ist
                for (;;) {
                    If ((Get-BitLockerVolume -MountPoint "$($bitlocker_drive):").VolumeStatus -eq "FullyEncrypted") {
                        break;
                    }
                }
            }
        }

        # Process Monitor beenden
        Start-Process "C:\_INSTALL\Tools\psexec64.exe" -ArgumentList "-s -i ""c:\_INSTALL\Tools\procmon64.exe"" /Terminate" -Wait -NoNewWindow

        for (;;) { # Warten bis Procmon64.exe tatsächlich beendet wurde, um unvollständig gespeicherte PML-Dateien zu verhindern
            if ((Get-Process "Procmon64" -ErrorAction SilentlyContinue) -eq $Null) {
                break;
            }
            Start-Sleep -Seconds 2
        }

        # Memory-Dump erstellen
        Start-Process -FilePath "$($using:tools_path_vm)\winpmem_mini_x64_rc2.exe" -Wait -ArgumentList """D:\$($env:ComputerName)_$($using:scenario)_$($using:starttime)_memorydump.raw"" -2" | Out-Null

        # BitLocker: KeyProtectorId und Recovery-Key in Datenbank speichern
        $BitlockerVolumes = Get-BitLockerVolume
        $query=$query_fields=$query_values=""
        $BitlockerVolumes | ForEach-Object {
            $mountpoint_temp = $_.MountPoint
            $_.KeyProtector | ForEach-Object {
                if ($BitlockerVolumes.VolumeStatus -eq "FullyEncrypted") {
                    $kpi = $_.KeyProtectorId -Replace "{","" -Replace "}",""
                    if ($_.KeyProtectorType -eq "RecoveryPassword") {
                        if ($mountpoint_temp -eq "C:") {
                            $query_fields += "OS_KeyProtectorID,OS_RecoveryKey,"
                            $query_values += "'$($kpi)','$($_.RecoveryPassword)',"
                        }
                        if ($mountpoint_temp -eq "E:") {
                            $query_fields += "BasicDisk_KeyProtectorID,BasicDisk_RecoveryKey,"
                            $query_values += "'$($kpi)','$($_.RecoveryPassword)',"
                        }
                    }
                }
            }
        }    

        if ($query_fields -ne "") {
            $query = "INSERT INTO temp_RecoveryKey ($($query_fields)) VALUES ($($query_values))" -Replace ",\)",")"
            Invoke-SqlCmd -ServerInstance "$($using:db_server_address)" -Database "Artifacts" -Query $($query) -Username "sa" -Password "$($using:password)"
        }
        
        # Relevante Registry-Pfade nach SQL-Datenbank exportieren
        $registry_keys = ("HKLM\System\CurrentControlSet\Control\BitLocker",
            "HKLM\SOFTWARE\Policies\Microsoft\FVE",                                             # BitLocker-GPO-Einstellungen
            "HKLM\Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\disk\Enum",     # Alle DERZEIT angeschlossenen Datenträger
            "HKLM\Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB",               # Für Nachweis des verwendeten USB-Sticks
            "HKLM\Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBStor",           # Für Nachweis des verwendeten USB-Sticks
            "HKLM\SYSTEM\MountedDevices",                                                       # Für Nachweis des verwendeten BitLocker-Laufwerks
            "HKLM\SYSTEM\CurrentControlSet\Services\disk\Enum"                                  # Für Nachweis des verwendeten BitLocker-Laufwerks
        )

        foreach ($r in $registry_keys) {
            $r=$r -Replace "HCR","Registry::HKEY_CLASSES_ROOT" -Replace "HKCU","Registry::HKEY_CURRENT_USER" -Replace "HKLM","Registry::HKEY_LOCAL_MACHINE"
            foreach ($p in $r) {
                $allkeys = ($p | Get-ItemProperty -ErrorAction SilentlyContinue).Psobject.Properties | Where-Object { $_.Name -cnotlike 'PS*' } | Select-Object Name,Value
                foreach ($k in $allkeys) {
                    $short_key=$p.Replace("Registry::HKEY_CLASSES_ROOT","HCR")
                    $short_key= $short_key -Replace "Registry::HKEY_CURRENT_USER","HKCU" -Replace "Registry::HKEY_LOCAL_MACHINE","HKLM"
                    Invoke-SqlCmd -ServerInstance "$($using:db_server_address)" -Database "Artifacts" -Query "INSERT INTO temp_Registry ([Key],[Name],[Value]) VALUES ('$($short_key)','$($k.Name)','$($k.Value)')" -Username "sa" -Password "$($using:password)"
                }
            }
        }

        # Spezielles Ereignisprotokoll verarbeiten (können von LogParser nicht exportiert werden)
        $logfile_name = "Microsoft-Windows-BitLocker/BitLocker Management"
        $logs=Get-WinEvent -LogName $logfile_name | Where-Object { $_.TimeCreated -ge $using:starttime_sql } | Select-Object
        foreach ($l in $logs) {
            $timestamp = "$($l.TimeCreated.ToString().Substring(6,4))$($l.TimeCreated.ToString().Substring(3,2))$($l.TimeCreated.ToString().Substring(0,2)) $($l.TimeCreated.ToString().Substring(11,8))"
            $query = "INSERT INTO temp_eventlog (EventLog,TimeGenerated,SourceName,EventId,Message,ComputerName)`
                        VALUES ('$($logfile_name)', '$timestamp', '$($l.ProviderName)', '$($l.Id)', '$($l.Message)','$($env:computername)')"
            Invoke-SqlCmd -ServerInstance "$($using:db_server_address)" -Database "Artifacts" -Query $query -Username "sa" -Password "$($using:password)"
        }

        Start-Process "shutdown.exe" -ArgumentList "/f /s /t 20" # Ohne Wait ausführen, damit die u. g. Variable noch übergeben werden kann

        # Den End-Zeitpunkt noch an den Hyper-V-Host übergeben
        $endtime_sql = (Get-Date -Format "yyyy.MM.dd HH:mm:ss")  -replace "\.", ""
        $endtime_sql
    } -Credential $credential -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    Write-Host "fertig."

    # Start- und End-Zeitpunkt des Szenarios in der Datenbank speichern
    $starttime_sql = $starttime_sql -replace "/", ""
    Invoke-SqlCmd -ServerInstance "$($db_server_address)" -Database "Artifacts" -Query "UPDATE MainScenario SET StartTime='$($starttime_sql)',EndTime='$($endtime_sql)' WHERE MainScenario.ID='$($scenario_id)'" -Username "sa" -Password "$($password)"

    # Warten, bis ein Szenario fertig ist (= VM ist heruntergefahren)
    Write-Host -NoNewline "   VM herunterfahren..."
    ShutdownVmAndWait "$($w10_version_name)"
    Write-Host "fertig."

    # VHD-Date schreibgeschützt mounten
    $tempVhd_C = Get-VMHardDiskDrive -VMName "$($w10_version_name)" | Where-Object { $_.Path -like '*_OS*' } | Select-Object -ExpandProperty Path
    Mount-VHD -Path $tempVhd_C -ReadOnly    # Als Read-Only mounten, um keine Spuren zu verändern
    $driveLetter_C = Get-Partition (Get-DiskImage "$($tempVhd_C)").Number | Get-Volume | Select-Object -ExpandProperty DriveLetter
    
    $tempVhd_D = Get-VMHardDiskDrive -VMName "$($w10_version_name)" | Where-Object { $_.Path -like '*_temp*' } | Select-Object -ExpandProperty Path            
    Mount-VHD -Path $tempVhd_D              #  Darf writeable sein, enthält nur Analysedaten
    $driveLetter_D = Get-Partition (Get-DiskImage "$($tempVhd_D)").Number | Get-Volume | Select-Object -ExpandProperty DriveLetter

    # BitLocker-verschlüsselte Volumes entsperren
    if ((Get-BitLockerVolume $driveLetter_C | Where-Object { $_.ProtectionStatus -eq "Unknown" } | Select-Object -ExpandProperty ProtectionStatus) -eq "Unknown") {
        $recovery_key=Invoke-SqlCmd -ServerInstance "$($db_server_address)" -Database "Artifacts" -Query "SELECT OS_RecoveryKey FROM temp_RecoveryKey" -Username "sa" -Password "$($password)" | Select-Object -ExpandProperty OS_RecoveryKey
        Unlock-BitLocker "$($driveLetter_C)" -RecoveryPassword "$($recovery_key)" | Out-Null
    }

    # Standard-Ereignisprotokolle verarbeiten
    Write-Host -NoNewline "   Ereignisprotokolle in Datenbank speichern..."
    # Standardmäßige Ereignisprotokolle verarbeiten; nur diese werden von LogParser unterstützt
    $evtx_logfiles = @("Application.evtx","Security.evtx","System.evtx")
    foreach ($e in $evtx_logfiles) {
        Start-Process "c:\Program Files (x86)\Log Parser 2.2\logparser.exe" -Wait -Argumentlist "-i:evt ""SELECT * INTO temp_Eventlog FROM '$($driveLetter_C):\Windows\System32\Winevt\Logs\$($e)' WHERE TimeGenerated > timestamp('$($starttime_sql)', 'yyyyMMdd hh:mm:ss')"" -o:sql -server:$($db_server_address) -database:Artifacts -driver:""ODBC Driver 17 for SQL Server"" -username:sa -password:$($password) -createTable:ON" #-ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Copy-Item "$($driveLetter_C):\Windows\System32\Winevt\Logs\$($e)" "$($artifacts_directory)\$($w10_version_name)_$($scenario)_$($starttime)_$($e)" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    Write-Host "fertig."

    # Process Monitor-Daten in CSV-Datei konvertieren und in MSSQL importieren
    Write-Host -NoNewline "   Process Monitor-Protokolldaten in Datenbank speichern..."
    Get-ChildItem "$($driveLetter_D):\" -Filter *.pml | Sort-Object -Property Name |
    foreach-object  {
        Start-Process -FilePath "$($tools_path_host)\VM\Tools\Procmon64.exe" -Wait -ArgumentList "/accepteula /quiet /openlog ""$($driveLetter_D):\$($_.Name)"" /SaveAs ""$($driveLetter_D):\$($_.Name).csv"" /SaveApplyFilter /LoadConfig ""$($tools_path_host)\VM\Tools\ProcmonConfiguration.pmc"""
        $csv_temp_filename="$($driveLetter_D):\$($_.Name)_temp.csv"
        Get-Content "$($driveLetter_D):\$($_.Name).csv" -ReadCount 10000 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | 
            Foreach-Object {
                $line = $_.Replace(';', '[semicolon]')
                Add-Content -Path $($csv_temp_filename) -Value $line -Encoding UTF8
            }

        # CSV-Datei in SQL-Datenbank importieren
        $sql_conn = New-Object System.Data.SqlClient.SqlConnection
        $sql_conn.ConnectionString = "Server=$($db_server_address);Database=Artifacts;User ID=sa;Password=$($password)"
        $csv_table = Import-Csv "$($driveLetter_D):\$($_.Name)_temp.csv" | Out-DataTable # Benötigt Powershell-Modul PSSQLite
        $sql_bulk_copy = New-Object ("Data.SqlClient.SqlBulkCopy") -ArgumentList $sql_conn
        $sql_bulk_copy.BulkCopyTimeout=120
        $sql_bulk_copy.DestinationTableName = "dbo.temp_ProcessMonitor"
        $sql_conn.Open()
        $sql_bulk_copy.WriteToServer($csv_table)
        $sql_conn.Close()
    }
    Write-Host "fertig."

    # Prefetch-Dateien verarbeiten
    Write-Host -NoNewline "   Prefetch-Dateien in Datenbank speichern..."
    $prefetch_files = Get-ChildItem "$($driveLetter_C):\Windows\Prefetch\*.pf" | Where-Object { $_.LastWriteTime -gt "$($starttime_gci)" }
    foreach ($p in $prefetch_files) {
        Start-Process "$($tools_path_vm)\WinPrefetchView.exe" -Wait -ArgumentList "/prefetchfile ""$($driveLetter_C):\Windows\Prefetch\$($p.Name)"" /scomma ""$($driveLetter_D):\temp_$($p.Name).csv"" /sort Index"
        Import-CSV "$($driveLetter_D):\temp_$($p.Name).csv" | ForEach-Object { 
            $AllValues = "'$($p.Name)',","'"+($_.Psobject.Properties.Value -join "','")+"'" 
            Invoke-Sqlcmd -Database "Artifacts" -ServerInstance "$($db_server_address)" -Query "insert into temp_Prefetch_File VALUES ($AllValues)" -Username "sa" -Password $password
        } 
        Remove-Item "$($driveLetter_D):\temp_$($p.Name).csv" -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Confirm:$false
    }
    Write-Host "fertig."

    # File-Hashes wichtiger Dateien erstellen
    Write-Host -NoNewline "   Prüfsummen forensisch relevanter Dateien in Datenbank speichern..."
    $files_for_hasing = ("C:\Windows\System32\BitLockerWizardElev.exe",
        "C:\Windows\System32\bdechangepin.exe",
        "C:\Windows\System32\fveapi.dll",
        "C:\Windows\System32\fveui.dll",
        "C:\Windows\System32\manage-bde.exe"
    )
    foreach ($f in $files_for_hasing) {
        $filename = $f.Split("\")
        $filepath = $f -replace ($filename[$filename.length-1],"")
        $CreationTime = (Get-ChildItem "$($f)" | Select-Object -ExpandProperty CreationTime |  Get-Date -f "yyyyMMdd HH:mm:ss") -replace "\.", "/"
        $LastWriteTime = (Get-ChildItem "$($f)" | Select-Object -ExpandProperty LastWriteTime |  Get-Date -f "yyyyMMdd HH:mm:ss") -replace "\.", "/"
        $LastAccessTime= (Get-ChildItem "$($f)" | Select-Object -ExpandProperty LastAccessTime |  Get-Date -f "yyyyMMdd HH:mm:ss") -replace "\.", "/"

        $fileversion = Get-ChildItem "$($f)" | % { $_.VersionInfo } | Select-Object -ExpandProperty FileVersion
        $md5_hash = Get-FileHash $($f) -Algorithm MD5 | Select-Object -ExpandProperty Hash
        $sha1_hash = Get-FileHash $($f) -Algorithm SHA1 | Select-Object -ExpandProperty Hash
        Invoke-Sqlcmd -Database "Artifacts" -ServerInstance "$($db_server_address)" -Query "INSERT INTO temp_File_Hashes VALUES ('$($filename[$filename.Length-1])','$($filepath)',CAST('$($CreationTime)' AS DATETIME),CAST('$($LastWriteTime)' AS DATETIME),CAST('$($LastAccessTime)' AS DATETIME),'$($fileversion)','$($md5_hash)','$($sha1_hash)')" -Username "sa" -Password $password
    }
    Write-Host "fertig."

    # Temporäre Tabellen durch Stored Procedure konvertieren und temporäre Tabellen leeren
    Write-Host -NoNewline "   In Datenbank gespeicherte Daten aufbereiten..."
    Invoke-SqlCmd -ServerInstance "$($db_server_address)" -Database "Artifacts" -Query "EXEC convertTempTables @scenario_id = $($scenario_id)" -Username "sa" -Password "$($password)"
    Write-Host "fertig."

    # USB-Stick-Emulation auf Host beenden
    Get-Process vhusbdwindk64 | Stop-Process -Force -Confirm:$false

    # Mit FTK-Imager eine E01-Datei von der Festplatte der VM erstellen
    $disk_number_C = (Get-DiskImage "$($tempVhd_C)").DevicePath # Betriebssystem-Datenträger
    
    # Relevante Dateien sichern
    Write-Host -NoNewline "   Forensisch relevante Dateien der VM kopieren..."
    Copy-Item "$($driveLetter_C):\Users\Administrator\NTUSER.DAT" "$($artifacts_directory)\$($w10_version_name)_$($scenario)_$($starttime)_NTUSER.DAT"
    (Get-ChildItem "$($artifacts_directory)\$($w10_version_name)_$($scenario)_$($starttime)_NTUSER.DAT"-Force).Attributes -="Hidden"
    Copy-Item "$($driveLetter_C):\Windows\system32\config\SAM" "$($artifacts_directory)\$($w10_version_name)_$($scenario)_$($starttime)_SAM"
    Copy-Item "$($driveLetter_C):\Windows\system32\config\SECURITY" "$($artifacts_directory)\$($w10_version_name)_$($scenario)_$($starttime)_SECURITY"
    Copy-Item "$($driveLetter_C):\Windows\system32\config\SOFTWARE" "$($artifacts_directory)\$($w10_version_name)_$($scenario)_$($starttime)_SOFTWARE"
    Copy-Item "$($driveLetter_C):\Windows\system32\config\SYSTEM" "$($artifacts_directory)\$($w10_version_name)_$($scenario)_$($starttime)_SYSTEM"
    Move-Item "$($driveLetter_D):\*.txt" "$($artifacts_directory)" -Force -Confirm:$false
    Move-Item "$($driveLetter_D):\*.csv" "$($artifacts_directory)" -Force -Confirm:$false
    Move-Item "$($driveLetter_D):\*.pml" "$($artifacts_directory)" -Force -Confirm:$false
    Move-Item "$($driveLetter_D):\*.raw" "$($artifacts_directory)" -Force -Confirm:$false
    Write-Host "fertig."

    Write-Host -NoNewline "   Datenträger-Abbild mit FTK Imager erstellen..." # Da auf Ebene der Physical Disk und als Read-Only gemountet muss die VHD-Datei nicht ausgehängt werden
    # Optional: Prüfsumme von E01-Datei mit --verify erstellen
    Start-Process "$($tools_path_vm)\ftkimager\ftkimager.exe" -Wait -ArgumentList "$($disk_number_C) ""$($artifacts_directory)\$($w10_version_name)_$($scenario)_OS"" --e01 --compress 9"
    Write-Host "fertig."

    # Gemountete VHD-Dateien wieder dismounten
    Dismount-VHD -Path $tempVhd_C
    Dismount-VHD -Path $tempVhd_D

    # Obsolete .avhd-Dateien löschen, um Speicherplatz zu sparen
    Get-ChildItem "$($vm_path)\$($w10_version_name)\*.avhdx" | Where-Object { $_.FullName -ne $tempvhd_C -and $_.FullName -ne $tempvhd_D } | Remove-Item -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

    # VM auf Snapshot zurücksetzen
    Write-Host -NoNewline "   Snapshot ""Grundinstallation"" für VM $($w10_version_name) anwenden..."
    Restore-VMSnapshot -VMName "$($w10_version_name)" -Name "Grundinstallation" -Confirm:$false
    Write-Host "fertig."
    
    Write-Host ""
    Write-Host "=> Szenario $($scenario) beendet: $((Get-Date -Format "dd.MM.yyyy HH:mm:ss"))"
    Write-Host ""
}

function ShutdownVmAndWait($vmname) {
    Stop-Computer -ComputerName "$($vmname)" -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    Start-Sleep -Seconds 2
    If ((Get-VM "$($vmname)").State -ne "Off") {
        Stop-VM -Name "$($vmname)" -TurnOff -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
}

Clear-Host

Import-Module SQLServer
Import-Module PSSQLite

$Global:ProgressPreference = 'SilentlyContinue' # Alle Fortschrittsbalken unterdrücken, z. B. bei Test-NetConnection
$db_server_address = "TS"                       # Hostname des Hyper-V-Hosts
$password = "Pa`$`$w0rd"
$tools_path_vm = "C:\_INSTALL\Tools"
$tools_path_host = "C:\_INSTALL"
$artifacts_root_directory="D:\W10_Artifacts"
$vm_path = "D:\HyperV"


#
# Hier nun Aufruf der Methode Invoke-Scenario, um das Szenario auszuführen.
# Bezeichnung der VM und Szenario-Nummer sind zu übergeben.
#
# Beispiel: Invoke-Scenario "W10_20H2" "11"

