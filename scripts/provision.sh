#!/bin/bash

set -euo pipefail

echo "Initializing Terraform..."
terraform -chdir=terraform init

echo "Formatting Terraform files..."
terraform -chdir=terraform fmt

echo "Validating Terraform configuration..."
terraform -chdir=terraform validate

echo "Applying Terraform infrastructure..."
terraform -chdir=terraform apply

echo "Terraform deployment complete."
terraform -chdir=terraform output