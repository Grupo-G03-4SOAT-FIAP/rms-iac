locals {
  region = "us-east-1"

  tags = {
    Project     = "rms"
    Terraform   = "true"
    Environment = "prod"
  }
}

/*
# Command shortcuts
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform apply --auto-approve
terraform apply -var "name=value"
terraform show
terraform destroy
terraform destroy --auto-approve
*/

module "network" {
  source = "./modules/network"

  region = local.region
  tags   = local.tags
}

module "db" {
  source = "./modules/db"

  region = local.region

  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets

  tags = local.tags
}

module "cluster_k8s" {
  source = "./modules/cluster_k8s"

  region = local.region

  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets

  app_namespace       = "rms" # O "name" do namespace do k8s onde será executada a sua aplicação
  serviceaccount_name = "eksdemo-secretmanager-sa"

  tags = local.tags
}

module "secrets_mercadopago" {
  source = "./modules/secrets-mercadopago"

  region              = local.region
  role_name_to_attach = module.cluster_k8s.serviceaccount_role_name
  tags                = local.tags
}

# Baseado no tutorial "Build and use a local module" do portal HashiCorp Developer em 
# https://developer.hashicorp.com/terraform/tutorials/modules/module-create
