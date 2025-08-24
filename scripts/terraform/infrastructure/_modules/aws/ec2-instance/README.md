# EC2 Instance Module

This module creates an EC2 instance with automatic SSH key generation and optional Elastic IP.

## Features

- ✅ Automatic SSH key pair generation (ED25519)
- ✅ Optional Elastic IP assignment
- ✅ Configurable security groups
- ✅ User data script support
- ✅ Flexible tagging

## Usage

### Basic Instance
```hcl
module "ec2" {
  source             = "../_modules/ec2-instance"
  name_prefix        = "my-app"
  subnet_id          = "subnet-12345"
  ami                = "ami-12345"
  instance_type      = "t3.micro"
  security_group_ids = ["sg-12345"]
}
```

### Instance with Elastic IP
```hcl
module "ec2" {
  source             = "../_modules/ec2-instance"
  name_prefix        = "my-app"
  subnet_id          = "subnet-12345"
  ami                = "ami-12345"
  instance_type      = "t3.micro"
  security_group_ids = ["sg-12345"]
  create_eip         = true
  user_data          = file("user-data.sh")
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name_prefix` | Prefix for resource names | string | n/a | ✅ Yes |
| `subnet_id` | ID of the subnet to launch instance in | string | n/a | ✅ Yes |
| `ami` | AMI ID for the EC2 instance | string | n/a | ✅ Yes |
| `instance_type` | EC2 instance type | string | n/a | ✅ Yes |
| `security_group_ids` | Set of security group IDs | set(string) | n/a | ✅ Yes |
| `create_eip` | Whether to create an Elastic IP | bool | `false` | ❌ No |
| `user_data` | User data script for instance initialization | string | `null` | ❌ No |
| `tags` | Additional tags for resources | map(string) | `{}` | ❌ No |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | ID of the EC2 instance |
| `public_ip` | Public IP address (EIP if created) |
| `ssh_private_key` | SSH private key (sensitive) |
| `ssh_public_key` | SSH public key (sensitive) |

## SSH Access

The module automatically generates an ED25519 SSH key pair. Access the private key:

```bash
terraform output -raw ssh_private_key > private_key.pem
chmod 600 private_key.pem
ssh -i private_key.pem ec2-user@<public_ip>
```

## Requirements

- Terraform ≥ 1.0
- AWS Provider
- Configured AWS credentials