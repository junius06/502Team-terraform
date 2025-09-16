variable "aws_region" {
  type        = number
  description = "1=eu-west-1, 2=us-west-2"
  validation {
    condition     = var.aws_region == 1 || var.aws_region == 2
    error_message = "Choose 1 for eu-west-1 or 2 for us-west-2."
  }
}

locals {
  region_map = {
    1 = "eu-west-1"
    2 = "us-west-2"
  }
  aws_region = local.region_map[var.aws_region]
}

provider "aws" {
  region = local.aws_region
  profile = "502-${env}"
}