locals {
  iam_roles = { for file in fileset("./iam/role", "*.yaml") :
    trimsuffix(file, ".yaml") => yamldecode(file("./iam/role/${file}"))
  }
}

module "iam_role" {
  source = "../module/terraform-aws-iam-role"

  for_each = local.iam_roles

  iam_info = { for k, v in local.iam_roles[*][each.key] : each.key => v }
}
