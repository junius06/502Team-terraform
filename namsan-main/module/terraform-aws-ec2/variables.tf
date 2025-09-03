################################################################################
# EC2
################################################################################
variable "ec2_list" {
  type = map(object({
    ec2_vpc           = string
    ec2_iam_profile   = string
    ec2_ami           = string
    ec2_instance_type = string
    ec2_keypair       = string
    ec2_root_eni = object({
      ec2_root_eni_subnet            = string
      ec2_root_eni_ip                = string
      ec2_root_eni_sg                = list(string)
      ec2_root_eni_source_dest_check = string
    })
    ec2_sub_eni = list(object({
      ec2_sub_eni_subnet            = string
      ec2_sub_eni_ip                = string
      ec2_sub_eni_sg                = list(string)
      ec2_sub_eni_source_dest_check = string
    }))
    ec2_root_volume = object({
      ec2_root_volume_type       = string
      ec2_root_volume_iops       = string
      ec2_root_volume_throughput = string
      ec2_root_volume_size       = string
      ec2_root_volume_sub_tag    = map(string)
    })
    ec2_sub_volume = list(object({
      ec2_sub_volume_device_name       = string
      ec2_sub_volume_type              = string
      ec2_sub_volume_size              = string
      ec2_sub_volume_iops              = string
      ec2_sub_volume_throughput        = string
      ec2_sub_volume_availability_zone = string
      ec2_sub_volume_sub_tag           = map(string)
    }))
    ec2_encrypt        = string
    ec2_kms_key_arn    = string
    ec2_user_data_file = string
    ec2_tags           = map(string)
  }))
}

variable "ec2_root_eni_info" {
  type = object({
    ec2_name                       = string
    ec2_root_eni_subnet            = string
    ec2_root_eni_ip                = string
    ec2_root_eni_sg                = list(string)
    ec2_root_eni_source_dest_check = string
  })
}

variable "ec2_sub_eni_info" {
  type = map(object({
    ec2_name                      = string
    ec2_sub_eni_subnet            = string
    ec2_sub_eni_ip                = string
    ec2_sub_eni_sg                = list(string)
    ec2_sub_eni_source_dest_check = string
  }))
}

variable "ec2_user_data" {
  type = string
}
