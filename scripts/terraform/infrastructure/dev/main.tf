module "vpc" {
  source      = "../_modules/aws/vpc"
  cidr_block  = "10.0.0.0/16"
  environment = "dev"
}