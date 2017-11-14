Name,Cron Expression,Class Name
Reevaluate underwriting assignment rules hourly,0 0 * * * ?,ScheduleRunUnderwritingAssignments
Reevaluate collections assignment rules hourly,0 0 * * * ?,ScheduleRunCollectionsAssignments
Reevaluate loan pending consolidation queue,0 0 8 * * ?,ScheduleUpdateLoanConsolidationQueue
Update OAuth Token every 30 mins 1,0 0 * * * ?,ScheduleUpdateZopaOAuth
Update OAuth Token every 30 mins 2,0 30 * * * ?,ScheduleUpdateZopaOAuth
Count days Case in Arrears process,0 30 7 * * ?,CaseArrearsDayCountBatch
Update Case Counters,0 0 6 * * ?,BatchUpdateCaseCounters