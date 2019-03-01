# istio-blue-green-deployment

# Blue Green Deployment Using ISTIO

##  Install Istio

    1.  curl -L https://git.io/getLatestIstio | sh -
    
    2.  Follow the instructions to add Istio variables on $PATH
    
    3.  kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
    
    4.  kubectl apply -f install/kubernetes/istio-demo-auth.yaml
    
    5.  kubectl get svc -n istio-system | grep -i ingress
    
    6.  Change the ingress service from LoadBalancer to NodePort 
    
    7.  kubectl label namespace default istio-injection=enabled --overwrite

    
##  Install Application that will perform action on our dummy deployment

    1.  We have an alpine image that has curl installed. This application can ping our main deployment to simulate request/response
    
    2.  Dockerfile is provided for the app. You can build your own image or just run the below command to run the Pod from my repo. 
    
    3.  kubectl run curlapp --image=harshal0812/curlapp:latest --port=9090 
    
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
    
    3.  kubectl get pods
        
        ballerinav1deployment-b75859b9b-mrrbs    2/2     Running   0          10m
        
        ballerinav2deployment-5d79454d5d-fsq6l   2/2     Running   0          10m

    4.  Expose any one pod - kubectl expose pod ballerinav1deployment-b75859b9b-mrrbs --type=NodePort
    
    5.  Edit the service to incorporate both deployments -
        
        kubectl edit svc ballerinav1deployment-b75859b9b-mrrbs
        
        Remove the below from labels and selectors- 
        
        pod-template-hash: b75859b9b
        
        version: v1
        
        
    
    6.  Send request from curlapp to our application service myapp
    
    7.  As a part of our application - The request should be sent to /api/apiPayload to get a response
    
    8.  kubectl exec -it  curlapp-98f7c878c-dmckl -c curlapp -- curl  http://ballerinav1deployment-b75859b9b-mrrbs:9090/api/apiPayload
    
        Hello, This is the output of application on Version V1 ! 
        
        Hello, This is the output of application on Version V2 ! 

##  Create Istio Gateway / VirtualService / destinationrule

    1.  You will find the corresponding files in this repository
    
    2.  Edit the files and match the host field with the name of the service you exposed for deployment
    
    3.  kubectl apply -f gateway.yaml -f destinationrule.yaml -f virtualservice.yaml 
    
    4.  Get the ingress port - 
    
        export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
        
    5.  Run a loop on one terminal
      


    
    
    
    
    
    
