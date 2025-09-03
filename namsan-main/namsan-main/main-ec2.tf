# locals {
#   ec2_instanes = { for file in fileset("./ec2", "*.yaml") :
#     trimsuffix(file, ".yaml") => yamldecode(file("./ec2/${file}"))
#   }
#   ec2_instanes_user_data = { for file in fileset("./ec2", "*.yaml") :
#     trimsuffix(file, ".yaml") => yamldecode(file("./ec2/${file}")).ec2_user_data_file
#   }
# }

# module "ec2" {
#   source = "../module/terraform-aws-ec2"

#   for_each = local.ec2_instanes

#   # 해당 반복에서 [*] 부분 넣지 않으면 key 중복으로 에러(Duplicate object key)가 발생함
#   ec2_list = { for k, v in local.ec2_instanes[*][each.key] : each.key => v }

#   ec2_root_eni_info = {
#     ec2_name                       = each.key
#     ec2_root_eni_subnet            = try(module.vpc[each.value.ec2_vpc].pri_sbn[each.value.ec2_root_eni.ec2_root_eni_subnet].id, module.vpc[each.value.ec2_vpc].pub_sbn[each.value.ec2_root_eni.ec2_root_eni_subnet].id, null)
#     ec2_root_eni_ip                = each.value.ec2_root_eni.ec2_root_eni_ip
#     ec2_root_eni_sg                = [for sg_name in each.value.ec2_root_eni.ec2_root_eni_sg : module.sg[each.value.ec2_vpc].sg[sg_name].id]
#     ec2_root_eni_source_dest_check = each.value.ec2_root_eni.ec2_root_eni_source_dest_check
#   }

#   ec2_sub_eni_info = { for k, v in each.value.ec2_sub_eni : k => {
#     ec2_name                      = each.key
#     ec2_sub_eni_subnet            = try(module.vpc[each.value.ec2_vpc].pri_sbn[v.ec2_sub_eni_subnet].id, module.vpc[each.value.ec2_vpc].pub_sbn[v.ec2_sub_eni_subnet].id, null)
#     ec2_sub_eni_ip                = v.ec2_sub_eni_ip
#     ec2_sub_eni_sg                = [for sg_name in v.ec2_sub_eni_sg : module.sg[each.value.ec2_vpc].sg[sg_name].id]
#     ec2_sub_eni_source_dest_check = v.ec2_sub_eni_source_dest_check
#   } if each.value.ec2_sub_eni != [] }

#   ec2_user_data = try([for k, file in local.ec2_instanes_user_data[*][each.key] : file("./ec2/user_data/${file}")][0], null)
# }