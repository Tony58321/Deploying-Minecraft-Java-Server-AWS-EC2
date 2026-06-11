#!/bin/bash

set -euo pipefail

echo "Destroying Terraform-managed AWS resources..."
terraform -chdir=terraform destroy

echo "AWS resources destroyed."