# locals {
#   eks_clusters = { for file in fileset("./eks", "*.yaml") :
#     trimsuffix(file, ".yaml") => yamldecode(file("./eks/${file}"))
#   }
# }

# module "eks" {
#   source = "../module/terraform-aws-eks"

#   for_each = local.eks_clusters

#   # 해당 반복에서 [*] 부분 넣지 않으면 key 중복으로 에러(Duplicate object key)가 발생함
#   eks_cluster_info          = { for k, v in local.eks_clusters[*][each.key] : each.key => v }
#   eks_cluster_subnet_id     = try([for eks_cluster_subnet in each.value.eks_cluster_subnets : module.vpc[each.value.eks_cluster_vpc].pub_sbn[eks_cluster_subnet].id], [for eks_cluster_subnet in each.value.eks_cluster_subnets : module.vpc[each.value.eks_cluster_vpc].pri_sbn[eks_cluster_subnet].id], null) # 퍼블릭일 경우를 고려함.
#   eks_cluster_sg_id         = [for sg_name in each.value.eks_cluster_security_group : module.sg[each.value.eks_cluster_vpc].sg[sg_name].id]
#   eks_node_group_subnet_id  = { for k, v in each.value.eks_node_group : k => try([for eks_node_group_subnet in v.eks_node_group_subnets : module.vpc[each.value.eks_cluster_vpc].pub_sbn[eks_node_group_subnet].id], [for eks_node_group_subnet in v.eks_node_group_subnets : module.vpc[each.value.eks_cluster_vpc].pri_sbn[eks_node_group_subnet].id], null) }
#   eks_launch_template_sg_id = { for k, v in each.value.eks_launch_template : k => [for sg_name in v.eks_launch_template_security_group : module.sg[each.value.eks_cluster_vpc].sg[sg_name].id] }
# }