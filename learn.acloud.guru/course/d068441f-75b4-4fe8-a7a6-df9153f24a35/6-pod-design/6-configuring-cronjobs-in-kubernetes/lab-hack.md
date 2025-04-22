# Adding a Name to the Kubernetes API Server Certificate

From [here](https://blog.scottlowe.org/2019/07/30/adding-a-name-to-kubernetes-api-server-certificate/) and
[here](https://blog.scottlowe.org/2020/06/16/using-kubectl-via-an-ssh-tunnel/).

As `root`:

```shell
mv -iv /etc/kubernetes/pki/apiserver.{crt,key} .
kubeadm init phase certs apiserver --config kubeadm.yaml
docker ps | grep kube-apiserver | grep -v pause | awk '{ print $1 }' | xargs -n 1 docker kill
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text
kubeadm config upload from-file --config kubeadm.yaml
```

As `cloud_user`:

```shell
sudo su
kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' > kubeadm.yaml
nano kubeadm.yaml
sudo su
kubectl -n kube-system get configmap kubeadm-config -o yaml
sudo su
```

`ssh -fNT -L 16443:3.238.105.231:6443 cloud_user@3.238.105.231`
