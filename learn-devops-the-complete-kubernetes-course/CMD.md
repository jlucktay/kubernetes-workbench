# Learn DevOps: The Complete Kubernetes Course

## Using `minikube` to deploy an image locally

``` shell
minikube start
minikube status
kubectl cluster-info
cat ~/.kube/config
kubectl run hello-minikube --image=gcr.io/google_containers/echoserver:1.4 --port=8080
kubectl expose deployment hello-minikube --type=NodePort
minikube service hello-minikube --url
minikube stop
```