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

## Examining a cluster

``` shell
kops get cluster
kops validate cluster
kubectl get node
kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.4 --port=8080
kubectl expose deployment hello-minikube --type=NodePort
kubectl get services
```

* validate cluster: kops validate cluster
* list nodes: kubectl get nodes --show-labels
* ssh to the master: ssh -i ~/.ssh/id_rsa admin@api.simple.k8s.local
* the admin user is specific to Debian. If not using Debian please use the appropriate user based on your OS.
* read about installing addons at: <https://github.com/kubernetes/kops/blob/master/docs/addons.md>.
