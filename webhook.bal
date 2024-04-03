import ballerinax/trigger.asgardeo;
import ballerina/http;
import ballerina/log;

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

# Client ID and Client Secret to connect to the SubMngr API
configurable string _clientId = ?;
configurable string _clientSecret = ?;
configurable string _tokenUrl = ?;
configurable string _endUrl = ?;

type User record {|
     string userName;
     int allowAccess;
     string? endSub?;
|};

service asgardeo:RegistrationService on webhookListener {
  
    remote function onAddUser(asgardeo:AddUserEvent event ) returns error? {
      log:printInfo(event.toJsonString());

      json __user = event.toJson();
      
      string method  = check __user.eventData.userOnboardMethod;
      if(method=="SELF_SIGNUP")
      { 
           string userNameStr  = check __user.eventData.userName;
           http:Client http_Client = check new (_endUrl, 
             auth = {
                     tokenUrl: _tokenUrl,
                     clientId: _clientId,
                     clientSecret: _clientSecret
             });

             anydata|http:ClientError unionResult = check http_Client->/user.post({
                 userName: userNameStr,
                 allowAccess: 0
             });
      }    
    }
    
    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {
      log:printInfo(event.toJsonString());
    }
    remote function onAcceptUserInvite(asgardeo:GenericEvent event ) returns error? {
      log:printInfo(event.toJsonString());
    }
}

service /ignore on httpListener {}
