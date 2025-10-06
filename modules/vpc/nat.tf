# EIP 생성
resource "aws_eip" "eip-nat" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.igw ]

  tags = merge(var.tags, {
    Name = "eip-nat-${var.Project}-${var.env}-${var.region_code}"
  })
}

# NAT GATEWAY 생성 - tfvars 파일에서 public_subnets 리스트 첫 번째 인덱스 값에 할당
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip-nat.id
  subnet_id = aws_subnet.public[0].id

  depends_on = [ aws_internet_gateway.igw ]

  tags = merge(var.tags, {
    Name = "nat-${var.Project}-${var.env}-${var.region_code}"
  })  
}