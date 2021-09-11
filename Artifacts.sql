USE [Artifacts]
GO
/****** Object:  StoredProcedure [dbo].[convertTempTables]    Script Date: 11.09.2021 15:16:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[convertTempTables] @scenario_id INT
AS
	INSERT INTO dbo.Eventlog
		(Scenario_ID,EventLog,RecordNumber,TimeGenerated,TimeWritten,EventID,EventType,EventTypeName,EventCategory,EventCategoryName,SourceName,Strings,ComputerName,SID,Message,Data)
	SELECT
		@scenario_id,EventLog,RecordNumber,TimeGenerated,TimeWritten,EventID,EventType,EventTypeName,EventCategory,EventCategoryName,SourceName,Strings,ComputerName,SID,Message,Data
	FROM temp_Eventlog

	-- Protokolldaten in Tabelle ProcessMonitor weiter eingrenzen, da Process Monitor-Filter nicht alle Angaben entfernt
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Services\Tcpip%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Temp%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%pnputil.exe%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\$Mft%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\$EXTEND%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\$Secure:$SDS:$DATA%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\Recovery\WindowsRE%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\Windows\INF%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\System Volume Information%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\Windows\System32\CatRoot%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\$LogFile%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\SYSTEM\DriverDatabase%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKCR\Interface%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKCU\Console%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKCU\System\GameConfigStore%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DeviceDisplayObjects%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Control\DeviceClasses%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Control\DeviceContainers%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Control\Terminal Server%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Services\DeviceInstall%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Services\Tcpip%'
	DELETE FROM temp_ProcessMonitor WHERE [PATH] LIKE '%procmon%'
	DELETE FROM temp_ProcessMonitor WHERE [Command Line] LIKE 'MsMpEng.exe'
	DELETE FROM temp_ProcessMonitor WHERE [Path] IN ('HKLM\System\CurrentControlSet\Control','HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Management Infrastructure\ErrorResources','HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Winners','HKLM\System\CurrentControlSet\Control\Session Manager\Environment','HKCU\Control Panel\International','HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Publishers','HKLM\System\CurrentControlSet\Control','HKCU','HKCR','HKLM','HKLM\SOFTWARE','C:\Windows\ServiceProfiles\NetworkService','HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion','HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR')

	INSERT INTO dbo.ProcessMonitor
		(Scenario_ID,[Time of Day],[Process Name],PID,Operation,[Path],Result,Detail,TID,[Date & Time],[Image Path],[Command Line],[Version],[User],[Session],[Parent PID])
	SELECT
		@scenario_id,[Time of Day],[Process Name],PID,Operation,[Path],Result,Detail,TID,[Date & Time],[Image Path],[Command Line],[Version],[User],[Session],[Parent PID]
	FROM temp_ProcessMonitor
	ORDER BY [Time of Day]

	
	-- Sonderzeichen in Tabelle ProcessMonitor ersetzen
	UPDATE 
	    ProcessMonitor
	SET
		[Command Line] = REPLACE([Command Line],'[semicolon]',';'),
		Detail = REPLACE(Detail,'[semicolon]',';'),
		Operation = REPLACE(Operation,'[semicolon]',';'),
		[Path] = REPLACE([Path],'[semicolon]',';')		
	WHERE
		Operation LIKE '%[semicolon]%'
	   
	INSERT INTO dbo.Prefetch_File
		(Scenario_ID,Prefetch_Filename,Referenced_Filename,Path,Device_Path,[Index])
	SELECT
		@scenario_id,Prefetch_Filename,Referenced_Filename,Path,Device_Path,[Index]
	FROM temp_Prefetch_File

	INSERT INTO dbo.Registry
		(Scenario_ID,[Key],[Name],[Value])
	SELECT
		@scenario_id,[Key],[Name],[Value]
	FROM temp_Registry

	INSERT INTO dbo.File_Hashes
		(Scenario_ID,Filename,Path,Timestamp_Created,Timestamp_Changed,Timestamp_LastAccess,Fileversion,MD5_Checksum,SHA1_Checksum)
	SELECT
		@scenario_id,Filename,Path,Timestamp_Created,Timestamp_Changed,Timestamp_LastAccess,Fileversion,MD5_Checksum,SHA1_Checksum
	FROM temp_File_Hashes

	IF EXISTS(SELECT * FROM RecoveryKey WHERE Scenario_id=@scenario_id)
		UPDATE RecoveryKey
		SET
			RecoveryKey.OS_KeyProtectorID=CASE WHEN RecoveryKey.OS_KeyProtectorID IS NULL THEN (SELECT OS_KeyProtectorID FROM temp_RecoveryKey) ELSE (SELECT OS_RecoveryKey FROM RecoveryKey WHERE Scenario_ID=@scenario_id) END,
			RecoveryKey.OS_RecoveryKey=CASE WHEN RecoveryKey.OS_RecoveryKey IS NULL THEN (SELECT OS_RecoveryKey FROM temp_RecoveryKey) ELSE (SELECT OS_RecoveryKey FROM RecoveryKey WHERE Scenario_ID=@scenario_id) END,
			RecoveryKey.BasicDisk_KeyProtectorID=CASE WHEN RecoveryKey.BasicDisk_KeyProtectorID IS NULL THEN (SELECT BasicDisk_KeyProtectorID FROM temp_RecoveryKey) ELSE (SELECT BasicDisk_KeyProtectorID FROM RecoveryKey WHERE Scenario_ID=@scenario_id) END,
			RecoveryKey.BasicDisk_RecoveryKey=CASE WHEN RecoveryKey.BasicDisk_RecoveryKey IS NULL THEN (SELECT BasicDisk_RecoveryKey FROM temp_RecoveryKey) ELSE (SELECT BasicDisk_RecoveryKey FROM RecoveryKey WHERE Scenario_ID=@scenario_id) END
		WHERE RecoveryKey.Scenario_ID=@scenario_id
	ELSE
		INSERT INTO dbo.RecoveryKey
			(Scenario_ID,OS_KeyProtectorID,OS_RecoveryKey,BasicDisk_KeyProtectorID,BasicDisk_RecoveryKey)
		SELECT
			@scenario_id,OS_KeyProtectorID,OS_RecoveryKey,BasicDisk_KeyProtectorID,BasicDisk_RecoveryKey
		FROM temp_RecoveryKey

	-- Temporäre Tabellen leeren
	DELETE FROM temp_Eventlog
	DELETE FROM temp_ProcessMonitor
	DELETE FROM temp_Prefetch_File
	DELETE FROM temp_File_Hashes
	DELETE FROM temp_Registry
	DELETE FROM temp_RecoveryKey

