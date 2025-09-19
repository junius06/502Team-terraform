module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      instance_types = var.mng_instance_types
      min_size       = var.mng_min_size
      desired_size   = var.mng_desired_size
      max_size       = var.mng_max_size
    }
  }

  tags = merge({ Module = "eks", Environment = var.env }, var.tags)
}
