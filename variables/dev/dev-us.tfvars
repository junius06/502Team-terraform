env    = "dev"
region = "us-west-2"

# --- VPC ---
vpc_cidr        = "10.1.0.0/20"
az_suffixes     = ["a", "b", "c"]  # 코드에서 "${region}${suffix}"로 합쳐 씀
private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
public_subnets  = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]

enable_nat_gateway     = false
single_nat_gateway     = false
one_nat_gateway_per_az = false

# --- EC2 ---
# ec2_instance_type = "t3.micro"
# ssh_ingress_cidrs = ["x.x.x.x/32"] # Access IP
# key_name          = "dev-ssh-key"

# --- EKS ---