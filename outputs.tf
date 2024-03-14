output "region" {
  description = "AWS region"
  value       = local.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.cluster_k8s.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.cluster_k8s.cluster_endpoint
}

output "cluster_serviceaccount_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = module.cluster_k8s.serviceaccount_role_arn
}

output "cluster_serviceaccount_name" {
  description = "Kubernetes ServiceAccount name"
  value       = module.cluster_k8s.serviceaccount_name
}

output "repository_url" {
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
  value       = module.registry.repository_url
}

output "docker_login" {
  description = "Log in to Amazon ECR: run the following command to authenticate Docker to the Amazon ECR registry"
  value       = "aws ecr get-login-password --region ${local.region} | docker login --username AWS --password-stdin ${module.registry.repository_url}"
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.db.rds_endpoint
  sensitive   = true
}

output "rds_master_user_secret_name" {
  description = "The name of the master user secret."
  value       = module.db.master_user_secret_name
}

output "mercadopago_secret_name" {
  description = "Friendly name of the new secret."
  value       = module.secrets_cognito.secretsmanager_secret_name
}

output "cognito_secret_name" {
  description = "Friendly name of the new secret."
  value       = module.secrets_cognito.secretsmanager_secret_name
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.cluster_k8s.cluster_name}"
}
