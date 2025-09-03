################################################################################
# Security Group
################################################################################
variable "sg_rules" {
  type = list(object({
    id               = string
    sg_name          = string
    rule_description = string
    from_port        = string
    to_port          = string
    protocol_type    = string
    cidr_block       = string
    prefix_id        = string
    src_sg           = string
    type             = string
  }))
}

variable "vpc_id" {
  type = string
}