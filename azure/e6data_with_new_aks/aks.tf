module "aks_engine" {
  source                  = "./modules/aks_cluster"
  region                  = var.region
  cluster_name            = var.cluster_name
  kube_version            = var.kube_version
  private_cluster_enabled = var.private_cluster_enabled
  resource_group_name     = var.resource_group_name
  aks_subnet_id           = module.network.aks_subnet_id
  aci_subnet_name         = module.network.aci_subnet_name
  tags                    = var.cost_tags

  #default nodepool vars
  default_node_pool_vm_size    = var.default_node_pool_vm_size
  default_node_pool_node_count = var.default_node_pool_node_count
  default_node_pool_name       = var.default_node_pool_name
  default_node_pool_min_size   = var.default_node_pool_min_size
  default_node_pool_max_size   = var.default_node_pool_max_size

  #default nodepool autosacler
  scale_down_unneeded              = var.scale_down_unneeded
  scale_down_delay_after_add       = var.scale_down_delay_after_add
  scale_down_unready               = var.scale_down_unready
  scale_down_utilization_threshold = var.scale_down_utilization_threshold

  depends_on = [module.network]
}

provider "kubernetes" {
  alias                  = "engine"
  host                   = module.aks_engine.host
  cluster_ca_certificate = base64decode(module.aks_engine.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--login",
      "azurecli",
      "--environment",
      "AzurePublicCloud",
      "--tenant-id",
      data.azurerm_client_config.current.tenant_id,
      "--server-id",
      "",
      "|",
      "jq",
      ".status.token"
    ]
  }
}

provider "helm" {
  alias = "engine"
  kubernetes {
    host                   = module.aks_engine.host
    cluster_ca_certificate = base64decode(module.aks_engine.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args = [
        "get-token",
        "--login",
        "azurecli",
        "--environment",
        "AzurePublicCloud",
        "--tenant-id",
        data.azurerm_client_config.current.tenant_id,
        "--server-id",
        "",
        "|",
        "jq",
        ".status.token"
      ]
    }
  }
}

resource "kubernetes_namespace" "engine_namespace" {
  provider = kubernetes.engine
  for_each = var.engine_namespaces

  metadata {
    annotations = {
      name = each.key
    }
    name = each.key
  }

  depends_on = [module.aks_engine]
}
