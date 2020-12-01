#!/usr/bin/env bash

for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp 09-worker.sh "$instance":~/
  gcloud compute ssh "$instance"
done
