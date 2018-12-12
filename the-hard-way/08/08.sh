#!/usr/bin/env bash

for instance in controller-0 controller-1 controller-2; do
    gcloud compute scp 08-controller-01.sh 08-controller-02.sh ${instance}:~/
    gcloud compute ssh ${instance}
done

gcloud compute scp 08-controller-03-single.sh controller-0:~/

gcloud compute ssh controller-0

{
    KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
        --region $(gcloud config get-value compute/region) \
        --format 'value(address)')

    gcloud compute http-health-checks create kubernetes \
        --description "Kubernetes Health Check" \
        --host "kubernetes.default.svc.cluster.local" \
        --request-path "/healthz"

    gcloud compute firewall-rules create kubernetes-the-hard-way-allow-health-check \
        --network kubernetes-the-hard-way \
        --source-ranges 209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 \
        --allow tcp

    gcloud compute target-pools create kubernetes-target-pool \
        --http-health-check kubernetes

    gcloud compute target-pools add-instances kubernetes-target-pool \
        --instances controller-0,controller-1,controller-2

    gcloud compute forwarding-rules create kubernetes-forwarding-rule \
        --address ${KUBERNETES_PUBLIC_ADDRESS} \
        --ports 6443 \
        --region $(gcloud config get-value compute/region) \
        --target-pool kubernetes-target-pool
}

# Verification
# Retrieve the kubernetes-the-hard-way static IP address
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')

# Make a HTTP request for the Kubernetes version info
curl --cacert ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version
