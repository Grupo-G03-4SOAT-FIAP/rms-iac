variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "tags" {
  description = "Tags to set."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "app_namespace" {
  description = "In Kubernetes, namespaces provides a mechanism for isolating groups of resources within a single cluster."
  type        = string
}

variable "serviceaccount_name" {
  description = "A service account provides an identity for processes that run in a Pod, and maps to a ServiceAccount object."
  default     = "iam-sa" # eksdemo-secretmanager-sa
  type        = string
}
