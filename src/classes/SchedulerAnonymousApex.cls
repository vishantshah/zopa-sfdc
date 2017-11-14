public with sharing class SchedulerAnonymousApex {
    public static void abortAllSchedulableJobs(){
        List<String> job_types_to_exclude = new List<String>{'3', '4', '8'};
        for (CronTrigger Job : [SELECT Id FROM CronTrigger WHERE NextFireTime != NULL AND CronJobDetail.JobType NOT IN :job_types_to_exclude])
            System.abortJob(Job.Id);
    }

    public static void restoreSchedulableJobs(){
        final String StaticResourceName = 'SchedulableJobs';
        List<Map<String,String>> ScheduledJobsList = CsvUtility.getDataFromCsvStaticResource(StaticResourceName);
        for (Map<String,String> ScheduledJobMap : ScheduledJobsList){
            String JobName = ScheduledJobMap.get('Name');
            String CronExpression = ScheduledJobMap.get('Cron Expression');
            Type SchedulableClass = Type.forName(ScheduledJobMap.get('Class Name'));
            try {
                System.schedule(JobName, CronExpression, (Schedulable)SchedulableClass.newInstance());
            } catch (System.AsyncException e) {
                System.debug('Anonymous apex job "' + JobName + '" is allready started."');
            }
        }
    }
}