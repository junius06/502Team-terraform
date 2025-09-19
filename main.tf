locals {
  # AZ suffix와 region을 합쳐서 ["eu-west-1a","eu-west-1b","eu-west-1c"] 생성
  azs_full = [ for s in var.az_suffixes : "${var.region}${s}" ]

  common_tags = {
    Environment = var.env
    Region      = var.region
    Project     = "FOT"
  }
}

# 1) IAM (EC2 SSM 접속용 역할/인스턴스 프로파일)
# module "iam" {
#   source = "./modules/iam"
#   env    = var.env
#   tags   = local.common_tags
# }

# 2) VPC
module "vpc" {
  source = "./modules/vpc"

  env             = var.env
  name_suffix     = "main"
  cidr            = var.vpc_cidr
  azs             = local.azs_full
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  tags = local.common_tags
}

# 3) EC2 (퍼블릭 서브넷에 배스천 1대)
# module "ec2" {
#   source = "./modules/ec2"

#   env                   = var.env
#   name_suffix           = "bastion"
#   instance_type         = var.ec2_instance_type
#   subnet_id             = module.vpc.public_subnet_ids[0]
#   ssh_ingress_cidrs     = var.ssh_ingress_cidrs
#   key_name              = var.key_name
#   iam_instance_profile  = module.iam.instance_profile_name
#   associate_public_ip   = true

#   tags = local.common_tags
# }