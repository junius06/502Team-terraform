locals {
  s3s = { for file in fileset("./s3", "*.yaml") :
    trimsuffix(file, ".yaml") => yamldecode(file("./s3/${file}"))
  }
}

module "s3" {
  source = "../module/terraform-aws-s3"

  for_each = local.s3s

  s3_info = { for k, v in local.s3s[*][each.key] : each.key => v }
}