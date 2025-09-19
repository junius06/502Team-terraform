# resource "aws_iam_role" "ec2_ssm_role" {
#   name = "${var.env}-ec2-ssm-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Principal = { Service = "ec2.amazonaws.com" },
#       Action   = "sts:AssumeRole"
#     }]
#   })
#   tags = merge({ Module = "iam" }, var.tags)
# }

# resource "aws_iam_role_policy_attachment" "ssm_core" {
#   role       = aws_iam_role.ec2_ssm_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_instance_profile" "this" {
#   name = "${var.env}-ec2-ssm-profile"
#   role = aws_iam_role.ec2_ssm_role.name
#   tags = var.tags
# }