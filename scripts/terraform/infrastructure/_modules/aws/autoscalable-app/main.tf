module "iam" {
  source      = "./_modules/iam"
  app_name    = var.app_name
  environment = var.environment
}

module "security_groups" {
  source      = "./_modules/security_groups"
  vpc_id      = var.vpc_id
  app_name    = var.app_name
  app_port    = var.app_port
  environment = var.environment
}

module "alb" {
  source                 = "./_modules/alb"
  vpc_id                 = var.vpc_id
  subnet_ids             = var.subnet_ids
  security_groups        = [module.security_groups.alb_sg_id]
  app_name               = var.app_name
  app_port               = var.app_port
  certificate_arn        = var.certificate_arn
  redirect_http_to_https = var.redirect_http_to_https
  environment            = var.environment
}

module "asg" {
  source               = "./_modules/asg"
  subnet_ids           = var.subnet_ids
  instance_type        = var.instance_type
  security_group_ids   = [module.security_groups.instance_sg_id]
  iam_instance_profile = module.iam.instance_profile_name
  target_group_arns    = [module.alb.target_group_arn]
  app_name             = var.app_name
  max_capacity         = var.max_capacity
  min_capacity         = var.min_capacity
  desired_capacity     = var.desired_capacity
  environment          = var.environment
  ami_id               = var.ami_id
}

module "autoscaler" {
  source            = "./_modules/autoscaler"
  app_name          = var.app_name
  scale_up_policy   = module.asg.scale_up_policy
  scale_down_policy = module.asg.scale_down_policy
  environment       = var.environment
  asg_name          = module.asg.asg_name
}