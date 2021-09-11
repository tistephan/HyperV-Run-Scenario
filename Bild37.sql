SELECT
	[Process Name],Operation,[Command Line],Path
FROM
	ProcessMonitor
		INNER JOIN
			MainScenario ON MainScenario.ID = ProcessMonitor.Scenario_ID
		INNER JOIN
			Scenario_Template ON
				MainScenario.Scenario_Template_ID = Scenario_Template.ID
WHERE
	Path
		LIKE '%BitLocker%'


