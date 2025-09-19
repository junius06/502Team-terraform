locals { name = "${var.env}-${var.name_suffix}" }

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = local.name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  tags = merge({ Module = "vpc" }, var.tags)
}

# VPC 생성
resource "aws_vpc" "this" {
  cidr_block            = var.cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = merge(var.tags, {
    Name = "vpc-${tags.Project}-${local.name}"
  })
}

# Public Subnet 생성
resource "aws_subnet" "public" {
  # count = length(var.public_subnets)
  for_each = toset(var.public_subnets)
  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.env}-${var.name_suffix}-public-${count.index + 1}"
    Tier = "Public"
  })
}

# Private Subnet 생성
resource "aws_subnet" "private_subnets" {
  for_each = toset(var.private_subnets)
  vpc_id = aws_vpc.this
}

# Internet Gateway 생성


# nat gateway