global class ScheduleBatchUpdateCaseAssignments {

    global class ScheduleUpdateUnderwritingAssignments implements Schedulable {
        global void execute(SchedulableContext sc) {
            Database.executeBatch(new BatchUpdateCaseAssignments(BatchUpdateCaseAssignments.JobMode.UNDERWRITING), 20);
        }
    }

    global class ScheduleUpdateCollectionsAssignments implements Schedulable {
        global void execute(SchedulableContext sc) {
            Database.executeBatch(new BatchUpdateCaseAssignments(BatchUpdateCaseAssignments.JobMode.COLLECTIONS), 20);
        }
    }
}