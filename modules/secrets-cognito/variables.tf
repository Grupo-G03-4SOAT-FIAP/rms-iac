variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "tags" {
  description = "Tags to set."
  type        = map(string)
  default     = {}
}

variable "cognito_user_pool_id" {
  description = "ID of the user pool."
  type        = string
}

variable "cognito_user_pool_client_id" {
  description = "Unique identifier for the user pool client."
  type        = string
}
