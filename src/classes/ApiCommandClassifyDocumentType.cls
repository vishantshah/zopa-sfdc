public class ApiCommandClassifyDocumentType extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    @TestVisible private String DocumentId;
    @TestVisible private String DocumentType;

    public ApiCommandClassifyDocumentType(String uuid, String doc_id, String doc_type) {
        super(ApiCommandsFactory.DOCUMENT_CLASSIFY_TYPE_COMMAND, uuid);
        DocumentId = doc_id;
        DocumentType = doc_type;
    }

    override protected ApiCommandAbstractBuilder setEndpoint(String endpoint) {
        HttpApiRequest.setEndpoint(endpoint.replace('{DocumentId}', DocumentId));
        return this;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(new DocumentClassificationResource(DocumentType));
    }

    private class DocumentClassificationResource {
        public String DocumentType;

        public DocumentClassificationResource(String type) {
            DocumentType = type;
        }
    }
}