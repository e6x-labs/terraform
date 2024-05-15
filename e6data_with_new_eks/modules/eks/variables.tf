variable "kube_version" {
  type        = string
  description = "kubernetes master version"
}

variable "cluster_name" {
  type        = string
  description = "Name of kubernetes cluster"
}

variable "cluster_log_types" {
  type        = list(string)
  description = "EKS Cluster enabled log types to Cloudwatch"
  default     = ["scheduler", "controllerManager"]
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet ids for eks cluster"
}

variable "vpc_id" {
  type        = string
  description = "vpc id of e6x"
}

variable "iam_eks_cluster_policy_arn" {
  type        = list(string)
  description = "List of Policies to attach to the EKS cluster role"
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]
}

variable "private_subnet_ids" {
  type = list(string)
  description = "private subnet IDs"
}

variable "public_access_cidrs" {
  type = list(string)
  description = "public access cidrs"
}

variable "endpoint_private_access" {
  type = bool
  description = "whether to enable private access to the eks cluster"
}