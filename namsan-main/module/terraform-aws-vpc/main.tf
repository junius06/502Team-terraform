locals {
  # IGW 이름 설정
  igw_name = endswith(var.vpc_name, "vpc") ? replace(var.vpc_name, "vpc", "igw") : "VPC YAML 파일명을 네이밍 룰에 맞게 변경하세요!"

  # VPC Flow Log 이름 설정
  vpc_flow_log_name = endswith(var.vpc_name, "vpc") ? replace(var.vpc_name, "vpc", "vpcflow") : "VPC YAML 파일명을 네이밍 룰에 맞게 변경하세요!"

  # 서브넷별 Routing Table 이름 설정
  pub_rtb_name = var.public_subnet != null ? { for key, value in var.public_subnet : join("",[regex("^((?:[^-]+-){3})(.*)$", value.tags.Name)[0], "rtb-", regex("^((?:[^-]+-){3})(.*)$", value.tags.Name)[1]]) => value.tags.Name } : {}
  pri_rtb_name = var.private_subnet != null ? { for key, value in var.private_subnet : join("",[regex("^((?:[^-]+-){3})(.*)$", value.tags.Name)[0], "rtb-", regex("^((?:[^-]+-){3})(.*)$", value.tags.Name)[1]]) => value.tags.Name } : {}

  # Multi-AZ / Single NAT 리소스 이름 설정 및 반복 횟수 지정
  one_nat_gateway_per_az_name  = [for key, value in aws_subnet.public : join("",[regex("^((?:[^-]+-){3})(.*)$", key)[0], "eip-", regex("^((?:[^-]+-){3})(.*)$", key)[1]]) if var.enable_nat_gateway && var.public_subnet != null]
  one_nat_gateway_per_az_count = var.single_nat_gateway_subnet == "" ? local.one_nat_gateway_per_az_name : null # single_nat_gateway_subnet값 공백 확인

  single_nat_gateway_name  = var.single_nat_gateway == true && var.public_subnet != null && var.single_nat_gateway != var.one_nat_gateway_per_az ? join("",[regex("^((?:[^-]+-){3})(.*)$", var.single_nat_gateway_subnet)[0], "eip-", regex("^((?:[^-]+-){3})(.*)$", var.single_nat_gateway_subnet)[1]]) : null
  single_nat_gateway_count = var.single_nat_gateway_subnet != null ? local.single_nat_gateway_name : null # single_nat_gateway_subnet값 공백 확인

  # Multi-AZ / Single NAT 리소스 생성을 위한 Subnet, EIP 정보 재조립
  one_nat_gateway_per_az_case = var.enable_nat_gateway && local.one_nat_gateway_per_az_count != null ? { for subnet_name, subnet_attribute in aws_subnet.public : join("",[regex("^((?:[^-]+-){3})(.*)$", subnet_name)[0], "nat-", regex("^((?:[^-]+-){3})(.*)$", subnet_name)[1]]) => {
    "subnet_id" = aws_subnet.public[subnet_name].id,
    "eip_id" = aws_eip.nat[join("",[regex("^((?:[^-]+-){3})(.*)$", subnet_name)[0], "eip-", regex("^((?:[^-]+-){3})(.*)$", subnet_name)[1]])].id }
  } : null

  single_nat_gateway_case = var.enable_nat_gateway && local.single_nat_gateway_count != null ? { join("",[regex("^((?:[^-]+-){3})(.*)$", var.single_nat_gateway_subnet)[0], "nat-", regex("^((?:[^-]+-){3})(.*)$", var.single_nat_gateway_subnet)[1]]) = {
    "subnet_id" = aws_subnet.public[var.single_nat_gateway_subnet].id,
    "eip_id" = aws_eip.nat[local.single_nat_gateway_name].id }
  } : null
}

################################################################################
# VPC
################################################################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = {
    Name = var.vpc_name
  }
}

# ################################################################################
# # VPC Flow Log
# ################################################################################
resource "aws_flow_log" "this" {
  for_each = var.vpc_flow_log_s3_name != "" ? toset([local.vpc_flow_log_name]) : toset([])

  vpc_id                   = aws_vpc.this.id
  traffic_type             = "ALL"
  max_aggregation_interval = "60"

  log_destination_type = "s3"
  log_destination      = "arn:aws:s3:::${var.vpc_flow_log_s3_name}"
  log_format           = "$${account-id} $${action} $${az-id} $${bytes} $${dstaddr} $${dstport} $${end} $${flow-direction} $${instance-id} $${interface-id} $${log-status} $${packets} $${pkt-dst-aws-service} $${pkt-dstaddr} $${pkt-src-aws-service} $${pkt-srcaddr} $${protocol} $${region} $${srcaddr} $${srcport} $${start} $${sublocation-id} $${sublocation-type} $${subnet-id} $${tcp-flags} $${traffic-path} $${type} $${version} $${vpc-id}"

  destination_options {
    file_format                = "parquet"
    hive_compatible_partitions = false
    per_hour_partition         = false
  }
  tags = {
    Name = local.vpc_flow_log_name
  }
}

# ################################################################################
# # Internet Gateway
# ################################################################################
resource "aws_internet_gateway" "this" {
  for_each = length(aws_subnet.public) > 0 ? toset([local.igw_name]) : toset([]) # public subnet 존재 여부에 따라 IGW 생성 조건

  vpc_id = aws_vpc.this.id
  tags = {
    Name = local.igw_name
  }
}

################################################################################
# Public Subnet
################################################################################
resource "aws_subnet" "public" {
  for_each = { for k, v in var.public_subnet : v.tags.Name => v if var.public_subnet != null } # public_subnet을 선언하지 않으면 null일 수 있으므로 조건 처리

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.subnet_cidr
  availability_zone       = "${var.region}${substr(each.key, -1, 1)}" # 서브넷 끝 자리 a,c를 기준으로 존 설정
  map_public_ip_on_launch = true
  tags                    = each.value.tags
}

###############################################################################
# Private Subnet
###############################################################################
resource "aws_subnet" "private" {
  for_each = { for k, v in var.private_subnet : v.tags.Name => v if var.private_subnet != null }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.subnet_cidr
  availability_zone = "${var.region}${substr(each.key, -1, 1)}"
  tags              = each.value.tags
}

################################################################################
# Publiс Routetable
################################################################################
resource "aws_route_table" "public" {
  for_each = local.pub_rtb_name != null ? local.pub_rtb_name : {}

  vpc_id = aws_vpc.this.id
  tags = {
    Name = each.key
  }
}
resource "aws_route_table_association" "public" {
  for_each = local.pub_rtb_name != null ? local.pub_rtb_name : {}

  subnet_id      = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route" "public_internet_gateway" {
  for_each = aws_route_table.public

  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[local.igw_name].id

  timeouts {
    create = "2m"
  }
}

################################################################################
# Private Routetable
################################################################################
resource "aws_route_table" "private" {
  for_each = local.pri_rtb_name != null ? local.pri_rtb_name : {}

  vpc_id = aws_vpc.this.id
  tags = {
    Name = each.key
  }
}

resource "aws_route_table_association" "private" {
  for_each = local.pri_rtb_name != null ? local.pri_rtb_name : {}

  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private[each.key].id
}

################################################################################
# EIP
################################################################################
resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? (var.single_nat_gateway ? toset([local.single_nat_gateway_count]) : var.one_nat_gateway_per_az ? local.one_nat_gateway_per_az_count : toset([]) # 생성된 public subnet의 availability_zone 값으로 toset([])을 사용하여 중복값 없앰.
  ) : toset([])

  domain = "vpc"
  tags = {
    Name = each.key
  }

  depends_on = [aws_internet_gateway.this]
}

################################################################################
# NAT Gateway
################################################################################
resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? (var.single_nat_gateway ? local.single_nat_gateway_case : var.one_nat_gateway_per_az ? local.one_nat_gateway_per_az_case : {} # 싱글 NAT 또는 Multi AZ NAT 경우에 따라서 NAT 생성
  ) : {}

  allocation_id = each.value.eip_id # 서브넷이 위치한 존 확인을 위해 local.public_subnet_id_az value 값 사용
  subnet_id     = each.value.subnet_id

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = each.key
  }
}