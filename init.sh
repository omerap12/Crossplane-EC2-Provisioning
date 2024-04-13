#!/bin/bash

function print_usage {
  echo "Usage: ./init.sh"
  echo "This script installs Crossplane and the AWS Provider."
  echo "It requires the following environment variable to be set:"
  echo "  - KUBECONFIG"
  echo "It also requires the following tools to be installed:"
  echo "  - kubectl"
  echo "  - helm"
}

function install_crossplane {
  # Crossplane Helm Chart repository
  helm repo add crossplane-stable https://charts.crossplane.io/stable 
  helm repo update
  # Run the Helm dry-run to see all the Crossplane components Helm installs.
  helm install crossplane crossplane-stable/crossplane --dry-run --debug --namespace crossplane-system --create-namespace

  # Install the Crossplane components using helm install.
  helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace
   # Check the status of the Crossplane components.
  sleep 2
  echo "Pods in crossplane-system namespace:"
  kubectl get pods -n crossplane-system
  echo 
  echo "endpoints in crossplane:"
  kubectl api-resources | grep crossplane
}


function aws_provider {
  # Apply AWS Credentials Secret.
  kubectl create secret generic aws-secret -n crossplane-system --from-file=creds=./aws-credentials.txt
  # Create the AWS Provider.
  kubectl apply -f Providers/
  helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace --set provider.packages='{xpkg.upbound.io/crossplane-contrib/provider-aws:v0.39.0}'

}

if [ $# -ne 0 ]; then
  print_usage
  exit 1
fi

if [ -z "$KUBECONFIG" ]; then
  echo "KUBECONFIG must be set."
  exit 1
fi


echo "Installing Crossplane..."
install_crossplane
echo
echo "Installing AWS Provider..."
sleep 10
aws_provider