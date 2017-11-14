global class ApiLoanEquifaxTestMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Boolean EmptyResponse;

    global ApiLoanEquifaxTestMock(Boolean is_success) {
        this(is_success, false);
    }

    global ApiLoanEquifaxTestMock() {
        this(true, false);
    }

    global ApiLoanEquifaxTestMock(Boolean is_success, Boolean empty_response) {
        IsSuccess = is_success;
        EmptyResponse = empty_response;
    }

    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('GET', request.getMethod(),'Request must be GET method');
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse(EmptyResponse);
        } else {
            response = getInternalErrorResponse();
        }
        return response;
    }

    public static HttpResponse getInternalErrorResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(500);
        http_response.setStatus('Salesforce Internal Error');
        http_response.setBody('{"message":"Internal Error"}');
        return http_response;
    }

    public static HttpResponse getSuccessResponse(Boolean is_empty_body) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        if(is_empty_body){
            http_response.setBody(getTestEmptyJsonBody());
        } else{
            http_response.setBody(getTestJsonBody());
        }
        return http_response;
    }

    public static String getTestJsonBody() {
        String json = '{' +
        '   "applicantCreditChecks":[' +
        '      {' +
        '         "address":"123 my street, some town, PO5 4CD",' +
        '         "insights":[' +
        '            {' +
        '               "name":"Mr Adam Test",' +
        '               "dateOfBirth":"1991-10-28T00:00:00",' +
        '               "startDate":"2016-02-12T00:00:00",' +
        '               "endDate":null,' +
        '               "balance":2124.0,' +
        '               "creditLimit":0.0,' +
        '               "paymentHistory":"0000UU",' +
        '               "companyClass":"Credit Broker",' +
        '               "accountType":"Loan",' +
        '               "terms":"113 over 24M",' +
        '               "updateDate":"2016-08-07T00:00:00",' +
        '               "defaultBalance":0.0,' +
        '               "delinquentDate":null,' +
        '               "flags":"A"' +
        '            },' +
        '            {' +
        '               "name":"Mr Adam Test",' +
        '               "dateOfBirth":"1991-10-28T00:00:00",' +
        '               "startDate":"2015-10-25T00:00:00",' +
        '               "endDate":"2015-10-26T00:00:00",' +
        '               "balance":269.0,' +
        '               "creditLimit":0.0,' +
        '               "paymentHistory":"UUUUUUUUUU",' +
        '               "companyClass":"Finance House",' +
        '               "accountType":"Fixed Term Deferred",' +
        '               "terms":"35 over 36M",' +
        '               "updateDate":"2016-08-15T00:00:00",' +
        '               "defaultBalance":0.0,' +
        '               "delinquentDate":null,' +
        '               "flags":null' +
        '            }' +
        '         ]' +
        '      },' +
        '      {' +
        '         "address":"76 Trombones Road, Bristol, BS94EZ",' +
        '         "insights":[' +
        '            {' +
        '               "name":"Mr Adam Test",' +
        '               "dateOfBirth":"1991-10-28T00:00:00",' +
        '               "startDate":"2003-09-12T00:00:00",' +
        '               "endDate":"2011-08-15T00:00:00",' +
        '               "balance":2124.0,' +
        '               "creditLimit":0.0,' +
        '               "paymentHistory":"S00000000000000000000000000000000000000000000000",' +
        '               "companyClass":"Bank",' +
        '               "accountType":"Current Account",' +
        '               "terms":null,' +
        '               "updateDate":"2011-09-28T00:00:00",' +
        '               "defaultBalance":0.0,' +
        '               "delinquentDate":null,' +
        '               "flags":null' +
        '            }' +
        '         ]' +
        '      }' +
        '   ],' +
        '   "associatedCreditChecks":[' +
        '      {' +
        '         "address":"123 my street, some town, PO5 4CD",' +
        '         "insights":[' +
        '            {' +
        '               "name":"Mrs Adrienne Test",' +
        '               "dateOfBirth":"1992-11-29T00:00:00",' +
        '               "startDate":"2013-11-23T00:00:00",' +
        '               "endDate":null,' +
        '               "balance":0.0,' +
        '               "creditLimit":0.0,' +
        '               "paymentHistory":"00000000000000000000000000000000",' +
        '               "companyClass":"Comms Supplier",' +
        '               "accountType":"Comms Supplier",' +
        '               "terms":null,' +
        '               "updateDate":"2016-07-21T00:00:00",' +
        '               "defaultBalance":0.0,' +
        '               "delinquentDate":null,' +
        '               "flags":null' +
        '            }' +
        '         ]' +
        '      }' +
        '   ],' +
        '   "familyCreditChecks":[' +
        '      {' +
        '         "address":"123 my street, some town, PO5 4CD",' +
        '         "insights":[' +
        '            {' +
        '               "name":"Mr Thomas Test",' +
        '               "dateOfBirth":"1992-11-29T00:00:00",' +
        '               "startDate":"2013-11-23T00:00:00",' +
        '               "endDate":null,' +
        '               "balance":0.0,' +
        '               "creditLimit":0.0,' +
        '               "paymentHistory":"S00000000000",' +
        '               "companyClass":"Retailer",' +
        '               "accountType":"Fixed Term",' +
        '               "terms":"36 over 10M",' +
        '               "updateDate":"2016-07-21T00:00:00",' +
        '               "defaultBalance":0.0,' +
        '               "delinquentDate":null,' +
        '               "flags":null' +
        '            }' +
        '         ]' +
        '      }' +
        '   ],' +
        '   "otherCreditChecks":[' +
        '      {' +
        '         "address":"76 Trombones Road, Bristol, BS94EZ",' +
        '         "insights":[' +
        '            {' +
        '               "name":"Mr Robert Peter Jones",' +
        '               "dateOfBirth":"1992-11-29T00:00:00",' +
        '               "startDate":"2011-11-23T00:00:00",' +
        '               "endDate":null,' +
        '               "balance":100065.0,' +
        '               "creditLimit":0.0,' +
        '               "paymentHistory":"000000000000000000000000000000000000000000000000",' +
        '               "companyClass":"Bank",' +
        '               "accountType":"Mortgage",' +
        '               "terms":"380 over 469M",' +
        '               "updateDate":"2016-07-21T00:00:00",' +
        '              "defaultBalance":0.0,' +
        '               "delinquentDate":"2011-11-23T00:00:00",' +
        '               "flags":"A"' +
        '            }' +
        '         ]' +
        '      }' +
        '   ]' +
        '}';
        return json;
    }

    public static String getTestEmptyJsonBody() {
        String json = '{' +
        '   "applicantCreditChecks":null,' +
        '   "associatedCreditChecks":null,' +
        '   "familyCreditChecks":[],' +
        '   "otherCreditChecks":[]' +
        '}';
        return json;
    }
}