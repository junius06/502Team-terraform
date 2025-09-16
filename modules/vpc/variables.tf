variable "env"              { type = string }
variable "name"             { type = string }
variable "cidr"             { type = string }
variable "azs"              { type = list(string) }
variable "private_subnets"  { type = list(string) }
variable "public_subnets"   { type = list(string) }

variable "nat_gateway" {
  type = object({
    enable      = bool
    single      = bool
    one_per_az  = bool
  })
  default = {
    enable      = true
    single      = true
    one_per_az  = false
  }
}

variable "tags" { 
    type = map(string) 
    default = {} 
}