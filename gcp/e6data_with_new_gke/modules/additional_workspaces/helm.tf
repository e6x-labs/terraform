terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "helm_release" "e6data_workspace_deployment" {
  for_each = { for idx, workspace in var.workspaces : workspace.name => workspace }

  name             = each.key
  repository       = "https://e6data.github.io/helm-charts/"
  chart            = "workspace"
  namespace        = each.value.namespace
  create_namespace = true
  version          = var.helm_chart_version
  timeout          = 600

  values = [
    yamlencode({
      cloud = {
        type               = "GCP"
        oidc_value         = each.value.serviceaccount_create ? local.service_accounts[each.value.name] : each.value.serviceaccount_email
        control_plane_user = var.control_plane_user
      }
    })
  ]
}
