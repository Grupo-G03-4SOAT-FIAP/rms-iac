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
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform apply --auto-approve
terraform apply -var "name=value"
terraform show
terraform destroy
terraform destroy --auto-approve
*/

/*
# Para provisionar somente um módulo específico:
terraform plan -target="module.cognito_idp"
terraform apply -target="module.cognito_idp"
terraform destroy -target="module.cognito_idp"
*/

/*
# Para remover um recurso específico do tfstate:
terraform state rm "module.cluster_k8s.kubernetes_namespace_v1.rms"
*/

################################################################################
# Network
################################################################################

module "network" {
  source = "./modules/network"

  region = local.region
  tags   = local.tags
}

################################################################################
# Kubernetes
################################################################################

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

################################################################################
# Database
################################################################################

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

################################################################################
# Secrets
################################################################################

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

################################################################################
# Identity provider (IdP)
################################################################################

module "cognito_idp" {
  source = "./modules/cognito-idp"

  region = local.region
  tags   = local.tags
}

module "secrets_cognito" {
  source = "./modules/secrets-cognito"

  cognito_user_pool_id        = module.cognito_idp.cognito_user_pool_id
  cognito_user_pool_client_id = module.cognito_idp.cognito_user_pool_client_id

  region = local.region
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "cognito_secret_to_role" {
  role       = module.cluster_k8s.serviceaccount_role_name
  policy_arn = module.secrets_cognito.secretsmanager_secret_policy_arn

  depends_on = [
    module.cluster_k8s,
    module.cognito_idp,
    module.secrets_cognito
  ]
}

# Baseado no tutorial "Build and use a local module" do portal HashiCorp Developer em 
# https://developer.hashicorp.com/terraform/tutorials/modules/module-create
