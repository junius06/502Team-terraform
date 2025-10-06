env         = "dev"
region      = "us-west-2"
region_code = "uw-2"

# --- VPC ---
vpc_cidr        = "192.168.0.0/24"
az_suffixes     = ["a", "c"]  # 코드에서 "${region}${suffix}"로 합쳐 씀
private_subnets = ["192.168.0.0/26", "192.168.0.64/26"]
public_subnets  = ["192.168.0.128/26", "192.168.0.192/26"]

enable_nat_gateway     = true
## 단일 nat
single_nat_gateway     = true       # AZ별 NAT 선택 시 false
one_nat_gateway_per_az = false      # AZ갯수만큼 nat 생성 시 true
## 다중 nat
# single_nat_gateway     = false
# one_nat_gateway_per_az = true
## 다중 nat 설정 시, `modules/vpc/nat.tf` 파일 수정 필요

nat_private_ip         = [ "192.168.0.1/32" ]

# --- Security Groups ---


# --- EC2 ---
# ec2_instance_type = "t3.micro"
# ssh_ingress_cidrs = ["x.x.x.x/32"] # Access IP
# key_name          = "dev-ssh-key"

# --- EKS ---
cluster_version     = "1.32"
cluster_name_suffix = "uw2"

mng_instance_types = ["t3.medium"]
mng_min_size       = 2
mng_desired_size   = 2
mng_max_size       = 5

# 