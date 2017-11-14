public class ManageLetterTemplatesController {

    public Boolean LazyLoadFinishedPickTemplate {public get; private set;}
    public Boolean LazyLoadFinishedTemplateBlock {public get; private set;}
    public Boolean IsEditMode {public get; private set;}
    public Boolean IsShownPreview {public get; private set;}
    public List<SelectOption> AllTemplatesOptions {public get; private set;}
    public String SelectedTemplateName {public get; public set;}
    public ApiCommandLetterTemplatesGet.LetterTemplate SelectedTemplate {public get; public set;}
    public String TemplateBody {public get; public set;}

    public ManageLetterTemplatesController() {
        LazyLoadFinishedPickTemplate = false;
        LazyLoadFinishedTemplateBlock = false;
        IsEditMode = false;
        IsShownPreview = false;
    }

    public PageReference getAllLetterTemplates() {
        ApiCommandLetterTemplatesGetAll get_all_templates_command = new ApiCommandLetterTemplatesGetAll();
        ApiCommandsFactory.getInstance().performApiCommandCallout(get_all_templates_command);
        if(get_all_templates_command.CommandSuccessful){
            List<ApiCommandLetterTemplatesGet.LetterTemplate> all_templates = get_all_templates_command.getResponse();
            setTemplatesOptions(all_templates);
            MessageUtility.addConfirmPageMessage('Templates retrieved successfully!');
        } else {
            MessageUtility.addErrorPageMessage(get_all_templates_command.CommandError);
        }
        LazyLoadFinishedPickTemplate = true;
        return null;
    }

    private void setTemplatesOptions(List<ApiCommandLetterTemplatesGet.LetterTemplate> templates){
        AllTemplatesOptions = new List<SelectOption>();
        for(ApiCommandLetterTemplatesGet.LetterTemplate template : templates){
            AllTemplatesOptions.add(new SelectOption(template.Name, template.FriendlyName));
        }
    }

    public void onClickSetTemplate(){
        LazyLoadFinishedTemplateBlock = false;
        SelectedTemplate = null;
        getTemplate();
        LazyLoadFinishedTemplateBlock = true;
        IsEditMode = false;
    }

    private void getTemplate(){
        ApiCommandLetterTemplatesGet get_template_command = new ApiCommandLetterTemplatesGet(SelectedTemplateName);
        ApiCommandsFactory.getInstance().performApiCommandCallout(get_template_command);
        if(get_template_command.CommandSuccessful){
            SelectedTemplate = get_template_command.getResponse();
            MessageUtility.addConfirmPageMessage('Template retrieved successfully! (' + SelectedTemplate.FriendlyName + ')');
        } else {
            MessageUtility.addErrorPageMessage(get_template_command.CommandError);
        }
    }

    public PageReference onClickTurnEditMode(){
        IsEditMode = true;
        return null;
    }

    public void onClickTurnViewMode(){
        IsEditMode = false;
    }

    public PageReference showPreviewMode(){
        IsShownPreview = true;
        return null;
    }

    public PageReference hidePreviewMode(){
        IsShownPreview = false;
        return null;
    }

    public void onClickSaveTemplate(){
        if(!String.isEmpty(SelectedTemplate.Html)){
            LazyLoadFinishedTemplateBlock = false;
            ApiCommandLetterTemplatesPost post_template_command = new ApiCommandLetterTemplatesPost(SelectedTemplate.Name, SelectedTemplate.Html);
            ApiCommandsFactory.getInstance().performApiCommandCallout(post_template_command);
            if(post_template_command.CommandSuccessful){
                MessageUtility.addInfoPageMessage('Template was successfuly saved!');
                onClickTurnViewMode();
                getTemplate();
                IsEditMode = false;
            } else {
                MessageUtility.addErrorPageMessage(post_template_command.CommandError);
            }
            LazyLoadFinishedTemplateBlock = true;
        }else{
            MessageUtility.addErrorPageMessage('Template Body should not be empty!');
        }
    }
}