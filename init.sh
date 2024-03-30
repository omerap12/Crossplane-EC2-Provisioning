#!/bin/bash

# Crossplane Helm Chart repository
helm repo add crossplane-stable https://charts.crossplane.io/stable 
helm repo update

# Run the Helm dry-run to see all the Crossplane components Helm installs.
helm install crossplane crossplane-stable/crossplane --dry-run --debug --namespace crossplane-system --create-namespace

# Install the Crossplane components using helm install.
helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace

# Check the status of the Crossplane components.
echo
sleep 2
kubectl get pods -n crossplane-system

# View endpoints
echo
sleep 2
kubectl api-resources | grep crossplane

echo
sleep 2
echo "Please create a secret with your AWS credentials in the crossplane-system namespace name aws-secret"