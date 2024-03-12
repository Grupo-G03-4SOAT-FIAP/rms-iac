provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"
}

module "db" {
  source = "./modules/db"

  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
}

module "cluster_k8s" {
  source = "./modules/cluster_k8s"

  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
}

# Baseado no tutorial "Build and use a local module" do portal HashiCorp Developer em 
# https://developer.hashicorp.com/terraform/tutorials/modules/module-create
