import ballerina/http;
import ballerinax/kubernetes;
import ballerina/log;

@kubernetes:Service { 
        serviceType: "NodePort",
        name: "version2"

}
@kubernetes:Deployment {
    singleYAML: true,
    image: "harshal0812/ballerinav2",
    name: "ballerinav2deployment"
}
@http:ServiceConfig {
    basePath: "/v1"
}
service v1 on new http:Listener(9090) {
    resource function sayHello(http:Caller outboundEP, http:Request request) {
        http:Response response = new;
        response.setTextPayload("Hello, This is the output of application on Version V2! \n");
        _ = outboundEP->respond(response);
        
    }
}
