# StatefulSet Basics

Following along with [this article](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/) with some fixes and adaptations from [this article](https://medium.com/@raj.ranjan.sinha/understanding-kubernetes-statefulsets-with-a-hands-on-example-51572df8b98f).

## Console log

```shell
kubectl apply --filename=statefulset.nginx-parallel.yaml

for i in $(seq 0 4); do kubectl exec "nginx-parallel-$i" -- sh -c 'echo "$(hostname)" > /usr/share/nginx/html/index.html'; done

for i in $(seq 0 4); do kubectl exec -i -t "nginx-parallel-$i" -- curl http://localhost/; done

kubectl delete sts nginx-parallel
kubectl delete svc nginx-parallel
kubectl delete pvc --all
```
