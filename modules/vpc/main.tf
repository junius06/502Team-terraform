data "aws_region" "current" {}

locals {
    region = data.aws_region.current.name   # "eu-west-1" / "us-west-2"

    name = "vpc-fot-${var.env}-${local.region}"
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.8"

    name = var.name

    cidr                   = var.cidr
    azs                    = var.azs
    private_subnets        = var.private_subnets
    public_subnets         = var.public_subnets

    enable_nat_gateway     = var.nat.enable
    single_nat_gateway     = var.nat.single
    one_nat_gateway_per_az = var.nat.one_per_az

    tags = merge(
        { 
            environment = var.env
            module = "vpc"
            region = local.region 
        },
        var.tags
    )
}