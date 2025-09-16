locals {
    common_tags = merge({ Module = "addons" }, var.tags)
}

# AWS Load Balancer Controller용 IRSA 예시 (IAM 역할은 따로 관리하는 것을 권장)
resource "helm_release" "aws_load_balancer_controller" {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    repository = "https://aws.github.io/eks-charts"
    chart = "aws-load-balancer-controller"
    version = var.alb_controller_version


    values = [jsonencode({
        clusterName = var.cluster_name
        serviceAccount = {
            create = true
            name = "aws-load-balancer-controller"
            annotations = {
                "eks.amazonaws.com/role-arn" = var.alb_controller_irsa_role_arn
            }
        }
    })]
}

resource "helm_release" "metrics_server" {
    name = "metrics-server"
    namespace = "kube-system"
    repository = "https://kubernetes-sigs.github.io/metrics-server/"
    chart = "metrics-server"
    version = var.metrics_server_version
}

resource "helm_release" "cluster_autoscaler" {
    name = "cluster-autoscaler"
    namespace = "kube-system"
    repository = "https://kubernetes.github.io/autoscaler"
    chart = "cluster-autoscaler"
    version = var.cluster_autoscaler_version


    values = [jsonencode({
        autoDiscovery = { clusterName = var.cluster_name }
        rbac = { 
            serviceAccount = { 
                annotations = { "
                    eks.amazonaws.com/role-arn" = var.autoscaler_irsa_role_arn 
                } 
            }
        }
    })]
}

output "addons" {
    value = {
        alb_controller = helm_release.aws_load_balancer_controller.status
        metrics_server = helm_release.metrics_server.status
        cluster_autoscaler = helm_release.cluster_autoscaler.status
    }
}