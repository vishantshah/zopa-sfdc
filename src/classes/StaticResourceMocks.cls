@isTest
public with sharing class StaticResourceMocks {
    private List<StaticResource> StaticResourceMocksList;
    static private StaticResourceMocks Self;

    static public StaticResourceMocks getInstance(){
        if(Self == null){
            Self = new StaticResourceMocks();
        }
        return Self;
    }

    private StaticResourceMocks(){
        StaticResourceMocksList = new List<StaticResource>();
    }

    public StaticResource getStaticResourceMock(String resource_name){
        for(StaticResource static_resource_mock : StaticResourceMocksList){
            if(static_resource_mock.Name == resource_name){
                return static_resource_mock;
            }
        }
        System.assert(false, 'There is no mock set, please set your mock using addStaticResourceMock() first before calling the method');
        return null;
    }

    public void addStaticResourceMock(StaticResource static_resource_mock){
        StaticResourceMocksList.add(static_resource_mock);
    }
}