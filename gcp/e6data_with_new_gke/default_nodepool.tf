resource "google_container_node_pool" "default_gke_cluster_nodepool" {
  name              = "e6data-${module.gke_e6data.gke_cluster_name}-default-node-pool"
  location          = var.gcp_region
  cluster           = module.gke_e6data.gke_cluster_name
  node_count        = 2
  version           = var.gke_version
  max_pods_per_node = 64

  node_config {
    disk_size_gb = 30

    spot = false
    machine_type = var.default_nodepool_instance_type

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    labels = {
        "app" = "e6data"
        "e6data-workspace-name" = "default"
    }
  }


  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    total_min_node_count = 2
    total_max_node_count = 3
    location_policy = "ANY"
  }

  lifecycle {
    ignore_changes = [node_count, autoscaling, node_config[0].labels, version]
  }
}