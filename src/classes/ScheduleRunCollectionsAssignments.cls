public class ScheduleRunCollectionsAssignments implements Schedulable {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchUpdateCaseAssignments(BatchUpdateCaseAssignments.JobMode.COLLECTIONS), 20);
    }
}