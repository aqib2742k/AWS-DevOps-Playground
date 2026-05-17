provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source             = "../../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones = var.availability_zones
  environment        = var.environment
}

# ALB Module
module "alb" {
  source          = "../../modules/alb"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  environment     = var.environment
}

# EC2 Module
module "ec2" {
  source          = "../../modules/ec2"
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  environment     = var.environment
}

# ASG Module
module "asg" {
  source              = "../../modules/asg"
  launch_template_id  = module.ec2.launch_template_id
  private_subnets     = module.vpc.private_subnet_ids
  target_group_arn    = module.alb.target_group_arn
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  environment         = var.environment
}
