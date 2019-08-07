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

* list clusters with: kops get cluster
* edit this cluster with: kops edit cluster simple.k8s.local
* edit your node instance group: kops edit ig --name=simple.k8s.local nodes
* edit your master instance group: kops edit ig --name=simple.k8s.local master-europe-west2-c

* validate cluster: kops validate cluster
* list nodes: kubectl get nodes --show-labels
* ssh to the master: ssh -i ~/.ssh/id_rsa admin@api.simple.k8s.local
* the admin user is specific to Debian. If not using Debian please use the appropriate user based on your OS.
* read about installing addons at: <https://github.com/kubernetes/kops/blob/master/docs/addons.md>.

## Checking defaults with `edit` when not specified in YAML file(s)

Use `kubectl` to create with `-f <file>` and then `kubectl edit <resource>` to see all values, both implicit and explicit, which lays out defaults that were not specified in YAML.

## Pod lifecycle

1. init container
1. post-init
    1. post start hook
    1. main container
1. probes
    1. readiness probe
    1. liveness probe
1. pre stop hook

## Snippets

### Get logs from a pod

``` bash
kubectl logs wordpress-db-2p8hz
```

### Scale one or more replica sets/controllers (or basically any other type of resource)

``` bash
kubectl scale --replicas=4 deployment pod-affinity-2
```

### Taint/untaint a node so that new deployments stop/resume scheduling onto it

``` bash
# Taint/stop
kubectl taint nodes ip-172-20-35-107.eu-west-2.compute.internal type=specialnode:NoSchedule

# Untaint/resume
kubectl taint node ip-172-20-35-107.eu-west-2.compute.internal type-
```

### Expose a Deployment using a Service

``` bash
kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080
```
