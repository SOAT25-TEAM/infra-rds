provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "soat_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true  
  enable_dns_hostnames = true  
  tags = {
    Name = "vpc-soat"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.soat_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true  
  tags = {
    Name = "subnet-publica-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.soat_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-publica-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.soat_vpc.id
  tags = {
    Name = "igw-soat"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.soat_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "rota-publica"
  }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group-soat"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  tags = {
    Name = "subnet-group-rds"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-access"
  description = "Libera MySQL para o SOAT"
  vpc_id      = aws_vpc.soat_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-rds-mysql"
  }
}

resource "aws_db_instance" "default" {
  identifier              = var.db_identifier
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = true  
  skip_final_snapshot     = true
  backup_retention_period = 0
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  tags = {
    Name = "mysql-soat"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}