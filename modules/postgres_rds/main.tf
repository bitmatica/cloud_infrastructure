resource "aws_security_group" "rds_security_group" {
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "rds_ingress_security_group_rule" {
  description = "Allow EKS worker nodes to communicate with database"
  from_port = var.port
  protocol = "tcp"
  security_group_id = aws_security_group.rds_security_group.id
  to_port = var.port
  type = "ingress"
  source_security_group_id = var.ingress_security_group_id
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = "db.t2.micro"
  allocated_storage = 5

  identifier = var.identifier
  name     = var.name
  username = var.username
  password = var.password
  port     = var.port

  iam_database_authentication_enabled = true
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # DB subnet group
  subnet_ids = var.subnet_ids

  # DB parameter group
  family = "postgres11"

  # DB option group
  major_engine_version = "11"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = var.identifier
}