# locals { name = "${var.env}-${var.name_suffix}" }

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 5.8"

#   name = local.name
#   cidr = var.cidr

#   azs             = var.azs
#   private_subnets = var.private_subnets
#   public_subnets  = var.public_subnets

#   enable_nat_gateway     = var.enable_nat_gateway
#   single_nat_gateway     = var.single_nat_gateway
#   one_nat_gateway_per_az = var.one_nat_gateway_per_az

#   tags = merge({ Module = "vpc" }, var.tags)
# }

locals { common_tags = merge({ Module = "vpc" }, var.tags) }

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, 
  { 
    Name = "vpc-${var.common_tags.Project}-${var.env}-${var.region_code}" 
  })
}