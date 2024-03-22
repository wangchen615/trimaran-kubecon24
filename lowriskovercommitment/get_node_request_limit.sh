#!/bin/bash

# Check if a node name was passed as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <NODE_NAME>"
    exit 1
fi

NODE_NAME="$1"

# Echo the node you're inspecting
echo "Getting pods on node: $NODE_NAME"

# Loop through each pod running on the specified node
kubectl get pods --all-namespaces --field-selector spec.nodeName=${NODE_NAME} -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}{end}' | while IFS=$'\t' read -r namespace pod; do
  echo "Namespace: $namespace, Pod: $pod"
  kubectl describe pod -n "$namespace" "$pod" | grep -A2 "Limits:\|Requests:"
  echo "-------------------------------------------------"
done

# Get all pods in JSON format
PODS_JSON=$(kubectl get pods --all-namespaces --field-selector spec.nodeName="$NODE_NAME" -o json)

# Correctly convert CPU units to millicores and memory units to bytes
CPU_REQUESTS_TOTAL=$(echo "$PODS_JSON" | jq '[.items[].spec.containers[].resources.requests.cpu // "0" | gsub("m"; "") | if test("^[0-9]+$") then . else (.[:-1] | tonumber * 1000) end | tonumber] | add')
MEMORY_REQUESTS_TOTAL=$(echo "$PODS_JSON" | jq '[.items[].spec.containers[].resources.requests.memory // "0" | gsub("Ki$"; " * 1024") | gsub("Mi$"; " * 1024^2") | gsub("Gi$"; " * 1024^3") | gsub("Ti$"; " * 1024^4") | gsub("Pi$"; " * 1024^5") | gsub("Ei$"; " * 1024^6") | @sh] | map(tonumber) | add')
CPU_LIMITS_TOTAL=$(echo "$PODS_JSON" | jq '[.items[].spec.containers[].resources.limits.cpu // "0" | gsub("m"; "") | if test("^[0-9]+$") then . else (.[:-1] | tonumber * 1000) end | tonumber] | add')
MEMORY_LIMITS_TOTAL=$(echo "$PODS_JSON" | jq '[.items[].spec.containers[].resources.limits.memory // "0" | gsub("Ki$"; " * 1024") | gsub("Mi$"; " * 1024^2") | gsub("Gi$"; " * 1024^3") | gsub("Ti$"; " * 1024^4") | gsub("Pi$"; " * 1024^5") | gsub("Ei$"; " * 1024^6") | @sh] | map(tonumber) | add')

echo "Total CPU Requests: $CPU_REQUESTS_TOTAL millicores"
echo "Total Memory Requests: $MEMORY_REQUESTS_TOTAL bytes (approximate)"
echo "Total CPU Limits: $CPU_LIMITS_TOTAL millicores"
echo "Total Memory Limits: $MEMORY_LIMITS_TOTAL bytes (approximate)"
