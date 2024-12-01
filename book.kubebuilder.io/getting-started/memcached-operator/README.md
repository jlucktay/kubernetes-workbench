# Sample project

From [here](https://book.kubebuilder.io/getting-started).

## Command history

```shell
mkdir -pv book.kubebuilder.io/getting-started/memcached-operator
cd book.kubebuilder.io/getting-started/memcached-operator
kubebuilder init --domain=example.com --repo=go.jlucktay.dev/kubernetes-workbench/book.kubebuilder.io/getting-started/memcached-operator
kubebuilder create api --group cache --version v1alpha1 --kind Memcached
make generate
```
