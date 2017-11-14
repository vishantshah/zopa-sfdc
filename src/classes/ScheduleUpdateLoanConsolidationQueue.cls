global class ScheduleUpdateLoanConsolidationQueue implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchUpdateLoanConsolidationQueue(), 10);
    }
}