# ==============================================================================
# AWS TWO-TIER WEB ARCHITECTURE CONFIGURATION
# ==============================================================================

# 1. VPC Module (Networking Layer)
module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  environment          = var.environment
}

# 2. S3 Module (Storage Layer)
module "s3" {
  source         = "./modules/s3"
  aws_account_id = var.aws_account_id
  environment    = var.environment
}

# 3. IAM Module (Identity & Access Profiles)
module "iam" {
  source      = "./modules/iam"
  bucket_arn  = module.s3.bucket_arn
  environment = var.environment
}

# 4. EC2 Module (Compute Layer: Bastion & App Nodes)
module "ec2" {
  source                    = "./modules/ec2"
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  private_subnet_ids        = module.vpc.private_subnet_ids
  key_name                  = var.key_name
  instance_type             = var.instance_type
  iam_instance_profile_name = module.iam.instance_profile_name
  allowed_admin_ips         = var.allowed_admin_ips
  environment               = var.environment
}

# 5. RDS Module (Data Layer)
module "rds" {
  source                = "./modules/rds"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.ec2.app_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  environment           = var.environment
}
