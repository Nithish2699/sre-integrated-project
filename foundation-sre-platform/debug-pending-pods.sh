#!/bin/bash

# A helper script to quickly debug the first pod found in a 'Pending' state
# within a specified namespace.

set -e

NAMESPACE=$1

if [[ -z "$NAMESPACE" ]]; then
  echo "❌ Error: Please provide a namespace."
  echo "   Usage: $0 <namespace>"
  exit 1
fi

PENDING_POD=$(kubectl get pods -n "$NAMESPACE" --field-selector=status.phase=Pending -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [[ -z "$PENDING_POD" ]]; then
  echo "✅ No pending pods found in namespace '$NAMESPACE'."
else
  echo "🔍 Describing first pending pod: $PENDING_POD"
  kubectl describe pod "$PENDING_POD" -n "$NAMESPACE"
fi