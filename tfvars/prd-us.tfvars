env    = "prd"
region = "us-west-2"

vpc_cidr        = "10.21.0.0/20"
az_suffixes     = ["a", "b", "c"]
private_subnets = ["10.21.1.0/24", "10.21.2.0/24", "10.21.3.0/24"]
public_subnets  = ["10.21.101.0/24", "10.21.102.0/24", "10.21.103.0/24"]

enable_nat_gateway     = true
single_nat_gateway     = true
one_nat_gateway_per_az = false

ec2_instance_type = "t3.small"
ssh_ingress_cidrs = ["x.x.x.x/32"]
key_name          = "prd-ssh-key"