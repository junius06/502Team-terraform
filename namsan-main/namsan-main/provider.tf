terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

# TFE 사용 시, 아래 주석 해제 및 assume_role 사용 필요
provider "aws" {
  region = var.region
}