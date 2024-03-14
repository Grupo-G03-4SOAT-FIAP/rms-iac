variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "tags" {
  description = "Tags to set."
  type        = map(string)
  default     = {}
}

variable "role_name_to_attach" {
  description = "Friendly name of the role"
  type        = string
}
