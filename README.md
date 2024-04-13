# Crossplane EC2 Provisioning

This project demonstrates how to provision EC2 instances on AWS using Crossplane.

## Overview

The project consists of several components:

- **CompositeResourceDefinition (CRD)**: Defines the custom resource `EC2` that users can create to request EC2 instances with specific configurations.
- **Composition**: Describes how to compose the `EC2` custom resource with the necessary patches to provision EC2 instances on AWS.
- **Provider Configuration**: Configures the AWS provider in Crossplane and sets up secrets for AWS credentials.
- **Initialization Script**: Bash script (`init.sh`) for installing Crossplane and the AWS provider, as well as setting up required configurations.
- **Example EC2 Resource**: An example `EC2` custom resource (`ec2-light.yaml`) showcasing how to request an EC2 instance with default parameters.

## Prerequisites

Before running the initialization script, ensure the following:

- File aws-credentials.txt is filled with the right AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
- KUBECONFIG environment variable is set.
- kubectl and helm are installed.

## Getting Started

To set up Crossplane and provision EC2 instances on AWS, follow these steps:

1. Clone this repository.
2. Set the required environment variables.
3. Run the initialization script: `./init.sh`.

## Usage

Run the following command to install the CRD (CompositeResourceDefinition), and the composition:
```bash
kubectl apply -f CompositeResourceDefinitions/ec2_definition.yaml
kubectl apply -f Compositions/ec2_composition.yaml
```
Once the initialization is complete, you can create EC2 instances by applying the `EC2` custom resource YAML files. For example:
```yaml
apiVersion: omerap12.com/v1alpha1
kind: EC2
metadata:
  name: ec2-light # Resource name
  annotations:
    creator: crossplane
    author: omerap12
spec:
  compositionSelector:
    matchLabels:
      provider: aws
  parameters:
    ec2type: cheap # cheap/memory/cpu/gpu/storage optimized (default cheap)
    operatingSystem: # linux linux(AL),Windows, Ubuntu (default AL2)
    subnetId: xxx # Must specify subnet id 
    publicIp: false # true/false (deafult false)
```
A new instance will be created and be managed by crossplane.