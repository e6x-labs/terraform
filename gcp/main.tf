# # Create GKE nodepool for workspace
resource "google_container_node_pool" "workspace" {
  name        = local.e6data_workspace_name
  /* location         = var.kubernetes_cluster_location */
  cluster          = data.google_container_cluster.gke_cluster.id
  initial_node_count = 0
  autoscaling {
    total_min_node_count = 0
    total_max_node_count = var.max_instances_in_nodegroup
    location_policy = "ANY"
  }
  node_config {
    spot  = true
    machine_type = var.nodegroup_instance_type
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      e6data-workspace-name                   = var.workspace_name
      app                                     = "e6data"
    }

    taint = [{
      key    = "e6data-workspace-name"
      value  = var.workspace_name
      effect = "NO_SCHEDULE"
    }]
  }
}

# # Create GCS bucket for workspace
resource "google_storage_bucket" "workspace_bucket" {
  name     = local.e6data_workspace_name
  location = var.gcp_region
}

# # Create service account for workspace
resource "google_service_account" "workspace_sa" {
  account_id   = local.e6data_workspace_name
  display_name = local.e6data_workspace_name
  description = "Service account for e6data workspace access"
}

# # Create IAM role for workspace write access on GCS bucket
resource "google_project_iam_custom_role" "workspace_write_role" {
  role_id     = local.workspace_write_role_name
  title       = "e6data ${var.workspace_name} Workspace Write Access"
  description = "Custom e6data workspace role for GCS write access "

  permissions = [
    "storage.objects.setIamPolicy",
    "storage.objects.getIamPolicy",
    "storage.objects.update",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.list",
  ]
}

# # Create IAM role for workspace read access on GCS buckets
resource "google_project_iam_custom_role" "workspace_read_role" {
  role_id     = local.workspace_read_role_name
  title       = "e6data ${var.workspace_name} Workspace Read Access"
  description = "Custom e6data workspace role for GCS read access"

  permissions = [
    "storage.objects.getIamPolicy",
    "storage.objects.get",
    "storage.objects.list",
  ]
}

# # Create IAM policy binding for workspace service account and GCS bucket write access
resource "google_project_iam_binding" "workspace_write_binding" {
  project = var.gcp_project_id
  role    = google_project_iam_custom_role.workspace_write_role.name

  members = [
    "serviceAccount:${google_service_account.workspace_sa.email}",
  ]

  condition {
    title       = "Workspace Write Access"
    description = "Write access to e6data workspace GCS bucket"
    expression  = "resource.name.startsWith(\"projects/_/buckets/${local.e6data_workspace_name}/\")"
  }

  depends_on = [ google_project_iam_custom_role.workspace_write_role, google_storage_bucket.workspace_bucket, google_service_account.workspace_sa ]
}

# Create IAM policy binding for workspace service account and GCS bucket read access
resource "google_project_iam_binding" "workspace_read_binding" {
  project = var.gcp_project_id
  role    = google_project_iam_custom_role.workspace_read_role.name

  members = [
    "serviceAccount:${google_service_account.workspace_sa.email}",
  ]

  depends_on = [ google_project_iam_custom_role.workspace_read_role, google_storage_bucket.workspace_bucket, google_service_account.workspace_sa ]
}

resource "google_project_iam_binding" "platform_gcs_read_binding" {
  project = var.gcp_project_id
  role    = google_project_iam_custom_role.workspace_write_role.name

  members = [
    "serviceAccount:${var.platform_sa_email}",
  ]

  condition {
    title       = "Workspace Read Access"
    description = "Read access to e6data workspace GCS bucket"
    expression  = "resource.name.startsWith(\"projects/_/buckets/${local.e6data_workspace_name}/\")"
  }

  depends_on = [ google_project_iam_custom_role.workspace_write_role, google_storage_bucket.workspace_bucket ]
}


resource "google_project_iam_custom_role" "e6dataclusterViewer" {
  role_id      = local.cluster_viewer_role_name
  title        = "e6data-${var.workspace_name}-clusterViewer"
  description  = "kubernetes container clusterViewer access"
  permissions  = [
    "container.clusters.get",
    "container.clusters.list",
    "resourcemanager.projects.get",
    "container.roleBindings.get"
  ]
  stage        = "GA"
  project      = var.gcp_project_id
}

# Create IAM policy binding for Platform Service and Kubernetes cluster
resource "google_project_iam_binding" "platform_ksa_mapping" {
  project = var.gcp_project_id
  role = google_project_iam_custom_role.e6dataclusterViewer.name
  members = [
    "serviceAccount:${var.platform_sa_email}",
  ]
}

resource "google_project_iam_custom_role" "workloadIdentityUser" {
  role_id      = local.workload_role_name
  title        = "e6data ${var.workspace_name} workloadIdentityUser Access"
  description  = "e6data custom workload identity user role"
  permissions  = [
     "iam.serviceAccounts.get",
    "iam.serviceAccounts.getAccessToken",
    "iam.serviceAccounts.getOpenIdToken",
    "iam.serviceAccounts.list"
  ]
  stage        = "GA"
  project      = var.gcp_project_id
}

# Create IAM policy binding for workspace service account and Kubernetes cluster
resource "google_project_iam_binding" "workspace_ksa_mapping" {
  project = var.gcp_project_id
  role = google_project_iam_custom_role.workloadIdentityUser.name
  members = [
    "serviceAccount:${var.gcp_project_id}.svc.id.goog[${var.kubernetes_namespace}/${var.workspace_name}]",
  ]
}