# Subnet Module

This module creates subnets in a VPC with automatic CIDR calculation and availability zone distribution.

## Features

- ✅ Automatic CIDR block calculation using `cidrsubnet()`
- ✅ Distributes subnets across available AZs
- ✅ Optional route table association
- ✅ Configurable public IP assignment
- ✅ Flexible tagging support

## Usage

### Public Subnets
```hcl
module "public_subnets" {
  source                  = "../subnet-module"
  vpc_id                  = module.vpc.vpc_id
  base_cidr               = "10.0.0.0/16"
  subnet_count            = 3
  subnet_cidr_bits        = 8
  cidr_offset             = 0
  name_prefix             = "public"
  map_public_ip_on_launch = true
  route_table_id          = aws_route_table.public.id
}
```

### Private Subnets
```hcl
module "private_subnets" {
  source           = "../subnet-module"
  vpc_id           = module.vpc.vpc_id
  base_cidr        = "10.0.0.0/16"
  subnet_count     = 3
  subnet_cidr_bits = 8
  cidr_offset      = 10
  name_prefix      = "private"
  route_table_id   = aws_route_table.private.id
}
```

### Subnets without Route Table Association
```hcl
module "db_subnets" {
  source                          = "../subnet-module"
  vpc_id                          = module.vpc.vpc_id
  base_cidr                       = "10.0.0.0/16"
  subnet_count                    = 2
  subnet_cidr_bits                = 8
  cidr_offset                     = 30
  name_prefix                     = "database"
  create_route_table_association  = false
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vpc_id` | ID of the VPC where subnets will be created | string | n/a | ✅ Yes |
| `base_cidr` | Base CIDR block to subnet from | string | n/a | ✅ Yes |
| `subnet_count` | Number of subnets to create | number | `2` | ❌ No |
| `subnet_cidr_bits` | Number of additional bits to extend the base CIDR | number | `8` | ❌ No |
| `cidr_offset` | Offset for CIDR calculation to avoid conflicts | number | `0` | ❌ No |
| `name_prefix` | Prefix for subnet names | string | n/a | ✅ Yes |
| `map_public_ip_on_launch` | Whether to assign public IP on launch | bool | `false` | ❌ No |
| `route_table_id` | Route table ID to associate with subnets | string | `null` | ❌ No* |
| `create_route_table_association` | Whether to create route table associations | bool | `true` | ❌ No |
| `tags` | Additional tags for subnets | map(string) | `{}` | ❌ No |

## Outputs

| Name | Description |
|------|-------------|
| `subnet_ids` | List of subnet IDs |
| `subnet_cidrs` | List of subnet CIDR blocks |
| `availability_zones` | List of availability zones used |

## CIDR Calculation

The module uses `cidrsubnet(base_cidr, subnet_cidr_bits, count.index + cidr_offset)` to calculate subnet CIDRs.

Example with `base_cidr = "10.0.0.0/16"`, `subnet_cidr_bits = 8`:
- Subnet 0: `10.0.0.0/24`
- Subnet 1: `10.0.1.0/24`
- Subnet 2: `10.0.2.0/24`

Use `cidr_offset` to avoid conflicts between public and private subnets.

## Notes

*`route_table_id` is required when `create_route_table_association` is `true` (default).