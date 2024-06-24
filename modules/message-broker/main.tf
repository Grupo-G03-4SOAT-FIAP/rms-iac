provider "aws" {
  region = local.region
}

locals {
  region = var.region
}

################################################################################
# SQS
################################################################################

module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.2.0"

  name = var.name

  create_dlq = true
  redrive_policy = {
    # default is 5 for this module
    maxReceiveCount = 10
  }

  tags = var.tags
}

################################################################################
# SQS Policies
################################################################################

resource "aws_iam_policy" "policy_sqs" {
  name        = "policy-sqs-fila-${module.sqs.queue_name}"
  description = "Permite publicar e consumir mensagens na fila ${module.sqs.queue_name} no Amazon SQS"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "SQS:SendMessage",
          "SQS:ReceiveMessage"
        ]
        Resource = module.sqs.queue_arn
      },
    ]
  })

  tags = var.tags

  depends_on = [
    module.sqs
  ]
}

################################################################################
# Secret
################################################################################

resource "aws_secretsmanager_secret" "sqs" {
  name        = var.secret_name
  description = "Armazena as credenciais da fila ${module.sqs.queue_name} no Amazon SQS"

  # recovery_window_in_days = 7 # (Optional) Number of days that AWS Secrets Manager waits before it can delete the secret. This value can be 0 to force deletion without recovery or range from 7 to 30 days. The default value is 30.
  recovery_window_in_days = 0

  tags = var.tags

  depends_on = [
    module.sqs
  ]
}

# The map here can come from other supported configurations
# like locals, resource attribute, map() built-in, etc.
locals {
  initial = {
    QUEUE_NAME   = module.sqs.queue_name
    QUEUE_URL    = module.sqs.queue_url
    QUEUE_REGION = local.region
  }
}

resource "aws_secretsmanager_secret_version" "version1" {
  secret_id     = aws_secretsmanager_secret.sqs.id
  secret_string = jsonencode(local.initial)
}

################################################################################
# Secret Policies
################################################################################

resource "aws_iam_policy" "policy_secret_sqs" {
  name        = "policy-secret-sqs-fila-${module.sqs.queue_name}"
  description = "Permite acesso somente leitura ao Secret ${aws_secretsmanager_secret.sqs.name} no AWS Secrets Manager"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.sqs.arn
      },
    ]
  })

  tags = var.tags

  depends_on = [
    aws_secretsmanager_secret.sqs
  ]
}

# Baseado no tutorial "Build and use a local module" do portal HashiCorp Developer em 
# https://developer.hashicorp.com/terraform/tutorials/modules/module-create

# DICA: Para forçar a exclusão de um Secret antes do prazo de recovery ser atingido use o comando 
# aws secretsmanager delete-secret --secret-id nome/Segredo/Aqui --force-delete-without-recovery --region <region>

# DICA: Não esqueça de preencher o valor dos Secrets declarados acima, caso contrário você irá verá o erro "Failed to fetch secret from all regions" no k8s
