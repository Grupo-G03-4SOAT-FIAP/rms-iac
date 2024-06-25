output "region" {
  description = "AWS region"
  value       = local.region
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.sqs.queue_arn
}

output "secretsmanager_secret_arn" {
  description = "ARN of the secret."
  value       = aws_secretsmanager_secret.sqs.arn
}
