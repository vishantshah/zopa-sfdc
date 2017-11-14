global class ApiLoanCallCreditTestMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Boolean EmptyResponse;

    global ApiLoanCallCreditTestMock(Boolean is_success) {
        this(is_success, false);
    }

    global ApiLoanCallCreditTestMock() {
        this(true, false);
    }

    global ApiLoanCallCreditTestMock(Boolean is_success, Boolean empty_response) {
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
        '       "applicantSummary":{' +
        '          "totalBalancesActive":102728.0,' +
        '          "totalBalancesLoans":2663.0,' +
        '          "totalBalancesMortgages":100065.0,' +
        '          "totalBalancesRevolve":10034,' +
        '          "totalLimitsRevolve":123,' +
        '          "balanceLimitRatioRevolve":123,' +
        '          "totalValueCashAdvances12Months":456,' +
        '          "totalValueCashAdvances36Months":789,' +
        '          "totalDelinqs12Months":0,' +
        '          "worstPayStatus12Months":"U",' +
        '          "worstPayStatus36Months":"U",' +
        '          "totalDefaults12Months":0,' +
        '          "totalDefaults36Months":0,' +
        '          "currentlyInsolvent":false,' +
        '          "totalDischargedBAIs":0,' +
        '          "totalActiveJudgements":0,' +
        '          "totalSatisfiedJudgements":0,' +
        '          "totalHomeCreditSearches3Months":0' +
        '       },' +
        '       "summaryAddresses":[' +
        '          {' +
        '            "current":true,' +
        '             "address":"123 my street, some town, PO5 4CD",' +
        '             "level":"Individual",' +
        '             "source":"Electoral Roll"' +
        '          }' +
        '       ],' +
        '       "applicantsCurrentAddressElectoralRoll":[' +
        '          {' +
        '             "address":"123 my street, some town, PO5 4CD",' +
        '             "resident":"Mr Adam Test",' +
        '             "duration":"12/2015 to date"' +
        '      }' +
        '       ],' +
        '       "isIndividualReport":true,' +
        '       "unsettledShareAccounts":null,' +
        '       "settledShareAccounts":[' +
        '          {' +
        '             "accountHolderName":"Mr Adam Test",' +
        '             "accountHolderAddress":"123 my street, some town, PO5 4CD",' +
        '             "historicPaymentStatus":[' +
        '                "0",' +
        '                "0",' +
        '                "0",' +
        '                "0",' +
        '                "U",' +
        '                "U"' +
        '             ],' +
        '             "historicAccountStatus":[' +
        '                "OK",' +
        '                "OK",' +
        '                "OK",' +
        '                "OK",' +
        '                "UC",' +
        '                "UC"' +
        '             ],' +
        '             "accountHolderDob":"1986-01-26T00:00:00",' +
        '             "accountState":"Normal",' +
        '             "accountType":"Unsecured Loan",' +
        '             "currentBalance":2124.0,' +
        '             "dateUpdated":"2016-01-07T00:00:00",' +
        '             "creditLimitOverdraft":123,' +
        '             "organisationType":"Finance House",' +
        '             "accountStartDate":"2016-02-12T00:00:00",' +
        '             "accountEndDate":"2016-02-13T00:00:00",' +
        '             "startingBalance":2520.0,' +
        '             "statementBalance":1234,' +
        '             "paymentFrequency":"Monthly",' +
        '             "regularPayment":113.0,' +
        '             "repaymentPeriodPayment":24,' +
        '             "defaulted":true,' +
        '             "defaultDate":"2016-02-05T00:00:00",' +
        '             "originalDefaultBalance":2100.0,' +
        '             "dateDefaultSatisfied":"2016-05-30T00:00:00",' +
        '             "accountHistory":[' +
        '                {' +
        '                   "month":"2016-07",' +
        '                   "currentBalance":2124.0,' +
        '                   "statementBalance":null,' +
        '                   "CreditLimit":null,' +
        '                   "paymentAmount":null,' +
        '                   "numberOfCashAdvances":null,' +
        '                   "valueOfCashAdvances":null' +
        '                },' +
        '                {' +
        '               "month":"2016-06",' +
        '                   "currentBalance":2224.0,' +
        '                   "statementBalance":null,' +
        '                   "CreditLimit":null,' +
        '                   "paymentAmount":null,' +
        '                   "numberOfCashAdvances":null,' +
        '                   "valueOfCashAdvances":null' +
        '                },' +
        '                {' +
        '                   "month":"2016-05",' +
        '                   "currentBalance":2323.0,' +
        '                   "statementBalance":null,' +
        '                   "CreditLimit":null,' +
        '                   "paymentAmount":null,' +
        '                   "numberOfCashAdvances":null,' +
        '                   "valueOfCashAdvances":null' +
        '                },' +
        '                {' +
        '                   "month":"2016-04",' +
        '                   "currentBalance":2422.0,' +
        '                   "statementBalance":null,' +
        '                   "CreditLimit":null,' +
        '                   "paymentAmount":null,' +
        '                   "numberOfCashAdvances":null,' +
        '                   "valueOfCashAdvances":null' +
        '                },' +
        '                {' +
        '                   "month":"2016-03",' +
        '                   "currentBalance":2520.0,' +
        '                   "statementBalance":null,' +
        '                   "CreditLimit":null,' +
        '                   "paymentAmount":null,' +
        '                   "numberOfCashAdvances":null,' +
        '                   "valueOfCashAdvances":null' +
        '                },' +
        '                {' +
        '                   "month":"2016-02",' +
        '                   "currentBalance":2520.0,' +
        '                   "statementBalance":null,' +
        '                   "CreditLimit":null,' +
        '                   "paymentAmount":null,' +
        '                   "numberOfCashAdvances":null,' +
        '                   "valueOfCashAdvances":null' +
        '                }' +
        '             ]' +
        '          }' +
        '       ],' +
        '       "addressLinks":[' +
        '          {' +
        '             "value":"76 Trombones Road, Bristol, BS94EZ"' +
        '          }' +
        '       ],' +
        '       "associateLinks":[' +
        '          {' +
        '             "supplierType":"Bank",' +
        '             "lastConfirmationDate":"2012-10-31T00:00:00",' +
        '             "earliestConfirmationDate":"2012-10-31T00:00:00"' +
        '         }' +
        '       ]' +
        '    }';
        return json;
    }

    public static String getTestEmptyJsonBody() {
        String json = '{' +
        '       "applicantSummary":{' +
        '          "totalBalancesActive":102728.0,' +
        '          "totalBalancesLoans":2663.0,' +
        '          "totalBalancesMortgages":100065.0,' +
        '          "totalBalancesRevolve":null,' +
        '          "totalLimitsRevolve":null,' +
        '          "balanceLimitRatioRevolve":null,' +
        '          "totalValueCashAdvances12Months":null,' +
        '          "totalValueCashAdvances36Months":null,' +
        '          "totalDelinqs12Months":0,' +
        '          "worstPayStatus12Months":"U",' +
        '          "worstPayStatus36Months":"U",' +
        '          "totalDefaults12Months":0,' +
        '          "totalDefaults36Months":0,' +
        '          "currentlyInsolvent":false,' +
        '          "totalDischargedBAIs":0,' +
        '          "totalActiveJudgements":0,' +
        '          "totalSatisfiedJudgements":0,' +
        '          "totalHomeCreditSearches3Months":0' +
        '       },' +
        '       "summaryAddresses":null,' +
        '       "applicantsCurrentAddressElectoralRoll":null,' +
        '       "isIndividualReport":true,' +
        '       "unsettledShareAccounts":null,' +
        '       "settledShareAccounts":null,' +
        '       "addressLinks":null,' +
        '       "associateLinks":null' +
        '    }';
        return json;
        return json;
    }
}