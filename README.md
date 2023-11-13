# nextjs-aws-terraform-starter
nextjs starter using terraform on aws

## Project Structure

```
nextjs-aws-terraform-starter/
│
├── nextjs-app/                # Next.js application source code
│   ├── pages/                 # Pages directory for Next.js
│   ├── public/                # Public assets
│   ├── styles/                # CSS or other styling files
│   ├── .env.local             # Local environment variables
│   ├── package.json           # Node.js dependencies and scripts
│   ├── Dockerfile             # Dockerfile for building your Next.js app
│   └── ...
│
├── terraform/                 # Terraform configuration files
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Terraform variables
│   ├── outputs.tf             # Terraform outputs
│   └── ...
│
├── scripts/                   # Utility and deployment scripts
│   ├── deploy.sh              # Script for building and deploying the app
│   └── ...
│
├── .gitignore                 # Git ignore file
└── README.md                  # Project README
```

## Setup

navigate to /scripts and run `./deploy.sh`

### Notes

* this assumes the use of default VPC and creates 2 new subnets: `172.31.101.0/24` and `172.31.102.0/24`. More on default VPC's [here.](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html)
* the ECR repo is created with `force_delete=true`, disable this for production deployments.