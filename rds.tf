resource "aws_db_instance" "postgres_db" {
  identifier            = "my-postgres-db"
  engine                = "postgres"
  engine_version        = "16.1"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "mydatabase"
  username = "db_admin_user"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security.id]
  parameter_group_name   = aws_db_parameter_group.default.name

  publicly_accessible = false
  skip_final_snapshot = true # Set to false for production to ensure backup before destruction

  tags = {
    Environment = "Dev"
  }
}

resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "db"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "db_security" {
  name        = "db_security"
  description = "Allow internal traffic to DB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group_rule" "db_traffic" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [aws_subnet.private1.cidr_block, aws_subnet.private2.cidr_block]
  security_group_id = "sg-123456"
}

resource "aws_db_parameter_group" "default" {
  name   = "rds-pg"
  family = "postgres16"
}
