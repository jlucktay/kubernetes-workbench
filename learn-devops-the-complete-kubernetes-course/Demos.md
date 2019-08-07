# Learn DevOps: The Complete Kubernetes Course

Learnings from each demo, in ten words or less.

## 08. Demo: Minikube

Local mini-cluster for development on own machine.

## 12. Demo: Preparing kops install

`kops` is `kubectl` for clusters.

## 13. Demo: Preparing AWS for kops install

`kops` has 1st-class support for AWS.

## 14. Demo: DNS Troubleshooting (Optional)

## 15. Demo: Cluster setup on AWS using kops

## 17. Demo: Building docker images

## 19. Demo: Pushing Docker Image

## 21. Demo: Running first app on Kubernetes

## 22. Demo: Useful commands

## 24. Demo: Service with AWS ELB LoadBalancer

## 28. Demo: Replication Controller

Makes sure a set number of pods are always running.

## 30. Demo: Deployments

Declarative updates for Pods and ReplicaSets.

## 32. Demo: Services

Bridge between front-end and back-end pods.

## 34. Demo: NodeSelector using Labels

Define criteria so that pods get scheduled on specific nodes.

## 36. Demo: Healthchecks

Check if something is ready to work.

## 38. Demo: Liveness and Readiness probe

Liveness: keep or kill?

Readiness: container is ready to receive traffic.

## 41. Demo: Pod Lifecycle

1. init container
1. post-init
    1. post start hook
    1. main container
1. probes
    1. readiness probe
    1. liveness probe
1. pre stop hook

## 43. Demo: Credentials using Volumes

## 44. Demo: Running Wordpress on Kubernetes

## 46. Demo: Web UI in Kops

## 47. Demo: WebUI

## 49. Demo: Service Discovery

## 51. Demo: ConfigMap

Map file contents through as key-value pairs.

## 53. Demo: Ingress Controller

## 55. Demo: External DNS

## 57. Demo: Volumes

## 59. Demo: Wordpress With Volumes

## 61. Demo: Pod Presets

Add boilerplate to all pods.

## 63. Demo: StatefulSets

Maintain pod IDs between teardowns/startups.

## 66. Demo: Resource Monitoring using Metrics Server

Run `kubectl top` on your nodes and pods.

## 67. Demo: Resource Usage Monitoring

Heapster retiring, Metrics Server incubating, need metrics for autoscaling.

## 68. Autoscaling

HorizontalPodAutoscaler target utilisation relative to initial deployment.

## 69. Demo: Autoscaling

HPA creates/destroys pods to meet target utilisation.

## 70. Affinity / Anti-Affinity

Node affinity resembles NodeSelector.

Pod (anti)affinity observes currently running pods.

## 71. Demo: Affinity / Anti-Affinity

Affinity is only observed when scheduling.

Destroy/recreate pods to reschedule accordingly.

## 72. Interpod Affinity and Anti-Affinity

For example, co-located: app+Redis, or same AZ.

Topology key (e.g. hostname, zone) describes selection axis.

## 73. Demo: Interpod Affinity

With `topologyKey: "kubernetes.io/hostname"`, scaling will run up pods on same node:

``` bash
$ kubectl get pods -o wide
NAME                              READY   STATUS              RESTARTS   AGE    IP           NODE
pod-affinity-1-596fbf7bf-mllsz    1/1     Running             0          109s   100.96.2.5   ip-172-20-35-107.eu-west-2.compute.internal
pod-affinity-2-789558cc6f-2665g   1/1     Running             0          5s     100.96.2.8   ip-172-20-35-107.eu-west-2.compute.internal
pod-affinity-2-789558cc6f-ptnxh   1/1     Running             0          109s   100.96.2.6   ip-172-20-35-107.eu-west-2.compute.internal
pod-affinity-2-789558cc6f-skxrz   1/1     Running             0          5s     100.96.2.7   ip-172-20-35-107.eu-west-2.compute.internal
pod-affinity-2-789558cc6f-w76t2   0/1     ContainerCreating   0          5s     <none>       ip-172-20-35-107.eu-west-2.compute.internal
```

## 74. Demo: Interpod Anti-Affinity

`requiredDuringSchedulingIgnoredDuringExecution` vs `preferredDuringSchedulingIgnoredDuringExecution`

Hard vs soft constraint.

## 75. Taints and Tolerations

`NoSchedule`: hard requirement
`PreferNoSchedule`: soft requirement
`NoExecute`: evicts running pods

## 76. Demo: Taints and Tolerations

'Tolerate' will put up with specified taints.

See also `k8staints` Bash func.

## 77. Custom Resource Definitions (CRDs)

Roll your own K8s resource types.

## 78. Operators

BYO logic/functionality for dealing with CRDs.

## 79. Demo: postgresql-operator

Very big and crunchy; bears revisiting!

## Quiz 1

### Question 1

> In regards to Service Discovery, what makes "curl service1" work (service1 is the name of a Service object)?

The /etc/resolv.conf file is modified to make sure all DNS lookups go to an internal DNS server.

_This was discussed in Lecture 48: Service Discovery_.

### Question 2

> You want to make a config file available within your container. You don't want to rebuild the image to change the
config file, what do you use?

The ConfigMap object is the best way to provide a config file to a container, without having to rebuild the app to see
new configuration files.

### Question 3

> What is one of the benefits of an ingress controller on the cloud?

With an ingress controller you can potentially save costs. Rather than using 1 LoadBalancer per public application, you
can use the ingress controller as a gateway for all your public apps, and only use 1 LoadBalancer in front of the
ingress-controller.

_This was discussed in Lecture 52: Ingress Controller_.

### Question 4

> You have a Kubernetes cluster within a single availability zone on AWS. The pod "app1" has a persistent volume (AWS
> EBS) attached. The pod get killed, what happens with the data in the persistent volume?

If the cluster is within the same availability zone, the pods with a PV will be able to reschedule on any node.

### Question 5

> You have a Kubernetes cluster within multiple availability zones on AWS. The pod "app1" has a persistent volume (AWS
> EBS) attached. The pod get killed, what happens with the data in the persistent volume?

If the cluster is within the same availability zone, the pods with a PV will be able to reschedule on a node within the
same availability zone.

### Question 6

> You have pod anti-affinity configured with preferredDuringSchedulingIgnoredDuringExecution. The rule doesn't match,
> what happens?

With preferred, the pod will always be scheduled, even if the rules don't match.

### Question 7

> You want to make sure that 2 pods are never scheduled on the same node, what options do you choose?

Anti-affinity makes sure that a pod is not scheduled next to another pod. the required rule makes sure that when the
rule doesn't match, the pod is not scheduled at all
