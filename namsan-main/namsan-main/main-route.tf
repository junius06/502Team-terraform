# 완료
locals {
  routes = { for file in fileset("./route", "*.csv") :
    trimsuffix(replace(file, "rtb", "vpc"), ".csv") => { route_rules = csvdecode(file("./route/${file}")) }
  }
}

module "route" {
  source = "../module/terraform-aws-route"

  for_each = local.routes

  # 라우팅 테이블 룰(CSV 추출)
  route_rules = each.value.route_rules

  # Private 라우팅 테이블 정보
  pri_route_table_info = module.vpc[each.key].pri_rtb

  # 라우팅 테이블의 라우팅 대상
  # 생성된 NAT 정보
  target_nat_exist = try(module.vpc[each.key].target_nat_exist, [])
  target_nat_info  = try(module.vpc[each.key].target_nat_info, null)

  # 생성된 TGW Attachment 정보
  target_tgwa_exist = try(module.tgwa[each.key].target_tgwa_exist, [])
  target_tgwa_info  = try(module.tgwa[each.key].target_tgwa_info, null)

  # 생성된 GWLB Endpoint 정보
  target_gwlb_ep_exist = try(module.vpce_gwlb[each.key].target_gwlb_ep_exist, [])
  target_gwlb_ep_info  = try(module.vpce_gwlb[each.key].target_gwlb_ep_info, null)
}

#######################################################
# GWLB Endpoint & TGW Attachment 사용안할 시, 임시로 생성
#######################################################
module "vpce_gwlb" {
  source = "../"
}

module "tgwa" {
  source = "../"
}
