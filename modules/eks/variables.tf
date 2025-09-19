variable "env"                 { type = string }
variable "cluster_name"        { type = string }
variable "cluster_version"     { type = string }

variable "vpc_id"              { type = string }
variable "private_subnet_ids"  { type = list(string) }

variable "mng_instance_types"  { type = list(string) }
variable "mng_min_size"        { type = number }
variable "mng_desired_size"    { type = number }
variable "mng_max_size"        { type = number }

variable "tags" { 
    type = map(string) 
    default = {} 
}