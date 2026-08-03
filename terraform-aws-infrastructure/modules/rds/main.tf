# --- Database Security Group ---
resource "aws_security_group" "db_sg" {
  name        = "${var.environment}-db-sg"
  description = "Allow incoming database traffic from the application layer"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Database access from App servers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
  }
}

# --- Database Subnet Group ---
resource "aws_db_subnet_group" "db_subnet" {
  name        = "${var.environment}-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for RDS database instance"

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# --- DB Instance ---
resource "aws_db_instance" "postgres" {
  identifier             = "${var.environment}-db"
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = 100
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  multi_az               = var.multi_az

  tags = {
    Name        = "${var.environment}-database"
    Environment = var.environment
  }
}
