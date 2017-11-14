@isTest
public class ScheduleUpdateZopaOAuthTest {

    static testMethod void getOAuthTokenSuccessWithoutCustomSettingsUnderwriting(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            OAuthZopaTestMock.setResponseResult('success');

            Test.startTest();
                ScheduleUpdateZopaOAuth test_sc = new ScheduleUpdateZopaOAuth();
                test_sc.execute(null);
            Test.stopTest();

            String token = ScheduleUpdateZopaOAuth.TokenUnderwriting;
            String expected_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSIsImtpZCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSJ9.eyJpc3MiOiJodHRwczovL2lkZW50aXR5LnNhbmRib3guem9waWFuLmFkLnpvcGEuY29tIiwiYXVkIjoiaHR0cHM6Ly9pZGVudGl0eS5zYW5kYm94LnpvcGlhbi5hZC56b3BhLmNvbS9yZXNvdXJjZXMiLCJleHAiOjE0ODEwNjc1MTYsIm5iZiI6MTQ4MTA2MzkxNiwiY2xpZW50X2lkIjoiY2xpZW50Y3JlZGVudGlhbHMuY2xpZW50IiwiY2xpZW50X2xvY2F0aW9uIjoiZGF0YWNlbnRlciIsInNjb3BlIjoid3JpdGUifQ.D-RWFobxNm4ki9Ynreomqiw65DRfd-ADn93lT8GZuXzmEXm5rraf57tSne9jYUjayGMzU8v7z1z6YYRcl8ofSLnBzVw2_n94GtIcxc7WqjUwa5nBa7thRzZa1WcYP3VYDEAccb1jJe7yu52U-txXeRVSg_p9g0RHT6pCQrzrDlvKTdXVvGdiGyjpVNu0IZozHVSC1UgNZGuvW3V9Fa3nUl-dyPKQN8RV2v3_B5BeltfQrymRTM2_zGah1qzhuLyIJ_RkpU876lkYpx3e89qIq8UwIMRhemRiLTcG1AnwtFpNn9fEH1cfYs7NmCUNVuWQlqqP4emtPVUx2e8Vo_bXHQ';
            System.assertEquals(expected_token, token, 'Didn\'t get the OAuth expected token');
            Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
            String expected_token1 = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSIsImtpZCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSJ9.eyJpc3MiOiJodHRwczovL2lkZW50aXR5LnNhbmRib3guem9waWFuLmFkLnpvcGEuY29tIiwiYXVkIjoiaHR0cHM6Ly9pZGVudGl0eS5zYW5kYm94LnpvcGlhbi';
            System.assertEquals(expected_token1, api_setting.Access_Token1__c, 'Didnt store the token is custom settings');
            String expected_token2 = '5hZC56b3BhLmNvbS9yZXNvdXJjZXMiLCJleHAiOjE0ODEwNjc1MTYsIm5iZiI6MTQ4MTA2MzkxNiwiY2xpZW50X2lkIjoiY2xpZW50Y3JlZGVudGlhbHMuY2xpZW50IiwiY2xpZW50X2xvY2F0aW9uIjoiZGF0YWNlbnRlciIsInNjb3BlIjoid3JpdGUifQ.D-RWFobxNm4ki9Ynreomqiw65DRfd-ADn93lT8GZuXzmEXm5rraf57tSne9jYU';
            System.assertEquals(expected_token2, api_setting.Access_Token2__c, 'Didnt store the token is custom settings');
            String expected_token3 = 'jayGMzU8v7z1z6YYRcl8ofSLnBzVw2_n94GtIcxc7WqjUwa5nBa7thRzZa1WcYP3VYDEAccb1jJe7yu52U-txXeRVSg_p9g0RHT6pCQrzrDlvKTdXVvGdiGyjpVNu0IZozHVSC1UgNZGuvW3V9Fa3nUl-dyPKQN8RV2v3_B5BeltfQrymRTM2_zGah1qzhuLyIJ_RkpU876lkYpx3e89qIq8UwIMRhemRiLTcG1AnwtFpNn9fEH1cfYs7NmCUNV';
            System.assertEquals(expected_token3, api_setting.Access_Token3__c, 'Didnt store the token is custom settings');
            String expected_token4 = 'uWQlqqP4emtPVUx2e8Vo_bXHQ';
            System.assertEquals(expected_token4, api_setting.Access_Token4__c, 'Didnt store the token is custom settings');
            System.assertNotEquals(null, api_setting.Access_Token_Expiry_Date__c, 'Didnt store the token expiry is custom settings');
            System.assertEquals(true, DateTime.now().addSeconds(2880) < api_setting.Access_Token_Expiry_Date__c, 'Token expiry is greater than 48 minutes.');
            System.assertEquals(true, api_setting.Access_Token_Expiry_Date__c < DateTime.now().addSeconds(3000), 'Token expiry is lower than 50 minutes.');
            System.assert(OAuthZopaTestMock.CalloutMade, 'Callout should have been made');
        }
    }

    static testMethod void getOAuthTokenWithCustomSettingsUpdateUnderwriting(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            OAuthZopaTestMock.setResponseResult('success');
            setup_data.updateOAuthCustomSettings(true);

            Test.startTest();
                ScheduleUpdateZopaOAuth test_sc = new ScheduleUpdateZopaOAuth();
                test_sc.execute(null);
            Test.stopTest();

            String token = ScheduleUpdateZopaOAuth.TokenUnderwriting;
            String expected_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSIsImtpZCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSJ9.eyJpc3MiOiJodHRwczovL2lkZW50aXR5LnNhbmRib3guem9waWFuLmFkLnpvcGEuY29tIiwiYXVkIjoiaHR0cHM6Ly9pZGVudGl0eS5zYW5kYm94LnpvcGlhbi5hZC56b3BhLmNvbS9yZXNvdXJjZXMiLCJleHAiOjE0ODEwNjc1MTYsIm5iZiI6MTQ4MTA2MzkxNiwiY2xpZW50X2lkIjoiY2xpZW50Y3JlZGVudGlhbHMuY2xpZW50IiwiY2xpZW50X2xvY2F0aW9uIjoiZGF0YWNlbnRlciIsInNjb3BlIjoid3JpdGUifQ.D-RWFobxNm4ki9Ynreomqiw65DRfd-ADn93lT8GZuXzmEXm5rraf57tSne9jYUjayGMzU8v7z1z6YYRcl8ofSLnBzVw2_n94GtIcxc7WqjUwa5nBa7thRzZa1WcYP3VYDEAccb1jJe7yu52U-txXeRVSg_p9g0RHT6pCQrzrDlvKTdXVvGdiGyjpVNu0IZozHVSC1UgNZGuvW3V9Fa3nUl-dyPKQN8RV2v3_B5BeltfQrymRTM2_zGah1qzhuLyIJ_RkpU876lkYpx3e89qIq8UwIMRhemRiLTcG1AnwtFpNn9fEH1cfYs7NmCUNVuWQlqqP4emtPVUx2e8Vo_bXHQ';
            System.assertEquals(expected_token, token, 'Didn\'t get the OAuth expected token');
            Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
            String expected_token1 = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSIsImtpZCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSJ9.eyJpc3MiOiJodHRwczovL2lkZW50aXR5LnNhbmRib3guem9waWFuLmFkLnpvcGEuY29tIiwiYXVkIjoiaHR0cHM6Ly9pZGVudGl0eS5zYW5kYm94LnpvcGlhbi';
            System.assertEquals(expected_token1, api_setting.Access_Token1__c, 'Didnt store the token is custom settings');
            String expected_token2 = '5hZC56b3BhLmNvbS9yZXNvdXJjZXMiLCJleHAiOjE0ODEwNjc1MTYsIm5iZiI6MTQ4MTA2MzkxNiwiY2xpZW50X2lkIjoiY2xpZW50Y3JlZGVudGlhbHMuY2xpZW50IiwiY2xpZW50X2xvY2F0aW9uIjoiZGF0YWNlbnRlciIsInNjb3BlIjoid3JpdGUifQ.D-RWFobxNm4ki9Ynreomqiw65DRfd-ADn93lT8GZuXzmEXm5rraf57tSne9jYU';
            System.assertEquals(expected_token2, api_setting.Access_Token2__c, 'Didnt store the token is custom settings');
            String expected_token3 = 'jayGMzU8v7z1z6YYRcl8ofSLnBzVw2_n94GtIcxc7WqjUwa5nBa7thRzZa1WcYP3VYDEAccb1jJe7yu52U-txXeRVSg_p9g0RHT6pCQrzrDlvKTdXVvGdiGyjpVNu0IZozHVSC1UgNZGuvW3V9Fa3nUl-dyPKQN8RV2v3_B5BeltfQrymRTM2_zGah1qzhuLyIJ_RkpU876lkYpx3e89qIq8UwIMRhemRiLTcG1AnwtFpNn9fEH1cfYs7NmCUNV';
            System.assertEquals(expected_token3, api_setting.Access_Token3__c, 'Didnt store the token is custom settings');
            String expected_token4 = 'uWQlqqP4emtPVUx2e8Vo_bXHQ';
            System.assertEquals(expected_token4, api_setting.Access_Token4__c, 'Didnt store the token is custom settings');
            System.assertNotEquals(null, api_setting.Access_Token_Expiry_Date__c, 'Didnt store the token expiry is custom settings');
            System.assertEquals(true, DateTime.now().addSeconds(2880) < api_setting.Access_Token_Expiry_Date__c, 'Token expiry is greater than 48 minutes.');
            System.assertEquals(true, api_setting.Access_Token_Expiry_Date__c < DateTime.now().addSeconds(3000), 'Token expiry is lower than 50 minutes.');
            System.assert(OAuthZopaTestMock.CalloutMade, 'Callout should have been made');
        }
    }

    static testMethod void getOAuthTokenSuccessWithoutCustomSettingsCollections(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            OAuthZopaTestMock.setResponseResult('success');

            Test.startTest();
                ScheduleUpdateZopaOAuth test_sc = new ScheduleUpdateZopaOAuth();
                test_sc.execute(null);
            Test.stopTest();

            String token = ScheduleUpdateZopaOAuth.TokenCollections;
            String expected_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSIsImtpZCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSJ9.eyJpc3MiOiJodHRwczovL2lkZW50aXR5LnNhbmRib3guem9waWFuLmFkLnpvcGEuY29tIiwiYXVkIjoiaHR0cHM6Ly9pZGVudGl0eS5zYW5kYm94LnpvcGlhbi5hZC56b3BhLmNvbS9yZXNvdXJjZXMiLCJleHAiOjE0ODEwNjc1MTYsIm5iZiI6MTQ4MTA2MzkxNiwiY2xpZW50X2lkIjoiY2xpZW50Y3JlZGVudGlhbHMuY2xpZW50IiwiY2xpZW50X2xvY2F0aW9uIjoiZGF0YWNlbnRlciIsInNjb3BlIjoid3JpdGUifQ.D-RWFobxNm4ki9Ynreomqiw65DRfd-ADn93lT8GZuXzmEXm5rraf57tSne9jYUjayGMzU8v7z1z6YYRcl8ofSLnBzVw2_n94GtIcxc7WqjUwa5nBa7thRzZa1WcYP3VYDEAccb1jJe7yu52U-txXeRVSg_p9g0RHT6pCQrzrDlvKTdXVvGdiGyjpVNu0IZozHVSC1UgNZGuvW3V9Fa3nUl-dyPKQN8RV2v3_B5BeltfQrymRTM2_zGah1qzhuLyIJ_RkpU876lkYpx3e89qIq8UwIMRhemRiLTcG1AnwtFpNn9fEH1cfYs7NmCUNVuWQlqqP4emtPVUx2e8Vo_bXHQ';
            System.assertEquals(expected_token, token, 'Didn\'t get the OAuth expected token');
            Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
            String expected_token1 = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSIsImtpZCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSJ9.eyJpc3MiOiJodHRwczovL2lkZW50aXR5LnNhbmRib3guem9waWFuLmFkLnpvcGEuY29tIiwiYXVkIjoiaHR0cHM6Ly9pZGVudGl0eS5zYW5kYm94LnpvcGlhbi';
            System.assertEquals(expected_token1, api_setting.Access_Token1__c, 'Didnt store the token is custom settings');
            String expected_token2 = '5hZC56b3BhLmNvbS9yZXNvdXJjZXMiLCJleHAiOjE0ODEwNjc1MTYsIm5iZiI6MTQ4MTA2MzkxNiwiY2xpZW50X2lkIjoiY2xpZW50Y3JlZGVudGlhbHMuY2xpZW50IiwiY2xpZW50X2xvY2F0aW9uIjoiZGF0YWNlbnRlciIsInNjb3BlIjoid3JpdGUifQ.D-RWFobxNm4ki9Ynreomqiw65DRfd-ADn93lT8GZuXzmEXm5rraf57tSne9jYU';
            System.assertEquals(expected_token2, api_setting.Access_Token2__c, 'Didnt store the token is custom settings');
            String expected_token3 = 'jayGMzU8v7z1z6YYRcl8ofSLnBzVw2_n94GtIcxc7WqjUwa5nBa7thRzZa1WcYP3VYDEAccb1jJe7yu52U-txXeRVSg_p9g0RHT6pCQrzrDlvKTdXVvGdiGyjpVNu0IZozHVSC1UgNZGuvW3V9Fa3nUl-dyPKQN8RV2v3_B5BeltfQrymRTM2_zGah1qzhuLyIJ_RkpU876lkYpx3e89qIq8UwIMRhemRiLTcG1AnwtFpNn9fEH1cfYs7NmCUNV';
            System.assertEquals(expected_token3, api_setting.Access_Token3__c, 'Didnt store the token is custom settings');
            String expected_token4 = 'uWQlqqP4emtPVUx2e8Vo_bXHQ';
            System.assertEquals(expected_token4, api_setting.Access_Token4__c, 'Didnt store the token is custom settings');
            System.assertNotEquals(null, api_setting.Access_Token_Expiry_Date__c, 'Didnt store the token expiry is custom settings');
            System.assertEquals(true, DateTime.now().addSeconds(2880) < api_setting.Access_Token_Expiry_Date__c, 'Token expiry is greater than 48 minutes.');
            System.assertEquals(true, api_setting.Access_Token_Expiry_Date__c < DateTime.now().addSeconds(3000), 'Token expiry is lower than 50 minutes.');
            System.assert(OAuthZopaTestMock.CalloutMade, 'Callout should have been made');
        }
    }

    static testMethod void getOAuthTokenWithCustomSettingsUpdateCollections(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            OAuthZopaTestMock.setResponseResult('success');
            setup_data.updateOAuthCustomSettings(true);

            Test.startTest();
                ScheduleUpdateZopaOAuth test_sc = new ScheduleUpdateZopaOAuth();
                test_sc.execute(null);
            Test.stopTest();

            String token = ScheduleUpdateZopaOAuth.TokenCollections;
            String expected_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSIsImtpZCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSJ9.eyJpc3MiOiJodHRwczovL2lkZW50aXR5LnNhbmRib3guem9waWFuLmFkLnpvcGEuY29tIiwiYXVkIjoiaHR0cHM6Ly9pZGVudGl0eS5zYW5kYm94LnpvcGlhbi5hZC56b3BhLmNvbS9yZXNvdXJjZXMiLCJleHAiOjE0ODEwNjc1MTYsIm5iZiI6MTQ4MTA2MzkxNiwiY2xpZW50X2lkIjoiY2xpZW50Y3JlZGVudGlhbHMuY2xpZW50IiwiY2xpZW50X2xvY2F0aW9uIjoiZGF0YWNlbnRlciIsInNjb3BlIjoid3JpdGUifQ.D-RWFobxNm4ki9Ynreomqiw65DRfd-ADn93lT8GZuXzmEXm5rraf57tSne9jYUjayGMzU8v7z1z6YYRcl8ofSLnBzVw2_n94GtIcxc7WqjUwa5nBa7thRzZa1WcYP3VYDEAccb1jJe7yu52U-txXeRVSg_p9g0RHT6pCQrzrDlvKTdXVvGdiGyjpVNu0IZozHVSC1UgNZGuvW3V9Fa3nUl-dyPKQN8RV2v3_B5BeltfQrymRTM2_zGah1qzhuLyIJ_RkpU876lkYpx3e89qIq8UwIMRhemRiLTcG1AnwtFpNn9fEH1cfYs7NmCUNVuWQlqqP4emtPVUx2e8Vo_bXHQ';
            System.assertEquals(expected_token, token, 'Didn\'t get the OAuth expected token');
            Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
            String expected_token1 = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSIsImtpZCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSJ9.eyJpc3MiOiJodHRwczovL2lkZW50aXR5LnNhbmRib3guem9waWFuLmFkLnpvcGEuY29tIiwiYXVkIjoiaHR0cHM6Ly9pZGVudGl0eS5zYW5kYm94LnpvcGlhbi';
            System.assertEquals(expected_token1, api_setting.Access_Token1__c, 'Didnt store the token is custom settings');
            String expected_token2 = '5hZC56b3BhLmNvbS9yZXNvdXJjZXMiLCJleHAiOjE0ODEwNjc1MTYsIm5iZiI6MTQ4MTA2MzkxNiwiY2xpZW50X2lkIjoiY2xpZW50Y3JlZGVudGlhbHMuY2xpZW50IiwiY2xpZW50X2xvY2F0aW9uIjoiZGF0YWNlbnRlciIsInNjb3BlIjoid3JpdGUifQ.D-RWFobxNm4ki9Ynreomqiw65DRfd-ADn93lT8GZuXzmEXm5rraf57tSne9jYU';
            System.assertEquals(expected_token2, api_setting.Access_Token2__c, 'Didnt store the token is custom settings');
            String expected_token3 = 'jayGMzU8v7z1z6YYRcl8ofSLnBzVw2_n94GtIcxc7WqjUwa5nBa7thRzZa1WcYP3VYDEAccb1jJe7yu52U-txXeRVSg_p9g0RHT6pCQrzrDlvKTdXVvGdiGyjpVNu0IZozHVSC1UgNZGuvW3V9Fa3nUl-dyPKQN8RV2v3_B5BeltfQrymRTM2_zGah1qzhuLyIJ_RkpU876lkYpx3e89qIq8UwIMRhemRiLTcG1AnwtFpNn9fEH1cfYs7NmCUNV';
            System.assertEquals(expected_token3, api_setting.Access_Token3__c, 'Didnt store the token is custom settings');
            String expected_token4 = 'uWQlqqP4emtPVUx2e8Vo_bXHQ';
            System.assertEquals(expected_token4, api_setting.Access_Token4__c, 'Didnt store the token is custom settings');
            System.assertNotEquals(null, api_setting.Access_Token_Expiry_Date__c, 'Didnt store the token expiry is custom settings');
            System.assertEquals(true, DateTime.now().addSeconds(2880) < api_setting.Access_Token_Expiry_Date__c, 'Token expiry is greater than 48 minutes.');
            System.assertEquals(true, api_setting.Access_Token_Expiry_Date__c < DateTime.now().addSeconds(3000), 'Token expiry is lower than 50 minutes.');
            System.assert(OAuthZopaTestMock.CalloutMade, 'Callout should have been made');
        }
    }

    public class SetupDataClass{
        public User TestUser {get; private set;}

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'OAuthZopaTest' AND LastName = 'OAuthZopaTest' LIMIT 1];
            setOAuthCustomSettings();
        }

        public void setOAuthCustomSettings(){
            Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
            api_setting.OAuth_Client_Id__c = 'test';
            api_setting.OAuth_Client_Id_Collections__c = 'test';
            api_setting.Grant_Type__c = 'test';
            api_setting.Grant_Type_Collections__c = 'test';
            api_setting.OAuth_Client_Secret__c = 'test';
            api_setting.OAuth_Client_Secret_Collections__c = 'test';
            api_setting.Scope__c = 'test';
            api_setting.Scope_Collections__c = 'test';
            TestCustomSettings.saveCustomSettings(api_setting);
        }

        public void updateOAuthCustomSettings(Boolean token_expired){
            Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
            api_setting.Access_Token1__c = 'OiJKV1QiLCJhbGc';
            api_setting.Access_Token2__c = 'BsaWNhdG';
            api_setting.Access_Token3__c = '00YWV';
            api_setting.Access_Token4__c = 'iJKV1QiLCJh';
            if(token_expired){
                api_setting.Access_Token_Expiry_Date__c = DateTime.now().addSeconds(-10);
            } else {
                api_setting.Access_Token_Expiry_Date__c = DateTime.now().addSeconds(10);
            }
            TestCustomSettings.saveCustomSettings(api_setting);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('OAuthZopaTest')
                                     .setLastName('OAuthZopaTest')
                                     .save();
    }
}