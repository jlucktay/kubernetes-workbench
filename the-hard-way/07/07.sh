#!/usr/bin/env bash

# gcloud compute ssh controller-0
# gcloud compute ssh controller-1
# gcloud compute ssh controller-2

for instance in controller-0 controller-1 controller-2; do
    gcloud compute scp 07-controller.sh ${instance}:~/
done
