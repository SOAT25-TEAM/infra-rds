provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "soat_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-soat"
  }
}

resource "aws_subnet" "public_subnet_soat" {
  vpc_id            = aws_vpc.soat_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"  
  map_public_ip_on_launch = true  
  tags = {
    Name = "subnet-publica-soat"
  }
}

resource "aws_internet_gateway" "soat_igw" {
  vpc_id = aws_vpc.soat_vpc.id
  tags = {
    Name = "igw-soat"
  }
}

resource "aws_route_table" "soat_public_route" {
  vpc_id = aws_vpc.soat_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.soat_igw.id
  }

  tags = {
    Name = "rota-publica-soat"
  }
}

resource "aws_route_table_association" "soat_public_assoc" {
  subnet_id      = aws_subnet.public_subnet_soat.id
  route_table_id = aws_route_table.soat_public_route.id
}

resource "aws_db_subnet_group" "soat_rds_subnet_group" {
  name       = "rds-subnet-group-soat"
  subnet_ids = [aws_subnet.public_subnet_soat.id]
  tags = {
    Name = "subnet-group-rds-soat"
  }
}

resource "aws_security_group" "soat_rds_open" {
  name        = "rds-acesso-total-soat"
  description = "Libera TODAS as portas (uso exclusivo para SOAT)"
  vpc_id      = aws_vpc.soat_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
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
    Name = "sg-rds-soat"
  }
}

resource "aws_db_instance" "soat_db" {
  identifier           = "db-soat-mysql"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  max_allocated_storage = 100
  db_name              = "soatdb"
  username             = "soatadmin"
  password             = "soatpassword123"  
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.soat_rds_open.id]
  db_subnet_group_name = aws_db_subnet_group.soat_rds_subnet_group.name
  tags = {
    Name = "mysql-soat"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.soat_db.endpoint
}