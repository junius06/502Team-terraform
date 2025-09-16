locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals.env
  region = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals.region
}

# 원격 상태 저장 (S3) 자동 생성
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "tfstate-${local.env}"
    key            = "s3/${local.env}/${path_relative_to_include()}.tfstate"
    region         = local.region
    dynamodb_table = "tfstate-locks"
    encrypt        = true
  }
}

# AWS provider 자동 생성
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" { 
  region = "${local.region}"
}
EOF
}