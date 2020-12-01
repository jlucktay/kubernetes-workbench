#!/usr/bin/env bash

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

for instance in worker-0 worker-1 worker-2; do
  cat > "$instance"-csr.json << EOF
{
    "CN": "system:node:${instance}",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "US",
            "L": "Portland",
            "O": "system:nodes",
            "OU": "Kubernetes The Hard Way",
            "ST": "Oregon"
        }
    ]
}
EOF

  EXTERNAL_IP=$(gcloud compute instances describe "$instance" \
    --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

  INTERNAL_IP=$(gcloud compute instances describe "$instance" \
    --format 'value(networkInterfaces[0].networkIP)')

  cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -hostname="$instance,$EXTERNAL_IP,$INTERNAL_IP" \
    -profile=kubernetes \
    "$instance"-csr.json | cfssljson -bare "$instance"
done

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region "$(gcloud config get-value compute/region)" \
  --format 'value(address)')

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,"$KUBERNETES_PUBLIC_ADDRESS",127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account

for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ca.pem "$instance"-key.pem "$instance".pem "$instance":~/
done

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem "$instance":~/
done
