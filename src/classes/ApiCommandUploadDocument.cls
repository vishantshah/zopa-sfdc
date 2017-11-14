public class ApiCommandUploadDocument  extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    @TestVisible private Blob DocumentBody;
    @TestVisible private String DocumentType;
    @TestVisible private String DocumentMimeType;
    @TestVisible private String DocumentName;
    @TestVisible private static final String MULTIPART_REQUEST_BOUNDARY = '----------------------------741e90d31eff';

    public ApiCommandUploadDocument(String uuid, Blob document_body, String document_type, String document_name, String document_mime_type) {
        super(ApiCommandsFactory.UPLOAD_DOCUMENT_COMMAND, uuid);
        DocumentBody = document_body;
        DocumentType = document_type;
        DocumentName = document_name;
        DocumentMimeType = document_mime_type;
    }

    override protected Map<String, String> buildMapHeaders() {
        return new Map<String, String>{'Content-Type' => 'multipart/form-data; boundary=' + MULTIPART_REQUEST_BOUNDARY};
    }

    override protected ApiCommandAbstractBuilder setBody() {
        HttpApiRequest.setBodyAsBlob(getDecodedBlobBody());
        return this;
    }

    @TestVisible private Blob getDecodedBlobBody() {
        String header = '--' + MULTIPART_REQUEST_BOUNDARY + '\r\nContent-Disposition: ' + DocumentType + '; filename="' + DocumentName + '"' +
                        '\r\nContent-Type: ' + DocumentMimeType + '';
        String footer = '--' + MULTIPART_REQUEST_BOUNDARY + '--';
        String header_encoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(header_encoded.endsWith('=')) {
            header += ' ';
            header_encoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String body_encoded = EncodingUtil.base64Encode(DocumentBody);
        Blob body_blob = null;
        String last_4_bytes = body_encoded.substring(body_encoded.length() - 4, body_encoded.length());

        if(last_4_bytes.endsWith('==')) {
            last_4_bytes = last_4_bytes.substring(0,2) + '0K';
            body_encoded = body_encoded.substring(0, body_encoded.length() - 4) + last_4_bytes;
        } else if(last_4_bytes.endsWith('=')) {
            last_4_bytes = last_4_bytes.substring(0,3) + 'N';
            body_encoded = body_encoded.substring(0,body_encoded.length() - 4) + last_4_bytes;
            footer = '\r\n' + footer;
        } else {
            footer = '\r\n' + footer;
        }
        String footer_encoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        body_blob = EncodingUtil.base64Decode(header_encoded + body_encoded + footer_encoded);
        return body_blob;
    }
}