provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
}

module "db" {
  source = "./modules/db"
}

module "cluster_k8s" {
  source = "./modules/cluster_k8s"
}

# Baseado no tutorial "Build and use a local module" do portal HashiCorp Developer em 
# https://developer.hashicorp.com/terraform/tutorials/modules/module-create
