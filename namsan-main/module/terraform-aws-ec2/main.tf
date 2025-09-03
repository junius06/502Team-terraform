locals {
  ###############################################
  # EBS 볼륨 암호화 여부 체크
  ###############################################
  ec2_encrypt     = [for k, v in var.ec2_list : v.ec2_encrypt][0]
  ec2_kms_key_arn = [for k, v in var.ec2_list : v.ec2_kms_key_arn][0]

  ###############################################
  # EBS 볼륨 생성을 위한 볼륨 정보 재조립
  ###############################################
  # EBS 서브 볼륨 정보 list to map로 변환
  # "ec2-an2-mkkim-dev-firewall-01a" = {
  # "0" = {
  #   "ec2_sub_volume_device_name"       = "/dev/sdb"
  #   "ec2_sub_volume_size"              = 20
  #   "ec2_sub_volume_type"              = "gp2"
  #   "ec2_sub_volume_availability_zone" = "ap-northeast-2a"
  # }
  ec2_sub_vol = { for key, devices in var.ec2_list : key => {
    for k, v in devices.ec2_sub_volume : k => v
    } if devices.ec2_sub_volume != null
  }

  # EBS 볼륨명을 Key로 가진 map 형태로 ec2 서브 볼륨 정보 재조립
  # "ec2-an2-mkkim-dev-firewall-01a-0" = {
  #   "ec2_sub_volume_device_name"       = "/dev/sdb"
  #   "ec2_sub_volume_size"              = 20
  #   "ec2_sub_volume_type"              = "gp2"
  #   "ec2_sub_volume_availability_zone" = "ap-northeast-2a"
  #               }
  ec2_sub_vol_convert = merge([
    for key, value in local.ec2_sub_vol :
    { for index, item in value :
      "${key}-${index}" => item
    }
  ]...) # ...은 리스트 병합 연산자

  ###############################################
  # EBS 볼륨 Attach를 위한 변수 재조립
  ###############################################
  # "EBS 볼륨명" = "디바이스명" 형태로 재조립
  # "ec2-an2-mkkim-dev-firewall-01a-0" = "/dev/sdb"
  ec2_sub_vol_attach_device_name = { for k, v in local.ec2_sub_vol_convert : k => v.ec2_sub_volume_device_name }

  # "EBS 볼륨명" = "볼륨 ID" 형태로 재조립
  # "ec2-an2-mkkim-dev-firewall-01a-0" = "vol-0505d2bde5aec1da1"
  ec2_sub_vol_attach_ebs_id = { for k, v in aws_ebs_volume.this : replace(k, "vol", "ec2") => v.id }

  # "EBS 볼륨명" = ["디바이스명","볼륨 ID"] 형태로 재조립
  # "ec2-an2-mkkim-dev-firewall-01a-0" = [
  #   "/dev/sdb",
  #   "vol-0505d2bde5aec1da1",
  # ]
  ec2_sub_vol_attach_info = {
    for key in distinct(concat(keys(local.ec2_sub_vol_attach_device_name), keys(local.ec2_sub_vol_attach_ebs_id))) :
    key => flatten([lookup(local.ec2_sub_vol_attach_device_name, key, []),
      lookup(local.ec2_sub_vol_attach_ebs_id, key, [])
    ])
  }
}

###############################################
# EC2 Instance
###############################################
resource "aws_instance" "this" {
  for_each             = var.ec2_list
  iam_instance_profile = each.value.ec2_iam_profile != "" ? each.value.ec2_iam_profile : ""
  ami                  = each.value.ec2_ami
  key_name             = each.value.ec2_keypair != "" ? each.value.ec2_keypair : null
  instance_type        = each.value.ec2_instance_type

  root_block_device {
    encrypted  = local.ec2_encrypt
    kms_key_id = local.ec2_encrypt == "true" ? local.ec2_kms_key_arn : null

    delete_on_termination = true
    volume_type           = each.value.ec2_root_volume.ec2_root_volume_type
    volume_size           = each.value.ec2_root_volume.ec2_root_volume_size
    iops                  = contains(["io1", "io2", "gp3"], each.value.ec2_root_volume.ec2_root_volume_type) && each.value.ec2_root_volume.ec2_root_volume_iops != "" ? each.value.ec2_root_volume.ec2_root_volume_iops : null
    throughput            = contains(["gp3"], each.value.ec2_root_volume.ec2_root_volume_type) && each.value.ec2_root_volume.ec2_root_volume_throughput != "" ? each.value.ec2_root_volume.ec2_root_volume_throughput : null

    tags = merge({ Name = "${replace(each.key, "ec2", "vol")}-root" }, try(each.value.ec2_root_volume.ec2_root_volume_sub_tag, {}))
  }

  # root network interface Attach
  network_interface {
    network_interface_id = aws_network_interface.root[0].id
    device_index         = 0
    #delete_on_termination = "true" # true 할 시 에러 발생 가능성 있음
  }

  user_data = try(var.ec2_user_data, null)
  tags      = each.value.ec2_tags
}

###############################################
# EC2 EBS Volume
###############################################
resource "aws_ebs_volume" "this" {
  for_each = { for k, v in local.ec2_sub_vol_convert : replace(k, "ec2", "vol") => v if local.ec2_sub_vol_convert != null }

  encrypted  = local.ec2_encrypt
  kms_key_id = local.ec2_encrypt == "true" ? local.ec2_kms_key_arn : null

  type              = each.value.ec2_sub_volume_type
  iops              = contains(["io1", "io2", "gp3"], each.value.ec2_sub_volume_type) && each.value.ec2_sub_volume_iops != "" ? each.value.ec2_sub_volume_iops : null
  throughput        = contains(["gp3"], each.value.ec2_sub_volume_type) && each.value.ec2_sub_volume_throughput != "" ? each.value.ec2_sub_volume_throughput : null
  size              = each.value.ec2_sub_volume_size
  availability_zone = each.value.ec2_sub_volume_availability_zone

  tags = merge({ Name = each.key }, try(each.value.ec2_sub_volume_sub_tag, {}))
}

resource "aws_volume_attachment" "this" {
  for_each = { for k, v in local.ec2_sub_vol_attach_info : replace(k, "ec2", "vola") => v }

  device_name = each.value[0]
  volume_id   = each.value[1]
  instance_id = aws_instance.this[regex("^(.+)-[^-]+$", replace(each.key, "vola", "ec2"))[0]].id # vola-an2-mkkim-dev-firewall-01a-0 => ec2-an2-mkkim-dev-firewall-01a 변환
}

###############################################
# EC2 Network Interface
###############################################
# root network interface
resource "aws_network_interface" "root" {
  for_each = { for k, v in [var.ec2_root_eni_info] : k => v }

  subnet_id         = each.value.ec2_root_eni_subnet
  private_ips       = [each.value.ec2_root_eni_ip]
  security_groups   = each.value.ec2_root_eni_sg
  source_dest_check = each.value.ec2_root_eni_source_dest_check
}

# sub network interface
resource "aws_network_interface" "sub" {
  for_each = { for k, v in var.ec2_sub_eni_info : k + 1 => v if var.ec2_sub_eni_info != {} } # k + 1은 배열 인덱스 0번을 사용할 경우 root eni device_index 와 겹치므로 사용

  subnet_id         = each.value.ec2_sub_eni_subnet
  private_ips       = [each.value.ec2_sub_eni_ip]
  security_groups   = each.value.ec2_sub_eni_sg
  source_dest_check = each.value.ec2_sub_eni_source_dest_check

  attachment {
    instance     = aws_instance.this[each.value.ec2_name].id
    device_index = each.key # root eni device_index 와 겹치지 않게 key 값에서 + 1
  }
}

