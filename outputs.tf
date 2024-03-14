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

output "cluster_serviceaccount_role_name" {
  description = "Friendly name of the role"
  value       = module.cluster_k8s.serviceaccount_role_name
}

output "cluster_serviceaccount_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = module.cluster_k8s.serviceaccount_role_arn
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
  value       = module.secrets_mercadopago.secretsmanager_secret_name
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.cluster_k8s.cluster_name}"
}
