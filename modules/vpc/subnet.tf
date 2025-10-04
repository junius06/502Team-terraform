# PUBLIC SUBNET
resource "aws_subnet" "public" {
    count                           = length(var.public_subnets)
    vpc_id                          = aws_vpc.this.id
    cidr_block                      = var.public_subnets[count.index]
    availability_zone               = var.azs[count.index]
    map_public_ip_on_launch         = true

    tags = merge(var.tags, {
        Name = "public-subnet-${var.Project}-${var.env}-${var.region_code}${var.az[count.index]}"
        Tier = "public"
    })
}

# PRIVATE SUBNET
resource "aws_subnet" "private" {
    count                           = length(var.public_subnets)
    vpc_id                          = aws_vpc.this.id
    cidr_block                      = var.private_subnets[count.index]
    availability_zone               = var.azs[count.index]

    tags = merge(var.tags, {
        Name    = "private-subnet-${var.Project}-${var.env}=${var.region_code}${var.az[count.index]}"
        Tier    = "private"
    })
}