#!/usr/bin/env bash

# KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
#     --region $(gcloud config get-value compute/region) \
#     --format 'value(address)')

# for instance in worker-0 worker-1 worker-2; do
#     kubectl config set-cluster kubernetes-the-hard-way \
#         --certificate-authority=ca.pem \
#         --embed-certs=true \
#         --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
#         --kubeconfig=${instance}.kubeconfig

#     kubectl config set-credentials system:node:${instance} \
#         --client-certificate=${instance}.pem \
#         --client-key=${instance}-key.pem \
#         --embed-certs=true \
#         --kubeconfig=${instance}.kubeconfig

#     kubectl config set-context default \
#         --cluster=kubernetes-the-hard-way \
#         --user=system:node:${instance} \
#         --kubeconfig=${instance}.kubeconfig

#     kubectl config use-context default --kubeconfig=${instance}.kubeconfig
# done

# {
#     kubectl config set-cluster kubernetes-the-hard-way \
#         --certificate-authority=ca.pem \
#         --embed-certs=true \
#         --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
#         --kubeconfig=kube-proxy.kubeconfig

#     kubectl config set-credentials system:kube-proxy \
#         --client-certificate=kube-proxy.pem \
#         --client-key=kube-proxy-key.pem \
#         --embed-certs=true \
#         --kubeconfig=kube-proxy.kubeconfig

#     kubectl config set-context default \
#         --cluster=kubernetes-the-hard-way \
#         --user=system:kube-proxy \
#         --kubeconfig=kube-proxy.kubeconfig

#     kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
# }

# {
#     kubectl config set-cluster kubernetes-the-hard-way \
#         --certificate-authority=ca.pem \
#         --embed-certs=true \
#         --server=https://127.0.0.1:6443 \
#         --kubeconfig=kube-controller-manager.kubeconfig

#     kubectl config set-credentials system:kube-controller-manager \
#         --client-certificate=kube-controller-manager.pem \
#         --client-key=kube-controller-manager-key.pem \
#         --embed-certs=true \
#         --kubeconfig=kube-controller-manager.kubeconfig

#     kubectl config set-context default \
#         --cluster=kubernetes-the-hard-way \
#         --user=system:kube-controller-manager \
#         --kubeconfig=kube-controller-manager.kubeconfig

#     kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
# }
