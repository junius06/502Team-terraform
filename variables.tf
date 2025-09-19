# ─────────────────────────────
# 필수 입력(반드시 tfvars로 주입)
# ─────────────────────────────
# variable "env" {
#   description = "Environment: dev | stg | prd"
#   type        = string
#   validation {
#     condition     = contains(["dev","stg","prd"], var.env)
#     error_message = "Environment must be one of: dev, stg, prd."
#   }
# }

# variable "region" {
#   description = "AWS region: eu-west-1 | us-west-2"
#   type        = string
#   validation {
#     condition     = contains(["eu-west-1","us-west-2"], var.region)
#     error_message = "Region must be one of: eu-west-1, us-west-2."
#   }
# }

# ─────────────────────────────
# VPC 파라미터 (환경별 CIDR 상이 → 기본값 제거)
# ─────────────────────────────
# variable "vpc_cidr" {
#   description = "VPC CIDR block (e.g., 10.20.0.0/16)"
#   type        = string
# }

# # 리전 접미사(가용영역 문자). 지역별 AZ 수에 맞춰 tfvars에서 지정
# variable "az_suffixes" {
#   description = "Availability zone suffixes (e.g., [\"a\",\"b\",\"c\"])"
#   type        = list(string)
#   validation {
#     condition     = length(var.az_suffixes) > 0 && alltrue([for s in var.az_suffixes : contains(["a","b","c","d"], s)])
#     error_message = "az_suffixes must be non-empty and each item must be one of: a, b, c, d."
#   }
# }

# variable "private_subnets" {
#   description = "List of private subnet CIDRs (same length as az_suffixes)"
#   type        = list(string)
#   validation {
#     condition     = length(var.private_subnets) == length(var.az_suffixes)
#     error_message = "private_subnets length must match az_suffixes length."
#   }
# }

# variable "public_subnets" {
#   description = "List of public subnet CIDRs (same length as az_suffixes)"
#   type        = list(string)
#   validation {
#     condition     = length(var.public_subnets) == length(var.az_suffixes)
#     error_message = "public_subnets length must match az_suffixes length."
#   }
# }

# # NAT 전략(환경별 정책 상이 가능 → 기본값 제거하고 tfvars에서 명시)
# variable "enable_nat_gateway"     { type = bool }
# variable "single_nat_gateway"     { type = bool }
# variable "one_nat_gateway_per_az" { type = bool }

# ─────────────────────────────
# EC2 (배스천 등)
# ─────────────────────────────
# variable "ec2_instance_type" {
#   type        = string
#   description = "EC2 instance type for bastion/app nodes"
# }

# # 운영에선 회사 고정 IP / VPN CIDR만 넣도록 기본값 제거
# variable "ssh_ingress_cidrs" {
#   type        = list(string)
#   description = "Allowed CIDRs for SSH (e.g., [\"203.0.113.0/24\"])"
#   validation {
#     condition     = length(var.ssh_ingress_cidrs) > 0
#     error_message = "ssh_ingress_cidrs must contain at least one CIDR."
#   }
# }

# # 키페어는 없을 수도 있으니 null 허용
# variable "key_name" {
#   type        = string
#   default     = null
#   description = "Optional EC2 key pair name"
# }