resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "igw-${var.Project}-${var.env}-${var.region_code}"
  })
}