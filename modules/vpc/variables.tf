variable "vpc_name"               { type = string }
variable "Project"                { type = string }

variable "env"                    { type = string }
variable "name_suffix"            { type = string }
variable "cidr"                   { type = string }
variable "az"                     { type = string }

# variables/{env}/{env}.tfvars 에서 추가한 지역 코드 (예: ["uw-2","ew-2"])
variable "region_code"            { type = string }

# full AZs (예: ["uw-2a","uw-2c"])
variable "azs"                    { type = list(string) }

# CIDR 목록 개수는 azs 길이와 같아야 함
variable "private_subnets"        { type = list(string) }
variable "public_subnets"         { type = list(string) }

# 선택 값들
variable "enable_nat_gateway"     { type = bool }
variable "single_nat_gateway"     { type = bool }
variable "one_nat_gateway_per_az" { type = bool }

variable "tags" { 
    type = map(string) 
    default = {} 
}