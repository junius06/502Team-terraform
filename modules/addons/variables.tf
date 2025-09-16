variable "cluster_name" { type = string }


variable "alb_controller_irsa_role_arn" { type = string }
variable "autoscaler_irsa_role_arn" { type = string }


variable "alb_controller_version" { 
    type = string 
    default = "1.8.1" 
}
variable "metrics_server_version" { 
    type = string 
    default = "3.12.1" 
}
variable "cluster_autoscaler_version" { 
    type = string 
    default = "9.29.0" 
}

variable "tags" { 
    type = map(string) 
    default = {}
}