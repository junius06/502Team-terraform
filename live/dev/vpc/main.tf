variable "env" { type = string }

locals {
    cfg = yamldecode(file("${path.root}/../../../envs/${var.env}.yaml"))
}

module "vpc_stack" {
    source = "../../../../modules/vpc"

    name = local.cfg.vpc.name
    cidr = local.cfg.vpc.cidr
    azs = local.cfg.vpc.azs
    private_subnets = local.cfg.vpc.private_subnets
    public_subnets = local.cfg.vpc.public_subnets

    enable_nat_gateway = try(local.cfg.vpc.nat.enable_nat_gateway, true)
    single_nat_gateway = try(local.cfg.vpc.nat.single_nat_gateway, true)
    one_nat_gateway_per_az = try(local.cfg.vpc.nat.one_nat_gateway_per_az, false)

    # 필요 시 추가 태그 전달 (ALB/EKS를 나중에 붙일 경우 여기에 cluster 태그 추가 가능)
    public_subnet_extra_tags = {}
    private_subnet_extra_tags = {}

    tags = try(local.cfg.vpc.tags, {})
}

output "vpc_id" { value = module.vpc_stack.vpc_id }
output "private_subnet_ids" { value = module.vpc_stack.private_subnet_ids }
output "public_subnet_ids" { value = module.vpc_stack.public_subnet_ids }
output "private_subnet_cidrs" { value = module.vpc_stack.private_subnet_cidrs }
output "public_subnet_cidrs" { value = module.vpc_stack.public_subnet_cidrs }