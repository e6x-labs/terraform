# # Configure the AWS Provider
# provider "aws" {
#   region  = var.aws_region
#   # access_key = "<Access key ID>"
#   # secret_key = "<Secret access key>"
#   default_tags {
#     tags = var.cost_tags
#   }
# }

# terraform {
#   backend "s3" {
#     bucket = "mybucket"
#     key    = "path/to/my/key"
#     region = "us-east-1"
#   }
  
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "5.35.0"
#     }
#   } 
# }

terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
