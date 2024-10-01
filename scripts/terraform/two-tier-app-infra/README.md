Here’s a **README** file template for the 2-tier app infrastructure project that you've just built using Terraform with AWS services like EC2, RDS, Auto Scaling, and Load Balancing.

---

# 2-Tier Application Infrastructure with Auto Scaling on AWS

This project provisions a 2-tier web application infrastructure on AWS using Terraform. It includes an application tier with EC2 instances behind an Elastic Load Balancer (ELB) and a database tier using an RDS instance with MySQL. The infrastructure also features auto-scaling to handle fluctuating traffic and ensures high availability with multiple public and private subnets across availability zones (AZs).

## Project Overview

The infrastructure is divided into two tiers:
- **Application Tier**: Consists of EC2 instances running the web application. These instances are part of an Auto Scaling Group (ASG) behind an Application Load Balancer (ALB) for high availability and fault tolerance.
- **Database Tier**: Uses AWS RDS (Relational Database Service) for MySQL to handle database storage. The RDS instance is deployed in private subnets and secured with a VPC security group.

### Features
- **VPC**: A custom Virtual Private Cloud (VPC) with public and private subnets across multiple availability zones.
- **Auto Scaling**: Auto Scaling Group (ASG) to ensure scalability and high availability of EC2 instances.
- **Load Balancer**: Application Load Balancer (ALB) to distribute traffic across multiple instances.
- **RDS MySQL**: A secure, encrypted RDS instance for MySQL database storage.
- **Security Groups**: Separate security groups for the EC2 instances and RDS instance, allowing for controlled access.
- **KMS Encryption**: RDS storage is encrypted using AWS Key Management Service (KMS).
- **CloudWatch Alarms**: Alarms to monitor EC2 instance CPU utilization and trigger scaling actions.

## Prerequisites

To deploy this infrastructure, you will need the following:
- **Terraform**: Ensure you have Terraform installed. You can download it from [here](https://www.terraform.io/downloads.html).
- **AWS CLI**: Install the AWS CLI and configure it with appropriate credentials. You can install the AWS CLI from [here](https://aws.amazon.com/cli/).
- **AWS Account**: Access to an AWS account with permissions to provision VPCs, EC2 instances, RDS, and other related resources.
- **Key Pair**: If SSH access is required, ensure you have an AWS EC2 key pair.

## Resources Provisioned

### Networking (VPC Module)
- **VPC**: Creates a VPC with a CIDR block of `10.0.0.0/16`.
- **Subnets**: Public and private subnets across multiple AZs.
- **Internet Gateway**: An internet gateway attached to the VPC for internet access in public subnets.
- **Route Tables**: Public and private route tables, with the public route table routing traffic to the internet via the Internet Gateway.
  
### Application Tier (EC2 Module)
- **Auto Scaling Group (ASG)**: Ensures there are a minimum of 1 and a maximum of 15 EC2 instances running.
- **Launch Template**: Defines the EC2 instance configuration, including the AMI, instance type, and security groups.
- **Application Load Balancer (ALB)**: Distributes incoming traffic across the EC2 instances in the ASG.
- **Security Group**: Controls inbound access to the EC2 instances, allowing traffic on port 80 (HTTP) and port 22 (SSH).

### Database Tier (RDS Module)
- **RDS MySQL**: Creates an RDS instance for MySQL with encryption enabled using AWS KMS.
- **DB Subnet Group**: Deploys the RDS instance across private subnets.
- **Security Group**: Restricts access to the RDS instance to only the EC2 instances in the ASG.

### Monitoring and Auto Scaling
- **CloudWatch Alarms**: Monitors the CPU utilization of EC2 instances and triggers Auto Scaling based on defined thresholds.
- **Auto Scaling Policies**: Automatically scales up the number of EC2 instances when CPU usage exceeds 70% and scales down when usage drops below 30%.

## How to Deploy

### 1. Clone the Repository
```bash
git clone https://github.com/your-repo/2-tier-app-infra.git
cd 2-tier-app-infra
```

### 2. Initialize Terraform
Run the following command to initialize the project and download the necessary providers:
```bash
terraform init
```

### 3. Define Variables
Update the `variables.tf` file or create a `terraform.tfvars` file to define the necessary variables, such as AWS region, public/private subnet CIDR blocks, availability zones, and any sensitive information (e.g., DB password).

Example of `terraform.tfvars`:
```hcl
region             = "us-east-1"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
azs               = ["us-east-1a", "us-east-1b", "us-east-1c"]
db_username       = "admin"
db_password       = "yourpassword"
```

### 4. Apply the Terraform Configuration
To create the infrastructure, run:
```bash
terraform apply
```
Review the proposed changes and type `yes` to confirm. Terraform will provision all the necessary resources.

### 5. Access the Application
Once the infrastructure is deployed, the public DNS of the load balancer will be available in the outputs. You can access your web application by visiting the load balancer's URL in your browser.

## Variables

Here are some key variables used in the project:

| Variable              | Description                                            |
|-----------------------|--------------------------------------------------------|
| `region`              | AWS region where the infrastructure will be deployed   |
| `public_subnet_cidrs` | List of CIDR blocks for public subnets                 |
| `private_subnet_cidrs`| List of CIDR blocks for private subnets                |
| `azs`                 | List of availability zones for subnet distribution     |
| `db_username`         | Username for the RDS MySQL database                    |
| `db_password`         | Password for the RDS MySQL database                    |

## Outputs

Key outputs of this Terraform project include:
- **Load Balancer DNS**: The DNS address for accessing the application.
- **RDS Endpoint**: The database connection endpoint for the MySQL instance.

## How to Destroy

To tear down and destroy the infrastructure when no longer needed, run:
```bash
terraform destroy
```
This will remove all the resources created by Terraform.

## Future Enhancements
- Add support for HTTPS by configuring an SSL certificate on the Load Balancer.
- Implement blue/green or canary deployments for the application using CodeDeploy.
- Integrate application monitoring using AWS CloudWatch Logs and Metrics.
  
## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

This **README** provides an overview of the project and instructions on how to set up, deploy, and manage the 2-tier infrastructure with Terraform on AWS. You can further customize it based on your specific requirements and preferences.