provider "aws" {
  region = var.aws_region
}

resource "aws_db_instance" "default" {
  identifier = var.db_identifier
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  max_allocated_storage = 100
  db_name = var.db_name
  username = var.db_username
  password = var.db_password
  publicly_accessible = true
  skip_final_snapshot = true
  backup_retention_period = 0
  multi_az = false
  deletion_protection = false
  storage_type = "gp2"
}