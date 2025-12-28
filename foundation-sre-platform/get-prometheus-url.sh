#!/bin/bash

# A helper script to discover the correct internal URL for the Prometheus service.
# This is useful for configuring Grafana or for debugging service discovery.

set -e
set -o pipefail

echo "🔍 Discovering Prometheus service..."

# Find the service using its standard labels and extract details.
PROMETHEUS_INFO_JSON=$(kubectl get service --all-namespaces -l "app.kubernetes.io/name=prometheus" -o json | jq -r '.items[0]')

if [[ -z "$PROMETHEUS_INFO_JSON" || "$PROMETHEUS_INFO_JSON" == "null" ]]; then
  echo "❌ Error: Prometheus service not found."
  echo "   Please ensure the kube-prometheus-stack is installed correctly."
  exit 1
fi

NAMESPACE=$(echo "$PROMETHEUS_INFO_JSON" | jq -r '.metadata.namespace')
SERVICE_NAME=$(echo "$PROMETHEUS_INFO_JSON" | jq -r '.metadata.name')

echo "✅ Prometheus found in namespace '$NAMESPACE'."
echo "   The fully qualified internal URL is:"
echo "   http://$SERVICE_NAME.$NAMESPACE.svc.cluster.local:9090"