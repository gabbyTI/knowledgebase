# EC2 NAT Gateway Module

This module creates a highly available NAT instance using Auto Scaling Group for cost-effective internet access from private subnets.

## Features

- ✅ Auto Scaling Group for high availability
- ✅ Dedicated ENI with static private IP
- ✅ Optional existing EIP support
- ✅ SSM agent for management
- ✅ Proper NAT configuration with iptables
- ✅ Source/destination check disabled

## Usage

### Basic NAT Instance (Auto-assigned IP)
```hcl
module "nat_instance" {
  source             = "../_modules/ec2-nat-gateway"
  name_prefix        = "my-app"
  nat_ami            = "ami-12345678"
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [aws_security_group.nat.id]
}
```

### NAT Instance with Specific IP
```hcl
module "nat_instance" {
  source             = "../_modules/ec2-nat-gateway"
  name_prefix        = "my-app"
  nat_ami            = "ami-12345678"
  subnet_id          = module.vpc.public_subnet_ids[0]
  eni_private_ip     = "10.0.1.100"
  security_group_ids = [aws_security_group.nat.id]
}
```

### NAT Instance with Existing EIP
```hcl
module "nat_instance" {
  source             = "../_modules/ec2-nat-gateway"
  name_prefix        = "production"
  nat_ami            = "ami-12345678"
  subnet_id          = module.vpc.public_subnet_ids[0]
  eni_private_ip     = "10.0.1.100"
  security_group_ids = [aws_security_group.nat.id]
  eip_allocation_id  = "eipalloc-12345678"
  instance_type      = "t3.small"
  
  tags = {
    Environment = "production"
    Purpose     = "NAT"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name_prefix` | Prefix for resource names | string | n/a | ✅ Yes |
| `nat_ami` | AMI ID for NAT instance | string | n/a | ✅ Yes |
| `subnet_id` | Subnet where NAT will live (public subnet) | string | n/a | ✅ Yes |
| `eni_private_ip` | Private IP to assign to ENI (optional) | string | `null` | ❌ No |
| `security_group_ids` | List of security group IDs | list(string) | n/a | ✅ Yes |
| `instance_type` | Instance type for NAT instance | string | `"t3.micro"` | ❌ No |
| `eip_allocation_id` | Optional existing EIP allocation ID | string | `null` | ❌ No |
| `asg_min_size` | Minimum size of ASG | number | `1` | ❌ No |
| `asg_max_size` | Maximum size of ASG | number | `1` | ❌ No |
| `asg_desired_capacity` | Desired capacity of ASG | number | `1` | ❌ No |
| `tags` | Tags to apply to resources | map(string) | `{}` | ❌ No |

## Outputs

| Name | Description |
|------|-------------|
| `nat_instance_id` | ID of the NAT instance (from ASG) |
| `nat_eni_id` | ID of the NAT instance ENI |
| `nat_private_ip` | Private IP of the NAT instance |
| `nat_public_ip` | Public IP of the NAT instance |
| `asg_name` | Name of the Auto Scaling Group |

## Security Group Requirements

The NAT instance requires a security group that allows:
- Inbound traffic from private subnets (typically all VPC CIDR)
- Outbound traffic to internet (0.0.0.0/0)

Example security group:
```hcl
resource "aws_security_group" "nat" {
  name_prefix = "nat-instance-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Route Table Configuration

After creating the NAT instance, update your private route table:
```hcl
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.nat_instance.nat_eni_id
}
```

## Requirements

- Terraform ≥ 1.0
- AWS Provider
- Configured AWS credentials
- Amazon Linux 2 AMI recommended