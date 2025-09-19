terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket               = "502team-fot"                            # tfstate 등 버킷이름
    key                  = "terraform-${env}/terraform.tfstate"     # 실제 키는 아래 prefix + workspace로 분리됨
    region               = "${region}"        # S3 버킷 리전
    # dynamodb_table       = "tfstate-locks"    # 락 테이블
    encrypt              = true
    workspace_key_prefix = "tfstate"          # 최종: 502team-fot/<workspace>/terraform-${env}/terraform.tfstate
  }
}