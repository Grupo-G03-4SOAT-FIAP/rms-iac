output "region" {
  description = "AWS region"
  value       = local.region
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.cluster_k8s.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.cluster_k8s.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.cluster_k8s.cluster_name
}

output "cluster_oidc_provider" {
  description = "The OpenID Connect identity provider"
  value       = module.cluster_k8s.oidc_provider
}

output "cluster_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = module.cluster_k8s.oidc_provider_arn
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.cluster_k8s.cluster_name}"
}
