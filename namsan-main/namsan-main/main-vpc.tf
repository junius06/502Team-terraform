locals {
  vpcs = { for file in fileset("./vpc", "*.yaml") :
    trimsuffix(file, ".yaml") => yamldecode(file("./vpc/${file}"))
  }
}

module "vpc" {
  source = "../module/terraform-aws-vpc"

  for_each = local.vpcs

  region               = var.region
  vpc_name             = each.key
  vpc_cidr             = each.value.vpc_cidr
  enable_dns_support   = each.value.enable_dns_support
  enable_dns_hostnames = each.value.enable_dns_hostnames

  enable_nat_gateway        = each.value.enable_nat_gateway
  single_nat_gateway        = each.value.single_nat_gateway
  single_nat_gateway_subnet = each.value.single_nat_gateway_subnet
  one_nat_gateway_per_az    = each.value.one_nat_gateway_per_az

  public_subnet  = each.value.public_subnet
  private_subnet = each.value.private_subnet

  vpc_flow_log_s3_name = each.value.vpc_flow_log_s3_name
}