# ─────────────────────────────
# 0. LOCAL
# ─────────────────────────────
locals {
  project   = "fot"
  azs_full  = [ for s in var.az_suffixes : "${var.region_code}${s}" ]
}

# ─────────────────────────────
# 1. VPC
# ─────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  env                    = var.env
  name_suffix            = "main"
  cidr                   = var.vpc_cidr

  region_code            = var.region_code    # uw-2, ew-2
  az                     = var.az_suffixes    # a, c
  azs                    = local.azs_full     # uw-2a, uw-2c, ew-2a, ew-2c
  
  private_subnets        = var.private_subnets
  public_subnets         = var.public_subnets

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  # tags = local.common_tags
  Project                = local.project
}


# ─────────────────────────────
# 2. EKS
# ─────────────────────────────
# module "eks" {
#   source = "./modules/eks"

#   env                 = var.env
#   cluster_name        = "eks-${local.common_tags.Project}-${var.env}-${var.cluster_name_suffix}" # eks-fot-dev-uw2
#   cluster_version     = var.cluster_version

#   vpc_id              = module.vpc.vpc_id
#   private_subnet_ids  = module.vpc.private_subnet_ids

#   mng_instance_types  = var.mng_instance_types
#   mng_min_size        = var.mng_min_size
#   mng_desired_size    = var.mng_desired_size
#   mng_max_size        = var.mng_max_size

#   tags = local.common_tags
# }


# ─────────────────────────────
# 3. IAM
# ─────────────────────────────
# module "iam" {
#   source = "./modules/iam"
#   env    = var.env
#   tags   = local.common_tags
# }


# ─────────────────────────────
# 4. EC2
# ─────────────────────────────
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


# ─────────────────────────────
# 5. Security Groups
# ─────────────────────────────