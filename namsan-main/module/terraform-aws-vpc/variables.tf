################################################################################
# Common
################################################################################
variable "region" {
  type = string
}

################################################################################
# VPC
################################################################################
variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  description = "CIDR Block for the VPC"
  type        = string
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "public_subnet" {
  description = "Map of public subnets"
  type = list(object({
    subnet_cidr = string
    tags        = map(string)
  }))
}

variable "private_subnet" {
  description = "Map of private subnets"
  type = list(object({
    subnet_cidr = string
    tags        = map(string)
  }))
}

variable "vpc_flow_log_s3_name" {
  description = "VPC Flow Log S3 Bucket Name"
  type        = string
}

################################################################################
# NAT Gateway
################################################################################
variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway_subnet" {
  type    = string
  default = null
}