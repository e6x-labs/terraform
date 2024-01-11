data "aws_iam_policy_document" "alb_controller_access_doc" {
  statement {
    actions = [
      "iam:CreateServiceLinkedRole"
   ]
    resources = ["*"]
    condition {
      test    = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }
  }

  statement {
    actions = [
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeVpcs",
        "ec2:DescribeVpcPeeringConnections",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeInstances",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeTags",
        "ec2:GetCoipPoolUsage",
        "ec2:DescribeCoipPools",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:DescribeTags"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
        "cognito-idp:DescribeUserPoolClient",
        "acm:ListCertificates",
        "acm:DescribeCertificate",
        "iam:ListServerCertificates",
        "iam:GetServerCertificate",
        "waf-regional:GetWebACL",
        "waf-regional:GetWebACLForResource",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL",
        "wafv2:GetWebACL",
        "wafv2:GetWebACLForResource",
        "wafv2:AssociateWebACL",
        "wafv2:DisassociateWebACL",
        "shield:GetSubscriptionState",
        "shield:DescribeProtection",
        "shield:CreateProtection",
        "shield:DeleteProtection"
    ]
    resources = ["*"]
  }

  statement {
    actions = [ 
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
        "ec2:CreateTags"
    ]
    resources = ["arn:aws:ec2:*:*:security-group/*"]
    condition {
      test = "StringEquals"
      variable = "ec2:CreateAction"
      values = ["CreateSecurityGroup"]
    }
    condition {
        test = "Null"
        variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
        values = ["false"]
    }
  }

  statement {
    actions =[
        "ec2:CreateTags",
        "ec2:DeleteTags"
    ]
    resources = ["arn:aws:ec2:*:*:security-group/*"]
    condition {
      test = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values = ["true"]
    }

    condition {
      test = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values = ["false"]
    }
  }

  statement {
    actions = [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DeleteSecurityGroup"
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values = ["true"]
    }
  }

  statement {
    actions = [
        # "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateTargetGroup"
    ]
    resources = ["*"]
    condition {
        test = "Null"
        variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
        values = ["false"]
    }
  }

  statement {
    actions = [
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:RemoveTags"
    ]
    resources = [
        "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
        "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*", 
        "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
    ]
    condition {
        test = "Null"
        variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
        values = ["true"]
    }
    condition {
        test = "Null"
        variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
        values = ["false"]
    }
  }

  statement {
    actions = [
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:DeleteRule"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        # "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:DeleteTargetGroup"
    ]
    resources = ["*"]
    condition {
        test = "Null"
        variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
        values = ["false"]
    }
  }

  statement {
    actions = [
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:RemoveTags"
    ]
    resources = [
        "arn:aws:elasticloadbalancing:*:*:listener/net/*/*",
        "arn:aws:elasticloadbalancing:*:*:listener/app/*/*", 
        "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*",
        "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*", 
        "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
        "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
    ]
  }
  
  statement {
    actions = [
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets"
    ]
    resources = ["arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"]
  }

  statement {
    actions = [
        "elasticloadbalancing:SetWebAcl",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:ModifyRule"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "alb_controller_policy" {
  name = "${module.eks.cluster_name}-alb-controller-policy"
  description = "EKS cluster ALB controller policy for cluster ${module.eks.cluster_name}"
  policy      = data.aws_iam_policy_document.alb_controller_access_doc.json
}

module "alb_controller_oidc" {
  source = "./modules/aws_oidc"

  providers = {
    kubernetes = kubernetes.e6data
  }

  tls_url = module.eks.eks_oidc_tls
  policy_arn = [aws_iam_policy.alb_controller_policy.arn]
  eks_oidc_arn = module.eks.oidc_arn

  oidc_role_name = "${module.eks.cluster_name}-alb-controller"

  kubernetes_namespace = var.alb_ingress_controller_namespace
  kubernetes_service_account_name = var.alb_ingress_controller_service_account_name

  depends_on = [ module.eks, aws_eks_node_group.workspace_node_group ]
}

resource "aws_ec2_tag" "subnet_cluster_tag" {
  count    =    length(module.network.public_subnet_ids)
  resource_id = module.network.public_subnet_ids[count.index]
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "private_subnet_cluster_tag" {
  count    =    length(module.network.private_subnet_ids)
  resource_id = module.network.private_subnet_ids[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

data "aws_elb_service_account" "main" {}

module "aws_ingress_controller" {
  source = "./modules/alb_controller"

  providers = {
    kubernetes = kubernetes.e6data
    helm       = helm.e6data
  }

  eks_cluster_name = module.eks.cluster_name

  eks_service_account_name = module.alb_controller_oidc.service_account_name
  namespace = module.alb_controller_oidc.kubernetes_namespace
  alb_ingress_controller_version = var.alb_controller_helm_chart_version # "1.4.7"

  region = var.aws_region
  vpc_id = module.network.vpc_id

  depends_on = [ module.alb_controller_oidc, module.autoscaler_deployment, aws_eks_node_group.workspace_node_group]
}

module "lb_sec_grp" {
  source = "./modules/security_group"

  service_ports  = [443]
  sec_grp_name   = "demotest loadbalancer sec grp"
  vpc_id         = module.network.vpc_id
  cidr_block     = ["0.0.0.0/0"]
}

resource "aws_lb" "lb" {
  name               = "e6data-${var.workspace_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.lb_sec_grp.id]
  subnets            = module.network.public_subnet_ids
  idle_timeout       = "1200"

  enable_deletion_protection = true

  tags = {
    "ingress.k8s.aws/stack" = var.workspace_name
    "ingress.k8s.aws/resource" = "LoadBalancer"
    "elbv2.k8s.aws/cluster"    = module.eks.cluster_name
    "alb.ingress.kubernetes.io/group.name" = var.workspace_name
    "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    # "alb.ingress.kubernetes.io/target-type" = "ip"
  }

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}

resource "kubernetes_ingress_v1" "default_ingress" {
  provider = kubernetes.e6data

  metadata {
    name = "dummy-ingress"
    namespace = var.kubernetes_namespace
    annotations = {
    "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    "alb.ingress.kubernetes.io/group.name" = var.workspace_name
    // "alb.ingress.kubernetes.io/security-groups" = var.security_group_id
    // "alb.ingress.kubernetes.io/ssl-redirect" = "443"
    "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-east-1:245069423449:certificate/002959e7-1d83-44de-a525-a63851e398c0"
    "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\":443}]"
    "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
    "alb.ingress.kubernetes.io/target-type" = "instance"
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      host = "dummy-ingress.abc.io"
      http {
        path {
          backend {
            service {
              name = "dummy-ingress"
              port {
                number = 80
              }
            }
          }
        }  
      }
    }
  }
}  