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

    

##  Install the application deployments 

    1.  There are 3 files in this repo -
    
        a.  app1.yaml  -- application on Version v1
        
        b.  app2.yaml  -- application on Version v2 
        
        
    2.  kubectl create -f app1.yaml -f app2.yaml
    
    3.  kubectl create -f service.yaml
    
    3.  kubectl get pods 
        NAME                          READY   STATUS    RESTARTS   AGE
        nginx-app1-7fb695b558-2jg7b   2/2     Running   0          7m2s
        nginx-app1-7fb695b558-2wldm   2/2     Running   0          7m2s
        nginx-app1-7fb695b558-7kzwl   2/2     Running   0          7m2s
        nginx-app2-564f858694-g6h2z   2/2     Running   0          7m2s
        nginx-app2-564f858694-jn4g7   2/2     Running   0          7m2s
        nginx-app2-564f858694-mdrxb   2/2     Running   0          7m1s
        
        
    4.  kubectl get svc
        NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
        appservice   ClusterIP   10.104.184.47   <none>        80/TCP    7m4s

##  Get the Ingress Gateway port 

    export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
    
    Alternatively you can just get the HTTP port using. 
    
    kubectl get svc -n istio-system | grep -i ingressgateway
    



##  Create Istio Gateway / VirtualService / destinationrule

    1.  You will find the corresponding files in this repository
    
    2.  Edit the files and match the host field with the name of the service you exposed for deployment
    
    3.  kubectl apply -f gateway.yaml -f destinationrule.yaml -f virtualservice.yaml 
    
        gateway.yaml - This is the default gateway that maps to IngressGateway
        
        destinationrule.yaml - This defines the subset for both the deployments. 
            
            Things to note -
            
            This rule defines what happens after routing has taken place from the service. 
            
            Subset v1 - points to app1
            
            Subset v2 - points to app2
            
            Once routing occours - the traffic will be routed to the pods that matches any one of the above labels 
            
        virtualservice.yaml - This defines the routing rules and the corresponding destinations. 
            
            The weight resource determines the percentage of traffic that will be routed to the subset. 
    
    4.  Since our ingress gateway is nodeport - you can use ip address of any host within your cluster to access the app
    
    5.  curl {{MASTER_IP_ADDRESS}}:${INGRESS_PORT}/app
    
    6.  In the virtualservice.yaml - change the weight to perform blue-green / Canary deployments 
   


    
    
    
    
    
    
