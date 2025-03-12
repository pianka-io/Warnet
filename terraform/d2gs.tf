#data "aws_ami" "windows_latest" {
#  most_recent = true
#  owners      = ["amazon"]
#  filter {
#    name   = "name"
#    values = ["Windows_Server-*-English-Full-Base-*"]
#  }
#}
#
#resource "aws_security_group" "windows_sg" {
#  name_prefix = "windows-sg-"
#  description = "Allow inbound traffic on port 6113"
#
#  ingress {
#    from_port   = 3389
#    to_port     = 3389
#    protocol    = "tcp"
#    cidr_blocks = ["47.20.0.0/16"]
#  }
#  ingress {
#    from_port   = 6112
#    to_port     = 6112
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#  ingress {
#    from_port   = 6113
#    to_port     = 6113
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#  ingress {
#    from_port   = 6114
#    to_port     = 6114
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#  ingress {
#    from_port   = 4000
#    to_port     = 4000
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
#
#resource "aws_instance" "windows_instance" {
#  ami           = data.aws_ami.windows_latest.id
#  instance_type = "t3.large"
#  key_name      = "warnet"
#  security_groups = [aws_security_group.windows_sg.name]
#
#  associate_public_ip_address = true
#
#  root_block_device {
#    volume_size = 200
#    volume_type = "gp3"
#    delete_on_termination = false
#  }
#
#  tags = {
#    Name = "WindowsServer"
#  }
#}
#
#resource "aws_backup_vault" "windows_backup_vault" {
#  name = "windows-backups"
#}
#
#resource "aws_backup_plan" "windows_backup_plan" {
#  name = "windows-daily-backup"
#
#  rule {
#    rule_name         = "daily-backup"
#    target_vault_name = aws_backup_vault.windows_backup_vault.name
#    schedule         = "cron(0 3 * * ? *)"
#
#    lifecycle {
#      delete_after = 30
#    }
#  }
#}
#
#resource "aws_backup_selection" "windows_backup_selection" {
#  name         = "windows-backup-selection"
#  iam_role_arn = "arn:aws:iam::869935095159:role/service-role/AWSBackupDefaultServiceRole"
#  plan_id      = aws_backup_plan.windows_backup_plan.id
#
#  resources = [aws_instance.windows_instance.arn]
#}
#
#data "aws_secretsmanager_secret" "admin_password" {
#  name = "windows_admin_password"
#}
#
#data "aws_secretsmanager_secret_version" "admin_password_version" {
#  secret_id = data.aws_secretsmanager_secret.admin_password.id
#}
#
#output "windows_admin_password" {
#  value     = data.aws_secretsmanager_secret_version.admin_password_version.secret_string
#  sensitive = true
#}
#
#output "instance_public_ip" {
#  value = aws_instance.windows_instance.public_ip
#}
