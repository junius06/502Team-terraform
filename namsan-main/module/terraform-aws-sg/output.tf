# Security Group을 사용하는 모든 리소스가 참조(Depends_on) ex)ec2, vpce, rds 등등
output "sg" {
  value = aws_security_group.this
}