variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "tags" {
  description = "Tags to set."
  type        = map(string)
  default     = {}
}

variable "rds_identifier" {
  description = "RDS instance identifier"
  type        = string
}

variable "rds_engine" {
  description = "RDS instance engine"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS instance endpoint"
  type        = string
}

variable "rds_port" {
  description = "RDS instance port"
  type        = string
}
