provider "aws" {
  region = local.region
}

locals {
  region = var.region

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

module "cluster_k8s" {
  source = "./modules/cluster_k8s"

  region = local.region

  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets

  app_namespace       = "rms" # O 'name' do namespace do k8s onde será executada a sua aplicação
  serviceaccount_name = "aws-iam-serviceaccount"

  tags = local.tags
}

module "registry" {
  source = "./modules/registry"

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

module "secrets_db" {
  source = "./modules/secrets-db"

  rds_address    = module.db.rds_address
  rds_port       = module.db.rds_port
  rds_identifier = module.db.rds_identifier
  rds_engine     = module.db.rds_engine

  region = local.region
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "db_secret_to_role" {
  role       = module.cluster_k8s.serviceaccount_role_name
  policy_arn = module.secrets_db.secretsmanager_secret_policy_arn

  depends_on = [
    module.cluster_k8s,
    module.db
  ]
}

module "secrets_mercadopago" {
  source = "./modules/secrets-mercadopago"

  region = local.region
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "mercadopago_secret_to_role" {
  role       = module.cluster_k8s.serviceaccount_role_name
  policy_arn = module.secrets_mercadopago.secretsmanager_secret_policy_arn

  depends_on = [
    module.cluster_k8s,
    module.secrets_mercadopago
  ]
}

module "cognito_ciam" {
  source = "./modules/cognito-ciam"

  region = local.region
  tags   = local.tags
}

module "secrets_cognito" {
  source = "./modules/secrets-cognito"

  cognito_user_pool_id        = module.cognito_ciam.cognito_user_pool_id
  cognito_user_pool_client_id = module.cognito_ciam.cognito_user_pool_client_id

  region = local.region
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "cognito_secret_to_role" {
  role       = module.cluster_k8s.serviceaccount_role_name
  policy_arn = module.secrets_cognito.secretsmanager_secret_policy_arn

  depends_on = [
    module.cluster_k8s,
    module.cognito_ciam,
    module.secrets_cognito
  ]
}

# Baseado no tutorial "Build and use a local module" do portal HashiCorp Developer em 
# https://developer.hashicorp.com/terraform/tutorials/modules/module-create
