resource "aws_secretsmanager_secret" "mariadb_password" {
  name = "mariadb_password"
}

data "aws_secretsmanager_secret_version" "mariadb_password_current" {
  secret_id = aws_secretsmanager_secret.mariadb_password.id
}

resource "aws_secretsmanager_secret" "discord_token" {
  name = "discord_token_ugh"
}

resource "aws_secretsmanager_secret_policy" "discord_token_policy" {
  secret_arn = aws_secretsmanager_secret.discord_token.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.orchestrator.arn
        },
        Action = "secretsmanager:GetSecretValue",
        Resource = aws_secretsmanager_secret.discord_token.arn
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.orchestrator.arn
        },
        Action = "secretsmanager:GetSecretValue",
        Resource = aws_secretsmanager_secret.locationiq_api_key.arn
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "locationiq_api_key" {
  name = "locationiq_api_key_ugh"
}

resource "aws_secretsmanager_secret_policy" "locationiq_api_key_policy" {
  secret_arn = aws_secretsmanager_secret.locationiq_api_key.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.orchestrator.arn
        },
        Action = "secretsmanager:GetSecretValue",
        Resource = aws_secretsmanager_secret.locationiq_api_key.arn
      }
    ]
  })
}
