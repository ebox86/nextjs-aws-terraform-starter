#!/bin/bash

if ! docker info > /dev/null 2>&1; then
    echo "Docker daemon is not running. Trying to source ~/.bashrc, ~/.bash_profile..."
    source ~/.bashrc
    source ~/.bash_profile
    if ! docker info > /dev/null 2>&1; then
        echo "Docker daemon is still not running. Please start Docker and try again."
        exit 1
    fi
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "Terraform could not be found. Please install Terraform and ensure it's in your PATH."
    exit 1
fi

# Configuration Variables
AWS_REGION="us-west-2"    # AWS region
IMAGE_TAG="latest"        # Image tag

# Navigate to the Terraform directory
cd ../terraform

# Initialize Terraform (only needs to be run once)
echo "Initializing Terraform..."
terraform init

# Apply Terraform configuration to create the ECR repository
echo "Applying Terraform configuration for ECR repository..."
terraform apply -target=aws_ecr_repository.nextjs_repository -auto-approve

# Retrieve the ECR repository URL
ECR_REPOSITORY=$(terraform output -raw ecr_repository_url)

# Navigate to the Next.js app directory
cd ../nextjs-app

# Build the Docker image
echo "Building Docker image..."
docker build -t nextjs-app .

# Tag the Docker image for the ECR repository
echo "Tagging Docker image..."
docker tag nextjs-app:latest ${ECR_REPOSITORY}:${IMAGE_TAG}

# Login to AWS ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY}

# Push the Docker image to ECR
echo "Pushing Docker image to ECR..."
docker push ${ECR_REPOSITORY}:${IMAGE_TAG}

# Navigate back to the Terraform directory
cd ../terraform

# Apply the full Terraform configuration
echo "Applying full Terraform configuration..."
terraform apply -auto-approve

# Return to the scripts directory
cd ../scripts
