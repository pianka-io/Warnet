resource "aws_secretsmanager_secret" "mariadb_password" {
  name = "mariadb_password"
}

data "aws_secretsmanager_secret_version" "mariadb_password_current" {
  secret_id = aws_secretsmanager_secret.mariadb_password.id
}
