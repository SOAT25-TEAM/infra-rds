variable "aws_region" {
  type = string
  default = "us-east-2"
}

variable "db_identifier" {
  type = string
  description = "Identificador único do RDS"
}

variable "db_name" {
  type = string
  description = "Nome do DB"
}

variable "db_username" {
  type = string
  description = "DB User"
  sensitive = true
}

variable "db_password" {
  type = string
  description = "DB Password"
  sensitive = true
}
