# # 최신 Amazon Linux 2023 (x86_64)
# data "aws_ami" "al2023" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter { 
#     name = "name"
#     values = ["al2023-ami-*-x86_64"] 
#   }
#   filter { 
#     name = "state"
#     values = ["available"] 
#   }
# }

# data "aws_subnet" "selected" { id = var.subnet_id }

# resource "aws_security_group" "this" {
#   name        = "${var.env}-ec2-${var.name_suffix}-sg"
#   description = "EC2 SG for ${var.name_suffix}"
#   vpc_id      = data.aws_subnet.selected.vpc_id

#   dynamic "ingress" {
#     for_each = toset(var.ssh_ingress_cidrs)
#     content {
#       description = "SSH"
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       cidr_blocks = [ingress.value]
#     }
#   }

#   egress { 
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"] 
#   }

#   tags = merge({ Module = "ec2" }, var.tags)
# }

# resource "aws_instance" "this" {
#   ami                         = data.aws_ami.al2023.id
#   instance_type               = var.instance_type
#   subnet_id                   = var.subnet_id
#   vpc_security_group_ids      = [aws_security_group.this.id]
#   key_name                    = var.key_name
#   iam_instance_profile        = var.iam_instance_profile
#   associate_public_ip_address = var.associate_public_ip

#   tags = merge({
#     Name        = "${var.env}-${var.name_suffix}"
#     Environment = var.env
#   }, var.tags)
# }