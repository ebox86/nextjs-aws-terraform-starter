#!/bin/bash

# Navigate to the Terraform directory
cd ../terraform

# Check if Terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "Terraform could not be found. Please install Terraform."
    exit 1
fi

# Destroy Terraform-managed infrastructure
echo "Destroying Terraform-managed infrastructure..."
terraform destroy -auto-approve

echo "Teardown complete."

# Return to the scripts directory
cd ../scripts
