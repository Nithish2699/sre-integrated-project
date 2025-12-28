#!/bin/bash

# A robust script to connect to Grafana without hardcoding names or namespaces.
# It uses label selectors to discover the running instance.

set -e # Exit immediately if a command exits with a non-zero status.
set -o pipefail # The return value of a pipeline is the status of the last command to exit with a non-zero status.

echo "🔍 Discovering Grafana service..."

# Find the service using its label and extract namespace and name.
# The 'jq' tool is excellent for safely parsing JSON.
SERVICE_INFO_JSON=$(kubectl get service --all-namespaces -l "app.kubernetes.io/name=grafana" -o json | jq -r '.items[0]')

if [[ -z "$SERVICE_INFO_JSON" || "$SERVICE_INFO_JSON" == "null" ]]; then
  echo "❌ Error: Grafana service not found."
  echo "   Please ensure the kube-prometheus-stack is installed correctly."
  exit 1
fi

NAMESPACE=$(echo "$SERVICE_INFO_JSON" | jq -r '.metadata.namespace')
SERVICE_NAME=$(echo "$SERVICE_INFO_JSON" | jq -r '.metadata.name')
SECRET_NAME=$SERVICE_NAME # The secret name usually matches the service name.

echo "✅ Grafana found in namespace '$NAMESPACE' with service name '$SERVICE_NAME'."
echo

# Retrieve the password using the discovered names.
ADMIN_PASSWORD=$(kubectl get secret -n "$NAMESPACE" "$SECRET_NAME" -o jsonpath="{.data.admin-password}" | base64 --decode)

echo "🔐 Credentials:"
echo "   Username: admin"
echo "   Password: $ADMIN_PASSWORD"
echo

echo "🚀 To connect, run the following command in a separate terminal and leave it running:"
echo "   kubectl port-forward -n $NAMESPACE svc/$SERVICE_NAME 3000:80"
