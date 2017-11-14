global class ApiLoanInfoTestMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Boolean EmptyResponse;

    global ApiLoanInfoTestMock(Boolean is_success) {
        this(is_success, false);
    }

    global ApiLoanInfoTestMock() {
        this(true, false);
    }

    global ApiLoanInfoTestMock(Boolean is_success, Boolean empty_response) {
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
        String json = '{'+
        '  "bankDetails": {'+
        '    "bankName": "Barclays",'+
        '    "accountHolderName": "John Smith",'+
        '    "accountNumber": "60555123",'+
        '    "sortCode": "10-20-30"'+
        '  },'+
        '  "callValidateBankDetails": {'+
        '    "matchLevel": "Bank Account Valid"'+
        '  },'+
        '  "addressHistory": ['+
        '    {'+
        '      "address": "123 Letsbe Avenue, London, SW84DA",'+
        '      "arrivedDate": "2016-03-03T00:00:00+00:00",'+
        '      "monthsAtAddress": 8'+
        '    },'+
        '    {'+
        '      "address": "76 Trombones Road, Bristol, BS94EZ",'+
        '      "arrivedDate": "2013-11-03T00:00:00+00:00",'+
        '      "monthsAtAddress": 28'+
        '    }'+
        '  ],'+
        '  "employment": {'+
        '    "currentEmployer": {'+
        '      "jobTitle": "Programmer",'+
        '      "name": "MegaCorp",'+
        '      "address": "Mega Plaze, London",'+
        '      "postCode": "EC1A 1AA",'+
        '      "telephone": "020 77554654",'+
        '      "monthsAtEmployer": 5,'+
        '      "contactInfo": "Some Manager"'+
        '    },'+
        '    "previousEmployer": {'+
        '      "jobTitle": "Programmer",'+
        '      "name": "SmallerCorp",'+
        '      "address": "Hoxton Square, London",'+
        '      "postCode": "N1 6NU",'+
        '      "telephone": "020 7222222",'+
        '      "monthsAtEmployer": 20,'+
        '      "contactInfo": "Some Manager"'+
        '    }'+
        '  },'+
        '  "affordability": {'+
        '    "declaredAnnualIncome": 35000,'+
        '    "confirmedAnnualIncome": 30000,'+
        '    "incomeCheckResult": "PASS",'+
        '    "additionalIncome": 560,'+
        '    "monthlyNetIncome": 2000,'+
        '    "rollingCreditLines": ['+
        '      {'+
        '        "companyClass": "CommunicationsSupplier",'+
        '        "accountType": "CommunicationsSupplier",'+
        '        "source": "Equifax",'+
        '        "total": 580.50,'+
        '        "monthly": 70.1'+
        '      },'+
        '      {'+
        '        "companyClass": "CommunicationSupplier",'+
        '        "accountType": "CommunicationsSupplier",'+
        '        "source": "Underwriter",'+
        '        "total": 530.50,'+
        '        "monthly": 70.1'+
        '      }'+
        '    ],'+
        '    "unsecuredDebts": ['+
        '      {'+
        '        "companyClass": "CommunicationSupplier",'+
        '        "accountType": "CommunicationsSupplier",'+
        '        "source": "Underwriter",'+
        '        "total": 230.50,'+
        '        "monthly": 70.1'+
        '      },'+
        '      {'+
        '        "companyClass": "CommunicationSupplier",'+
        '        "accountType": "CommunicationsSupplier",'+
        '        "source": "Equifax",'+
        '        "total": 230.50,'+
        '        "monthly": 70.1'+
        '      }'+
        '    ],'+
        '    "totalMonthlyRepaymentAmount": 40,'+
        '    "totalUnsecuredDebtAmount": 700,'+
        '    "disposableIncome": 122,'+
        '    "DebtToIncome": 111,'+
        '    "LowDebtToIncome": 100,'+
        '    "RentMortgage": 670,'+
        '    "mortgage": 1670,'+
        '    "ConfirmedRentMortgage": 270'+
        '  },'+
        '  "ZopaLoanHistory": ['+
        '    {'+
        '      "LoanId": "12345-123123-213123-12322",'+
        '      "PaymentHistory": ['+
        '        {'+
        '           "repaymentDate": "2016-10-04T00:00:00+01:00",'+
        '           "type": "Regular",'+
        '           "amount": 250,'+
        '           "status": "Paid"'+
        '        }'+
        '      ]'+
        '    }'+
        '  ],'+
        '  "ccJs": ['+
        '    {'+
        '      "address": "123 my street, some town, PO5 4CD",'+
        '      "ccJs": ['+
        '        {'+
        '          "name": "John Smith",'+
        '          "dateOfBirth": "1970-01-01T00:00:00",'+
        '          "value": 123,'+
        '          "courtDate": "2014-02-03T00:00:00",'+
        '          "satisfiedDate": "2015-05-05T00:00:00"'+
        '        }'+
        '      ]'+
        '    }'+
        '  ],'+
        '  "cifas": ['+
        '    {'+
        '      "address": "123 my street, some town, PO5 4CD",'+
        '      "cifasItems": ['+
        '        {'+
        '          "name": "John Smith",'+
        '          "dateOfBirth": "1970-01-01T00:00:00",'+
        '          "fraudDate": "2012-02-03T00:00:00",'+
        '          "caseNumber": "356654",'+
        '          "category": "Protective Registration",'+
        '          "supplyingMember": "Some Member",'+
        '          "referenceText": "SOme text"'+
        '        }'+
        '      ]'+
        '    }'+
        '  ],'+
        '  "electoralRollAddresses": ['+
        '    {'+
        '      "address": "123 my street, some town, PO5 4CD",'+
        '      "electoralEnrollments": ['+
        '        {'+
        '          "VotersName": "John Doe",'+
        '          "Period": "71-10",'+
        '          "IsApplicant": true'+
        '        }'+
        '      ]'+
        '    }'+
        '  ],'+
        '  "telephoneMatchAddresses": ['+
        '    {'+
        '      "address": "123 my street, some town, PO5 4CD",'+
        '      "TelephoneMatches": ['+
        '        {'+
        '          "name": "Nate Denver",'+
        '          "TelephoneNumber": "880094485"'+
        '        }'+
        '      ]'+
        '    }'+
        '  ]'+
        '}';

        return json;
    }

    public static String getTestEmptyJsonBody() {
        String json = '{'+
        '  "bankDetails": {},'+
        '  "callValidateBankDetails": {},'+
        '  "addressHistory": [],'+
        '  "employment": {},'+
        '  "affordability": {},'+
        '  "ZopaLoanHistory": [],'+
        '  "ccJs": [],'+
        '  "cifas": []'+
        '}';

        return json;
    }
}