locals { 
  vpc_name    = "vpc-${var.tags.Project}-${var.env}-${var.region_code}"
  common_tags = merge({ Module = "vpc" }, var.tags)
}

resource "aws_vpc" "this" {  
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = local.vpc_name
  })
}