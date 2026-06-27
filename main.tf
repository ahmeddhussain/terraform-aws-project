locals {
  public_subnet_ids  = [module.network.public-subnet-1-id, module.network.public-subnet-2-id]
  private_subnet_ids = [module.network.private-subnet-1-id, module.network.private-subnet-2-id]
}

# Network layer
module "network" {
  source                = "./modules/networking"
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  vpc_cidr              = var.vpc_cidr
  environment           = var.environment
}

# Security layer
module "security" {
  source           = "./modules/security"
  vpc_id           = module.network.vpc-cidr-id
  environment      = var.environment
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

# Application layer
module "compute" {
  source                = "./modules/compute"
  public_subnet_ids     = local.public_subnet_ids
  private_subnet_ids    = local.private_subnet_ids
  vpc_id                = module.network.vpc-cidr-id
  frontend_sg_id        = module.security.frontend_ec2_sg_id
  backend_sg_id         = module.security.backend_ec2_sg_id
  backend_alb_sg_id     = module.security.backend_alb_sg_id
  alb_sg_id             = module.security.frontend_alb_sg_id
  alb_name              = var.alb_name
  alb_type              = var.alb_type
  instance_type         = var.instance_type
  backend_instance_type = var.backend_instance_type
  key_pair_name         = var.key_pair_name
  min_size              = var.min_size
  desired_capacity      = var.desired_capacity
  max_size              = var.max_size
  environment           = var.environment
}

# Data layer
module "database" {
  source               = "./modules/database"
  private_subnet_ids   = local.private_subnet_ids
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_username          = var.db_username
  db_password          = var.db_password
  db_sg_id             = module.security.db_sg_id
  environment          = var.environment
}

# Observability layer
module "monitoring" {
  source            = "./modules/monitoring"
  frontend_asg_name = module.compute.frontend_asg_name
  backend_asg_name  = module.compute.backend_asg_name
  alert_email       = var.alert_email
  environment       = var.environment
}
