# GCP Variables
gcp_region                          = "us-central1"                   # The region where the e6data resources will be created
gcp_project_id                      = "proven-outpost-351604"          # The ID of the GCP project

# e6data Workspace Variables
workspace_name                      = "connectivity"                   # The name of the e6data workspace

helm_chart_version                  = "1.0.7"                        ### e6data workspace Helm chart version to be used.

# Network Variables
gke_subnet_ip_cidr_range            = "10.100.0.0/18"                 # The subnet IP range for GKE

gke_e6data_master_ipv4_cidr_block   = "10.103.4.0/28" 
# The IP range in CIDR notation to use for the hosted master network
# This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP
# This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet

# Kubernetes Variables
gke_version                         = "1.27.7-gke.1121002"                          # The version of GKE to use                
gke_encryption_state                = "DECRYPTED"                     # The encryption state for GKE (It is recommended to use encryption)
gke_dns_cache_enabled               = true                            # The status of the NodeLocal DNSCache addon.
spot_enabled                        = true                            # A boolean that represents whether the underlying node VMs are spot.

# GKE Cluster variables
cluster_name                        = "connectivity"                   # The name of the GKE cluster
default_nodepool_instance_type      = "e2-standard-2"                     # The default instance type for the node pool

gke_e6data_initial_node_count       = 1                               # The initial number of nodes in the GKE cluster
gke_e6data_max_pods_per_node        = 64                              # The maximum number of pods per node in the GKE cluster
gke_e6data_instance_type            = "c2-standard-30"                # The instance type for the GKE nodes
max_instances_in_nodepool          = 50                              # The maximum number of instances in a node group

# Kubernetes Namespace
kubernetes_namespace                = "connectivity"                   # The namespace to use for Kubernetes resources

# Cost Labels
cost_labels = {
  team = "plt"
  operation = "poc"
  environment = "dev"
  app = "e6data"
  user = "plat"
  permanent = "true"
}                            # Cost labels for tracking costs

buckets                             = ["*"]                           ### List of bucket names that the e6data engine queries and therefore, require read access to. Default is ["*"] which means all buckets, it is advisable to change this.