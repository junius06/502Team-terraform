# Decode the CSV file into a list of maps
locals {
  # 보안그룹 생성 및 VPC ID 조회를 위한 TEMP 변수 => CSV 파일 내 SG Name, VPC Name 정보(중복값 제거) 리스트로 저장
  sg_info_list = toset([for rule in var.sg_rules : {
    sg_name = rule.sg_name
    }
  ])

  # sg_info_list 리스트 변수를 MAP 형태로 변환
  sg_info_map = { for k, v in local.sg_info_list : v.sg_name => var.vpc_id }
}

# Create a security group for each unique name
resource "aws_security_group" "this" {
  for_each = local.sg_info_map

  vpc_id      = each.value
  name        = each.key
  description = each.key
  tags = {
    Name = each.key
  }

  timeouts {
    create = "30s"
    delete = "30s"
  }
}

# CIDR Block Type Rule
resource "aws_security_group_rule" "cidr_block_rules" {
  for_each = { for rule in var.sg_rules : rule.id => rule if rule.cidr_block != "" }

  type              = each.value.type
  from_port         = each.value.from_port != "" ? tonumber(each.value.from_port) : 0
  to_port           = each.value.to_port != "" ? tonumber(each.value.to_port) : 65535
  protocol          = each.value.protocol_type
  cidr_blocks       = [each.value.cidr_block]
  security_group_id = aws_security_group.this[each.value.sg_name].id
  description       = each.value.rule_description

  timeouts {
    create = "30s"
  }
}

# Security Group Type Rule
resource "aws_security_group_rule" "src_sg_rules" {
  for_each = { for rule in var.sg_rules : rule.id => rule if rule.src_sg != "" }

  type                     = each.value.type
  from_port                = each.value.from_port != "" ? tonumber(each.value.from_port) : 0
  to_port                  = each.value.to_port != "" ? tonumber(each.value.to_port) : 65535
  protocol                 = each.value.protocol_type
  source_security_group_id = each.value.src_sg != "" ? try(aws_security_group.this[each.value.src_sg].id, each.value.src_sg) : ""
  security_group_id        = aws_security_group.this[each.value.sg_name].id
  description              = each.value.rule_description

  timeouts {
    create = "30s"
  }
}

# Prefix Type Rule
resource "aws_security_group_rule" "prefix_rules" {
  for_each = { for rule in var.sg_rules : rule.id => rule if rule.prefix_id != "" }

  type              = each.value.type
  from_port         = each.value.from_port != "" ? tonumber(each.value.from_port) : 0
  to_port           = each.value.to_port != "" ? tonumber(each.value.to_port) : 65535
  protocol          = each.value.protocol_type
  prefix_list_ids   = each.value.prefix_id != "" ? try([each.value.prefix_id]) : []
  security_group_id = aws_security_group.this[each.value.sg_name].id
  description       = each.value.rule_description

  timeouts {
    create = "30s"
  }
}