public class CaseCollectionsRecoveriesDetails{
    public Case CurrentCase {get; private set;}
    public Boolean LazyLoadFinished {get; private set;}

    public CaseCollectionsRecoveriesDetails(ApexPages.StandardController controller) {
        CurrentCase = (Case)controller.getRecord();
        LazyLoadFinished = false;
    }

    public PageReference getDetailsInformation(){
        LazyLoadFinished = true;
        return null;
    }
}