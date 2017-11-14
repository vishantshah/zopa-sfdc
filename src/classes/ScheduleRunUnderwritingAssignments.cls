public class ScheduleRunUnderwritingAssignments implements Schedulable {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchUpdateCaseAssignments(BatchUpdateCaseAssignments.JobMode.UNDERWRITING), 20);
    }
}