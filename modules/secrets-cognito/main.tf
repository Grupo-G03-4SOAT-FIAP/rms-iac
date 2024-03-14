provider "aws" {
  region = local.region
}

locals {
  region = var.region
}

resource "aws_secretsmanager_secret" "cognito" {
  name        = "prod/RMS/Cognito"
  description = "Armazena as credenciais do Amazon Cognito"

  # recovery_window_in_days = 7 # (Optional) Number of days that AWS Secrets Manager waits before it can delete the secret. This value can be 0 to force deletion without recovery or range from 7 to 30 days. The default value is 30.
  recovery_window_in_days = 0

  tags = var.tags
}

# The map here can come from other supported configurations
# like locals, resource attribute, map() built-in, etc.
variable "credenciais" {
  default = {
    # Inicializa as Keys, vazias, em branco
    # Por segurança, após o provisionamento do Secret preencha os valores abaixo manualmente no Console da AWS no link abaixo: 
    # https://us-east-1.console.aws.amazon.com/secretsmanager/secret?name=prod/RMS/Cognito&region=us-east-1
    COGNITO_USER_POOL_ID = null
    COGNITO_CLIENT_ID    = null
  }

  type = map(string)
}

resource "aws_secretsmanager_secret_version" "version1" {
  secret_id     = aws_secretsmanager_secret.cognito.id
  secret_string = jsonencode(var.credenciais)
}

################################################################################
# Policies
################################################################################

resource "aws_iam_policy" "policy_cognito" {
  name        = "policy-cognito"
  description = "Permite acesso de leitura ao Secret no AWS Secrets Manager"

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
        Resource = aws_secretsmanager_secret.cognito.arn
      },
    ]
  })

  tags = var.tags
}

# Baseado no tutorial "Build and use a local module" do portal HashiCorp Developer em 
# https://developer.hashicorp.com/terraform/tutorials/modules/module-create

# DICA: Para forçar a exclusão de um Secret antes do prazo de recovery ser atingido use o comando 
# aws secretsmanager delete-secret --secret-id nome/Segredo/Aqui --force-delete-without-recovery --region <region>

# DICA: Não esqueça de preencher o valor dos Secrets declarados acima, caso contrário você irá verá o erro "Failed to fetch secret from all regions" no k8s
