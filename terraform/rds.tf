resource "aws_db_instance" "warnet" {
  allocated_storage      = 10
  identifier             = "warnet"
  db_name                = "warnet"
  engine                 = "mariadb"
  engine_version         = "10.5.27"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = data.aws_secretsmanager_secret_version.mariadb_password_current.secret_string
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds.id]
}
