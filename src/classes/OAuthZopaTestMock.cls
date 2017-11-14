@isTest
public class OAuthZopaTestMock {
    public static Boolean CalloutMade = false;
    public static String ResponseType = 'success';

    public static void setResponseResult(String response_type) {
        ResponseType = response_type;
    }

    public static HTTPResponse respond(HTTPRequest request) {
        CalloutMade = true;
        System.assertEquals('POST', request.getMethod(),'Request must be POST method');
        System.assert(request.getEndpoint().endsWith('/oauth/connect/token'),'Wrong endpoint');
        HttpResponse response;
        if (ResponseType == 'success') {
            response = getSuccessResponse();
        } else if (ResponseType == 'fail') {
            response = getInternalErrorResponse();
        } else if (ResponseType == 'wrong') {
            response = getWrongResponse();
        }
        return response;
    }

    private static HttpResponse getInternalErrorResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(500);
        http_response.setStatus('Internal Error');
        http_response.setBody('Required SSL');
        return http_response;
    }

    private static HttpResponse getSuccessResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBody('{"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSIsImtpZCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSJ9.eyJpc3MiOiJodHRwczovL2lkZW50aXR5LnNhbmRib3guem9waWFuLmFkLnpvcGEuY29tIiwiYXVkIjoiaHR0cHM6Ly9pZGVudGl0eS5zYW5kYm94LnpvcGlhbi5hZC56b3BhLmNvbS9yZXNvdXJjZXMiLCJleHAiOjE0ODEwNjc1MTYsIm5iZiI6MTQ4MTA2MzkxNiwiY2xpZW50X2lkIjoiY2xpZW50Y3JlZGVudGlhbHMuY2xpZW50IiwiY2xpZW50X2xvY2F0aW9uIjoiZGF0YWNlbnRlciIsInNjb3BlIjoid3JpdGUifQ.D-RWFobxNm4ki9Ynreomqiw65DRfd-ADn93lT8GZuXzmEXm5rraf57tSne9jYUjayGMzU8v7z1z6YYRcl8ofSLnBzVw2_n94GtIcxc7WqjUwa5nBa7thRzZa1WcYP3VYDEAccb1jJe7yu52U-txXeRVSg_p9g0RHT6pCQrzrDlvKTdXVvGdiGyjpVNu0IZozHVSC1UgNZGuvW3V9Fa3nUl-dyPKQN8RV2v3_B5BeltfQrymRTM2_zGah1qzhuLyIJ_RkpU876lkYpx3e89qIq8UwIMRhemRiLTcG1AnwtFpNn9fEH1cfYs7NmCUNVuWQlqqP4emtPVUx2e8Vo_bXHQ","expires_in":3000,"token_type":"Bearer"}');
        return http_response;
    }

    private static HttpResponse getWrongResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBody('{"token":"test","expires_in":3600,"token_type":"Bearer"}');
        return http_response;
    }
}