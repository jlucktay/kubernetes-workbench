#!/usr/bin/env bash
set -euo pipefail

set +e

kubectl delete -f https://raw.githubusercontent.com/kudobuilder/kudo/842c7f19a0a361751f0dab330faf3be147c9c4b3/docs/deployment/20-deployment.yaml
kubectl delete -f https://raw.githubusercontent.com/kudobuilder/kudo/v0.5.0/docs/deployment/10-crds.yaml
kubectl delete -f https://raw.githubusercontent.com/kudobuilder/kudo/v0.5.0/docs/deployment/00-prereqs.yaml
