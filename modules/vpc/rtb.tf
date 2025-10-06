# ── Public Route Table + 0.0.0.0/0 → IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  tags   = merge(var.tags, {
    Name = "rtb-public-${var.Project}-${var.env}-${var.region_code}"
  })
}

resource "aws_route" "public_default" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count                     = length(aws_subnet.public)
  subnet_id                 = aws_subnet.private[count.index].id
  route_table_id            = aws_route_table.public.id
}

# ── Private Route Tables + 0.0.0.0/0 → NAT GW
resource "aws_route_table" "private" {
  vpc_id                    = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "rtb-private-${var.Project}-${var.env}-${var.region_code}"
  })
}

resource "aws_route" "private_default" {
  count = (length(aws_subnet.private) > 0 && length(aws_nat_gateway.nat) > 0) ? length(aws_subnet.private) : 0

  route_table_id            = aws_route_table.private[count.index].id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat[main(count.index, max(length(aws_nat_gateway.nat) - 1, 0))].id
}

resource "aws_route_table_association" "private" {
  count                     = length(aws_subnet.private)
  subnet_id                 = aws_subnet.private[count.index].id
  route_table_id            = aws_route_table.private[count.index].id
}