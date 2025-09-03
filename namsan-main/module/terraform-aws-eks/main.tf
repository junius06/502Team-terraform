locals {
  ng = flatten([for k, v in var.eks_cluster_info : [
    for key, ng in v.eks_node_group :
    {
      cluster              = k,
      launch_template_name = v.eks_launch_template[key].eks_launch_template_name
      node_group_name      = ng.eks_node_group_name
      node_group_role_arn  = ng.eks_node_group_role_arn
      node_group_subnets   = var.eks_node_group_subnet_id[key]
      node_group_scaling = {
        min_size     = ng.eks_node_group_scaling.min_size
        max_size     = ng.eks_node_group_scaling.max_size
        desired_size = ng.eks_node_group_scaling.desired_size
      }
      node_group_update_config = {
        max_unavailable_type  = ng.eks_node_group_update_config.max_unavailable_type
        max_unavailable_value = ng.eks_node_group_update_config.max_unavailable_value
      }
      node_group_tags = ng.eks_node_group_tags
    }
  ]])

  lt = flatten([for k, v in var.eks_cluster_info : [
    for key, lt in v.eks_launch_template :
    {
      cluster                        = k
      node_group_name                = v.eks_node_group[key].eks_node_group_name
      launch_template_name           = lt.eks_launch_template_name
      launch_template_ami            = lt.eks_launch_template_ami
      launch_template_instance_type  = lt.eks_launch_template_instance_type
      launch_template_security_group = var.eks_launch_template_sg_id[key]
      launch_template_root_volume = {
        volume_device_name = lt.eks_launch_template_root_volume.volume_device_name
        volume_size        = lt.eks_launch_template_root_volume.volume_size
        volume_type        = lt.eks_launch_template_root_volume.volume_type
        volume_iops        = lt.eks_launch_template_root_volume.volume_iops
        volume_kms_key_id  = lt.eks_launch_template_root_volume.volume_kms_key_id
      }
      launch_template_sub_volume    = lt.eks_launch_template_sub_volume
      launch_template_resource_tags = lt.eks_launch_template_resource_tags
      launch_template_tags          = lt.eks_launch_template_tags
    }
  ]])

  addon_list = flatten([for k, v in var.eks_cluster_info : [
    for addon in v.eks_cluster_addon :
    {
      cluster  = k,
      name     = addon.name,
      version  = addon.version
      role_arn = addon.role_arn
    }
  ]])

  #   launch_template_user_data = { for key, v in local.lt : v.launch_template_name => <<EOF
  # MIME-Version: 1.0
  # Content-Type: multipart/mixed; boundary="//"
  # --//
  # Content-Type: text/x-shellscript; charset="us-ascii"
  # #!/bin/bash
  # set -ex
  # B64_CLUSTER_CA=${aws_eks_cluster.this[v.cluster].certificate_authority[0].data}
  # API_SERVER_URL=${aws_eks_cluster.this[v.cluster].endpoint}
  # K8S_CLUSTER_DNS_IP=${cidrhost(aws_eks_cluster.this[v.cluster].kubernetes_network_config[0].service_ipv4_cidr, 10)}
  # /etc/eks/bootstrap.sh ${v.cluster} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${v.launch_template_ami},eks.amazonaws.com/nodegroup=${v.node_group_name} --max-pods=234' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL --dns-cluster-ip $K8S_CLUSTER_DNS_IP --use-max-pods false
  # --//--
  #     EOF
  #   }
  launch_template_user_data = { for key, v in local.lt : v.launch_template_name => <<EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster: 
    name: ${v.cluster}
    apiServerEndpoint: ${aws_eks_cluster.this[v.cluster].endpoint}
    certificateAuthority: ${aws_eks_cluster.this[v.cluster].certificate_authority[0].data}
    cidr: ${aws_eks_cluster.this[v.cluster].kubernetes_network_config[0].service_ipv4_cidr}

--BOUNDARY--
    EOF
  }

  access_list = flatten([for k, v in var.eks_cluster_info : [
    for access in v.eks_cluster_iam_access :
    {
      cluster    = k,
      iam_arn    = access.iam_arn,
      policy_arn = access.policy_arn
    }
  ]])

  pod_identity_list = flatten([for k, v in var.eks_cluster_info : [
    for identity in v.eks_cluster_pod_identity :
    {
      cluster         = k,
      iam_arn         = identity.iam_arn,
      namespace       = identity.namespace
      service_account = identity.service_account
    }
  ]])
}

##################################
# EKS Cluster
##################################
resource "aws_eks_cluster" "this" {
  for_each = var.eks_cluster_info

  name                      = each.value.eks_cluster_name
  version                   = each.value.eks_cluster_version
  role_arn                  = each.value.eks_cluster_role_arn
  enabled_cluster_log_types = each.value.eks_cluster_enabled_log_types
  tags                      = each.value.eks_cluster_tags

  access_config {
    authentication_mode                         = each.value.eks_cluster_auth_mode
    bootstrap_cluster_creator_admin_permissions = each.value.eks_cluster_allow_admin_access
  }

  vpc_config {
    security_group_ids      = var.eks_cluster_sg_id
    subnet_ids              = var.eks_cluster_subnet_id
    endpoint_public_access  = each.value.eks_cluster_public_endpoint_access
    endpoint_private_access = each.value.eks_cluster_private_endpoint_access
  }

  kubernetes_network_config {
    service_ipv4_cidr = each.value.eks_cluster_service_ipv4_cidr
    ip_family         = "ipv4"
  }

  dynamic "encryption_config" {
    for_each = each.value.eks_cluster_secret_enc_kms_key_arn != "" ? [1] : []

    content {
      provider {
        key_arn = each.value.eks_cluster_secret_enc_kms_key_arn
      }
      resources = ["secrets"]
    }
  }
}

##################################
# EKS Cluster Addon
##################################
resource "aws_eks_addon" "this" {
  for_each = { for k, v in local.addon_list : v.name => v }

  cluster_name             = aws_eks_cluster.this[each.value.cluster].name
  addon_name               = each.value.name
  addon_version            = each.value.version
  service_account_role_arn = try(each.value.role_arn, null)

  timeouts {
    create = "15m"
  }
  depends_on = [aws_eks_node_group.this] # aws_eks_node_group.this 필요! 그렇지 않으면 coredns 배포할 노드가 없어 coredns add_on 배포가 불가능
}

# ##################################
# # EKS Cluster Node Group
# ##################################
resource "aws_eks_node_group" "this" {
  for_each = { for k, v in local.ng : v.node_group_name => v }

  node_group_name = each.value.node_group_name
  cluster_name    = each.value.cluster
  node_role_arn   = each.value.node_group_role_arn
  subnet_ids      = each.value.node_group_subnets
  tags            = each.value.node_group_tags

  scaling_config {
    min_size     = each.value.node_group_scaling.min_size
    max_size     = each.value.node_group_scaling.max_size
    desired_size = each.value.node_group_scaling.desired_size
  }

  dynamic "launch_template" {
    for_each = each.value.launch_template_name != "" ? [each.value.launch_template_name] : []

    content {
      name    = aws_launch_template.this[each.value.launch_template_name].name
      version = aws_launch_template.this[each.value.launch_template_name].latest_version
    }
  }

  dynamic "update_config" {
    for_each = each.value.node_group_update_config != {} ? [each.value.node_group_update_config] : []

    content {
      max_unavailable_percentage = each.value.node_group_update_config.max_unavailable_type == "percent" ? update_config.value.max_unavailable_value : null
      max_unavailable            = each.value.node_group_update_config.max_unavailable_type == "number" ? update_config.value.max_unavailable_value : null
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size,
    ]
  }

  timeouts {
    create = "10m"
  }
}

# ##################################
# # EKS Cluster Launch Template
# ##################################
resource "aws_launch_template" "this" {
  for_each = { for k, v in local.lt : v.launch_template_name => v }

  name                   = each.value.launch_template_name
  image_id               = each.value.launch_template_ami
  instance_type          = each.value.launch_template_instance_type
  vpc_security_group_ids = each.value.launch_template_security_group #concat(each.value.launch_template_security_group, [aws_eks_cluster.this[each.value.cluster].vpc_config[0].cluster_security_group_id])
  update_default_version = true
  user_data              = base64encode(lookup(local.launch_template_user_data, each.value.launch_template_name, null))

  tags = each.value.launch_template_tags

  # root volume
  block_device_mappings {
    device_name = each.value.launch_template_root_volume.volume_device_name
    ebs {
      delete_on_termination = true
      volume_size           = each.value.launch_template_root_volume.volume_size
      volume_type           = each.value.launch_template_root_volume.volume_type
      iops                  = each.value.launch_template_root_volume.volume_iops
      encrypted             = each.value.launch_template_root_volume.volume_kms_key_id != "" ? true : false
      kms_key_id            = each.value.launch_template_root_volume.volume_kms_key_id
    }
  }

  # sub volume
  dynamic "block_device_mappings" {
    for_each = each.value.launch_template_sub_volume

    content {
      device_name = lookup(block_device_mappings.value, "volume_device_name", null)

      dynamic "ebs" {
        for_each = flatten([lookup(block_device_mappings.value, "volume_device_name", [])])
        content {
          delete_on_termination = true
          volume_size           = lookup(block_device_mappings.value, "volume_size", null)
          volume_type           = lookup(block_device_mappings.value, "volume_type", null)
          iops                  = lookup(block_device_mappings.value, "volume_iops", null)
          encrypted             = lookup(block_device_mappings.value, "volume_kms_key_id", null) != null ? true : false
          kms_key_id            = lookup(block_device_mappings.value, "volume_kms_key_id", null)
        }
      }
    }
  }

  #https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateTagSpecificationRequest.html
  dynamic "tag_specifications" {
    for_each = each.value.launch_template_resource_tags

    content {
      resource_type = lookup(tag_specifications.value, "resource_type", null)
      tags          = lookup(tag_specifications.value, "resource_tag", null)
    }
  }

  metadata_options {
    http_put_response_hop_limit = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

##################################
# EKS Cluster Access
##################################
resource "aws_eks_access_entry" "this" {
  for_each = { for k, v in local.access_list : split("/", "${v.iam_arn}")[1] => v if v.iam_arn != "" && length(split("/", "${v.iam_arn}")) == 2 }

  cluster_name  = aws_eks_cluster.this[each.value.cluster].name
  principal_arn = each.value.iam_arn
  type          = "STANDARD"
}

resource "aws_eks_access_entry" "service_role" {
  for_each = { for k, v in local.access_list : split("/", "${v.iam_arn}")[3] => v if v.iam_arn != "" && length(split("/", "${v.iam_arn}")) == 4 }

  cluster_name  = aws_eks_cluster.this[each.value.cluster].name
  principal_arn = each.value.iam_arn
  type          = "STANDARD"
}

resource "aws_eks_access_entry" "reserved_role" {
  for_each = { for k, v in local.access_list : split("/", "${v.iam_arn}")[4] => v if v.iam_arn != "" && length(split("/", "${v.iam_arn}")) == 5 }

  cluster_name  = aws_eks_cluster.this[each.value.cluster].name
  principal_arn = each.value.iam_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "this" {
  for_each = { for k, v in local.access_list : split("/", "${v.iam_arn}")[1] => v if v.iam_arn != "" && length(split("/", "${v.iam_arn}")) == 2 }

  cluster_name  = aws_eks_cluster.this[each.value.cluster].name
  principal_arn = each.value.iam_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type = "cluster"
    # namespaces = ["example-namespace"]
  }
}

resource "aws_eks_access_policy_association" "service_role" {
  for_each = { for k, v in local.access_list : split("/", "${v.iam_arn}")[3] => v if v.iam_arn != "" && length(split("/", "${v.iam_arn}")) == 4 }

  cluster_name  = aws_eks_cluster.this[each.value.cluster].name
  principal_arn = each.value.iam_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type = "cluster"
    # namespaces = ["example-namespace"]
  }
}

resource "aws_eks_access_policy_association" "reserved_role" {
  for_each = { for k, v in local.access_list : split("/", "${v.iam_arn}")[4] => v if v.iam_arn != "" && length(split("/", "${v.iam_arn}")) == 5 }

  cluster_name  = aws_eks_cluster.this[each.value.cluster].name
  principal_arn = each.value.iam_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type = "cluster"
    # namespaces = ["example-namespace"]
  }
}

##################################
# EKS Cluster Pod Identity
##################################
resource "aws_eks_pod_identity_association" "this" {
  for_each = { for k, v in local.pod_identity_list : split("/", "${v.iam_arn}")[1] => v if v.iam_arn != "" }

  cluster_name    = aws_eks_cluster.this[each.value.cluster].name
  role_arn        = each.value.iam_arn
  namespace       = each.value.namespace
  service_account = each.value.service_account
}

##################################
# EKS Cluster OIDC
##################################
data "tls_certificate" "this" {
  for_each = var.eks_cluster_info

  url = aws_eks_cluster.this[each.key].identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  for_each = var.eks_cluster_info

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this[each.key].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this[each.key].identity[0].oidc[0].issuer
}
