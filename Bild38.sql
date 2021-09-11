SELECT
	ComputerName,EventLog,EventID,Message
FROM
	EventLog
		INNER JOIN
			MainScenario ON MainScenario.ID = EventLog.Scenario_ID
		INNER JOIN
			Scenario_Template ON
				MainScenario.Scenario_Template_ID = Scenario_Template.ID
	WHERE
		EventID IN (775,768,817)
	ORDER BY
		ComputerName

