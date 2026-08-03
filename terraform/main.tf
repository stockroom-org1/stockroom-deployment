terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }

  backend "s3" {
    # Configured at init time via -backend-config flags
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source      = "./modules/vpc"
  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "ecr" {
  source      = "./modules/ecr"
  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "alb" {
  source            = "./modules/alb"
  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  tags              = local.common_tags
}

module "ecs" {
  source                    = "./modules/ecs"
  name_prefix               = local.name_prefix
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  api_image_uri             = var.api_image_uri
  frontend_image_uri        = var.frontend_image_uri
  api_target_group_arn      = module.alb.api_target_group_arn
  frontend_target_group_arn = module.alb.frontend_target_group_arn
  database_url              = "postgresql+asyncpg://${module.rds.db_username}:${var.db_password}@${module.rds.db_endpoint}/${module.rds.db_name}"
  api_key                   = var.api_key
  tags                      = local.common_tags
}

module "rds" {
  source             = "./modules/rds"
  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  vpc_cidr_block     = module.vpc.vpc_cidr_block
  private_subnet_ids = module.vpc.private_subnet_ids
  db_password        = var.db_password
  tags               = local.common_tags
}
