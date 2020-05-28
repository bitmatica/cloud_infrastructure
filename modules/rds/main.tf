resource "aws_security_group" "rds_security_group" {
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "rds_ingress_from_eks" {
  description = "Allow EKS worker nodes to communicate with database"
  from_port = 5432
  protocol = "tcp"
  security_group_id = aws_security_group.rds_security_group.id
  to_port = 5432
  type = "ingress"
  source_security_group_id = var.ingress_security_group_id
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = var.db_identifier

  engine            = "postgres"
  engine_version    = "11.6"
  instance_class    = "db.t2.micro"
  allocated_storage = 5

  name     = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  iam_database_authentication_enabled = true

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
  final_snapshot_identifier = var.db_identifier
}