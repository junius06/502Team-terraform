locals { 
  common_tags = merge({ Module = "vpc" }, var.tags)
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr

  tags   = merge(local.common_tags, {
    Name = "vpc-${var.tags.Project}-${var.env}-${var.region_code}"
  })
}