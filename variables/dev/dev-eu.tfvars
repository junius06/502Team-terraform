env    = "dev"
region = "eu-west-1"

# --- VPC ---
vpc_cidr        = "10.0.0.0/20"
az_suffixes     = ["a", "b", "c"]  # 코드에서 "${region}${suffix}"로 합쳐 씀
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

enable_nat_gateway     = true
single_nat_gateway     = true
one_nat_gateway_per_az = false

# --- EC2 ---
ec2_instance_type = "t3.micro"
ssh_ingress_cidrs = ["x.x.x.x/32"] # Access IP
key_name          = "dev-ssh-key"