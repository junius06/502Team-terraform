locals {
  nat_eip_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
}

# EIP 생성
resource "aws_eip" "nat" {
  count = local.nat_eip_count
  domain = "vpc"
  depends_on = [ aws_internet_gateway.this ]

  tags = merge(local.common_tags, {
    Name = "eip-nat-${var.Project}-${var.env}-${var.region_code}-${count.index + 1}"
  })
}

# NAT GATEWAY 생성 - EIP 수만큼 생성, 퍼블릭 서브넷에 배치
resource "aws_nat_gateway" "this" {
  count = local.nat_eip_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id

  depends_on = [ aws_internet_gateway.this ]

  tags = merge(local.common_tags, {
    Name = "nat-${var.Project}-${var.env}-${var.region_code}-${count.index + 1}"
  })  
}