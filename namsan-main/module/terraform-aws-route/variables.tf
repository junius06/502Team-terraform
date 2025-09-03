################################################################################
# Route
################################################################################
variable "route_rules" {
  type = list(object({
    dst_cidr_block = string
    id             = string
    route_table    = string
    target         = string
    target_type    = string
  }))
}

variable "target_nat_exist" {
  type    = list(string)
  default = null
}

variable "target_tgwa_exist" {
  type    = list(string)
  default = null
}

variable "target_gwlb_ep_exist" {
  type    = list(string)
  default = null
}

variable "target_nat_info" {
  type    = any
  default = null
}

variable "target_tgwa_info" {
  type    = any
  default = null
}

variable "target_gwlb_ep_info" {
  type    = any
  default = null
}

variable "pri_route_table_info" {
  type    = any
  default = null
}
