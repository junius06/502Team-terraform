# route.tf 변수에 NAT 정보 저장 용도
output "target_nat_exist" {
  value = [for value in [for value in aws_nat_gateway.this : value.tags] : value.Name]
}

output "target_nat_info" {
  value = aws_nat_gateway.this
}

# sg.tf 모듈에 depend_on 용도
output "vpc_id" {
  value = aws_vpc.this.id
}

output "pub_sbn" {
  value = aws_subnet.public
}

output "pri_sbn" {
  value = aws_subnet.private
}

# route 모듈의 pri_route_table_info 변수에 활용
output "pri_rtb" {
  value = aws_route_table.private
}