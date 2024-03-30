#!/bin/bash

function print_usage {
  echo "Usage: ./init.sh"
  echo "This script installs Crossplane and the AWS Provider."
  echo "It requires the following environment variables to be set:"
  echo "  - AWS_ACCESS_KEY_ID"
  echo "  - AWS_SECRET_ACCESS_KEY"
  echo "  - KUBECONFIG"
  echo "It also requires the following tools to be installed:"
  echo "  - kubectl"
  echo "  - helm"
}

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set."
  exit 1
fi

if [ -z "$KUBECONFIG" ]; then
  echo "KUBECONFIG must be set."
  exit 1
fi

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
  # Create a secret with AWS credentials.
  kubectl create secret generic aws-creds -n crossplane-system --from-literal=aws_access_key_id=${AWS_ACCESS_KEY_ID} --from-literal=aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
  # Create the AWS Provider.
  kubectl apply -f Providers/aws-provider.yaml
  # Check the status of the provider.
  kubectl get providers.aws.crossplane.io -n crossplane-system
}

if [ $# -ne 0 ]; then
  print_usage
  exit 1
fi

echo "Installing Crossplane..."
install_crossplane
echo "Installing AWS Provider..."
aws_provider