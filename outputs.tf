output "vpc_id"          { value = module.vpc.vpc_id }
output "public_subnets"  { value = module.vpc.public_subnet_ids }
# output "instance_id"     { value = module.ec2.instance_id }
# output "public_ip"       { value = module.ec2.public_ip }