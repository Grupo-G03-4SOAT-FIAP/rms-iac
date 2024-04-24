provider "aws" {
  region = var.region
}

resource "aws_db_subnet_group" "rms" {
  name       = "rms-prod-subnetgroup"
  subnet_ids = var.public_subnets

  tags = var.tags
}

resource "aws_security_group" "rds" {
  name   = "rms-prod-securitygroup"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_db_parameter_group" "rms" {
  name   = "rms-prod-paramgroup"
  family = "postgres15"

  parameter {
    name  = "rds.force_ssl"
    value = "0" # Desativa o SSL obrigatório
  }

  parameter {
    name  = "rds.logical_replication"
    value = "1" # enable logical replication
  }
}

resource "aws_db_instance" "rms" {
  identifier                  = "rms-prod-postgres-standalone"
  instance_class              = "db.t3.micro" # A instance_class do Free Tier é db.t3.micro
  allocated_storage           = 5
  db_name                     = "rms"
  engine                      = "postgres"
  engine_version              = "15.6"
  manage_master_user_password = true # Guarda o usuário e senha do banco de dados em um Secret no AWS Secrets Manager
  username                    = "postgres"
  db_subnet_group_name        = aws_db_subnet_group.rms.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  parameter_group_name        = aws_db_parameter_group.rms.name
  publicly_accessible         = true
  # skip_final_snapshot         = false
  skip_final_snapshot = true
  # storage_encrypted   = true
  storage_encrypted = false

  tags = var.tags
}

# Use the output of the `master_user_secret` object, which includes `secret_arn`,
# to manage the rotation rules.
resource "aws_secretsmanager_secret_rotation" "rms" {
  secret_id = aws_db_instance.rms.master_user_secret[0].secret_arn

  rotation_rules {
    automatically_after_days = 7 # (Optional) # O valor padrão é 7 dias
  }
}

# Optionally fetch the secret data if attributes need to be used as inputs
# elsewhere.
data "aws_secretsmanager_secret" "rms" {
  arn = aws_db_instance.rms.master_user_secret[0].secret_arn
}

# Baseado no tutorial "Manage AWS RDS instances" do portal HashiCorp Developer em 
# https://developer.hashicorp.com/terraform/tutorials/aws/aws-rds
