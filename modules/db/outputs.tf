output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.rms.address
  sensitive   = true
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.rms.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.rms.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.rms.username
  sensitive   = true
}

output "master_user_secret_name" {
  description = "The name of the master user secret."
  value       = data.aws_secretsmanager_secret.rms.name
}

output "master_user_secret_arn" {
  description = "The Amazon Resource Name (ARN) of the master user secret."
  value       = data.aws_secretsmanager_secret.rms.arn
}

output "rds_master_user_secret_policy_name" {
  description = "The name of the policy."
  value       = aws_iam_policy.master_user_secret_policy.name
}

output "rds_master_user_secret_policy_arn" {
  description = "The ARN assigned by AWS to the policy."
  value       = aws_iam_policy.master_user_secret_policy.arn
}
