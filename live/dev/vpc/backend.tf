terraform {
    backend "s3" {
        bucket = "tfstate-dev"
        key = "./s3/dev/vpc.tfstate"
        region = var.aws_region
        dynamodb_table = "tfstate-locks"    # 변경
        encrypt = true
    }
    required_version = ">= 1.6.0"
}