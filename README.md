# istio-blue-green-deployment

# Blue Green Deployment Using ISTIO

##  Install Istio

    1.  curl -L https://git.io/getLatestIstio | sh -
    
    2.  Follow the instructions to add Istio variables on $PATH
    
    3.   for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done

    4.  kubectl apply -f install/kubernetes/istio-demo-auth.yaml
    
    5.  kubectl get svc -n istio-system | grep -i ingress
    
    6.  Change the ingress service from LoadBalancer to NodePort 
    
    7.  kubectl label namespace default istio-injection=enabled --overwrite

    
##  Install Application that will perform action on our dummy deployment

    1.  We have an alpine image that has curl installed. This application can ping our main deployment to simulate request/response
    
    2.  Dockerfile is provided for the app. You can build your own image or just run the below command to run the Pod from my repo. 
    
    3.  kubectl run curlapp --image=harshal0812/curl_app_v1 --port=9090 
    
    4.  The port 9090 is where our demo deployment will run. 
    
    5.  curlapp-98f7c878c-dmckl   2/2     Running   0          9s   --- 2 containers as istio injected envoy proxy
    
    6.  Expose the deployment as NodePort - kubectl expose deployment curlapp --type=NodePort
    
    7.  kubectl get svc
        
        curlapp      NodePort    10.101.22.66   <none>        9090:30974/TCP   27s


##  Install the application deployments 

    1.  There are 3 files in this repo -
    
        a.  ballerina_app_v1.yaml  -- application on Version v1
        
        b.  ballerina_app_v2.yaml  -- application on Version v2 
        
        
    2.  kubectl create -f ballerina_app_v1.yaml -f ballerina_app_v2.yaml
    
    3.  Its important to note the below points - 
    
        a.  There is 1 service with the name version1 that has the selector : type: "myapp"
        
        b.  There are 2 deployments. The pod metadata has the label type: "myapp"
        
        c.  There is one additional label assigned to both the deployment-
             
             app: "ballerina_app_v1"  -- for version1 deployment
             
             app: "ballerina_app_v2"  -- for version2 deployment
             
             The service will not select this label as we have defined the selector as ONLY type: "myapp"
    
    3.  kubectl get pods
        
        ballerinav1deployment-b75859b9b-mrrbs    2/2     Running   0          10m
        
        ballerinav2deployment-5d79454d5d-fsq6l   2/2     Running   0          10m
        
        
    4.  kubectl get svc 
    
        version1     NodePort    10.111.65.134   <none>        9090:31505/TCP   93m

##  Get the Ingress Gateway port 

    export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
    
    Alternatively you can just get the HTTP port using. 
    
    kubectl get svc -n istio-system | grep -i ingressgateway
    
##  Use the curlapp to hit the service 

    kubectl exec -it {{CURL APP POD NAME}} -c {{CURL APP CONTAINER}} -- curl {{SERVICE_IP}}:9090/v1/sayHello
    
    outputs - 
    
    Hello, This is the output of application on Version V1 ! ---coming from deployment1

    Hello, This is the output of application on Version V2!  ---coming from deployment2 


##  Create Istio Gateway / VirtualService / destinationrule

    1.  You will find the corresponding files in this repository
    
    2.  Edit the files and match the host field with the name of the service you exposed for deployment
    
    3.  kubectl apply -f gateway.yaml -f destinationrule.yaml -f virtualservice.yaml 
    
        gateway.yaml - This is the default gateway that maps to IngressGateway
        
        destinationrule.yaml - This defines the subset for both the deployments. 
            
            Things to note -
            
            This rule defines what happens after routing has taken place from the service. 
            
            Subset v1 - points to app: ballerina_app_v1
            
            Subset v2 - points to app: ballerina_app_v2 
            
            Once routing occours - the traffic will be routed to the pods that matches any one of the above labels 
            
        virtualservice.yaml - This defines the routing rules and the corresponding destinations. 
            
            The weight resource determines the percentage of traffic that will be routed to the subset. 
    
    4.  Since our ingress gateway is nodeport - you can use ip address of any host within your cluster to access the app
    
    5.  curl {{MASTER_IP_ADDRESS}}:${INGRESS_PORT}/v1/sayHello 
    
    6.  In the virtualservice.yaml - change the weight to perform blue-green / Canary deployments 
   


    
    
    
    
    
    
