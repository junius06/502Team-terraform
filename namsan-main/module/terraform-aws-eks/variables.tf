################################################################################
# EKS
################################################################################
variable "eks_cluster_info" {
  type = map(object({
    eks_cluster_name                    = string
    eks_cluster_version                 = string
    eks_cluster_role_arn                = string
    eks_cluster_auth_mode               = string
    eks_cluster_allow_admin_access      = string
    eks_cluster_secret_enc_kms_key_arn  = string
    eks_cluster_tags                    = map(string)
    eks_cluster_vpc                     = string
    eks_cluster_subnets                 = list(string)
    eks_cluster_security_group          = list(string)
    eks_cluster_public_endpoint_access  = string
    eks_cluster_private_endpoint_access = string
    eks_cluster_service_ipv4_cidr       = string
    eks_cluster_enabled_log_types       = list(string)
    eks_cluster_addon = list(object({
      name     = string
      version  = string
      role_arn = string
    }))
    eks_node_group = list(object({
      eks_node_group_name     = string
      eks_node_group_role_arn = string
      eks_node_group_subnets  = list(string)
      eks_node_group_scaling = object({
        min_size     = string
        max_size     = string
        desired_size = string
      })
      eks_node_group_update_config = object({
        max_unavailable_type  = string
        max_unavailable_value = string
      })
      eks_node_group_tags = map(string)
    }))
    eks_launch_template = list(object({
      eks_launch_template_name           = string
      eks_launch_template_ami            = string
      eks_launch_template_instance_type  = string
      eks_launch_template_security_group = list(string)
      eks_launch_template_root_volume = object({
        volume_device_name = string
        volume_size        = string
        volume_type        = string
        volume_iops        = string
        volume_kms_key_id  = string
      })
      eks_launch_template_sub_volume = list(object({
        volume_device_name = string
        volume_size        = string
        volume_type        = string
        volume_iops        = string
        volume_kms_key_id  = string
      }))
      eks_launch_template_resource_tags = list(object({
        resource_type = string
        resource_tag  = map(string)
      }))
      eks_launch_template_tags = map(string)
    }))
    eks_cluster_iam_access = list(object({
      iam_arn    = string
      policy_arn = string
    }))
    eks_cluster_pod_identity = list(object({
      iam_arn         = string
      namespace       = string
      service_account = string
    }))
  }))
}

variable "eks_cluster_sg_id" {
  type = list(string)
}

variable "eks_cluster_subnet_id" {
  type = list(string)
}

variable "eks_node_group_subnet_id" {
  type = any
}

variable "eks_launch_template_sg_id" {
  type = any
}
