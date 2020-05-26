resource "aws_security_group" "rds_security_group" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "rds_ingress_from_eks" {
  description = "Allow worker nodes to communicate with database"
  from_port = 5432
  protocol = "TCP"
  security_group_id = aws_security_group.rds_security_group.id
  to_port = 5432
  type = "ingress"
  source_security_group_id = module.eks.worker_security_group_id
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "demodb"

  engine            = "postgres"
  engine_version    = "11.6"
  instance_class    = "db.t2.micro"
  allocated_storage = 5

  name     = "demodb"
  username = "demouser"
  password = "YourPwdShouldBeLongAndSecure!"
  port     = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

//  # Enhanced Monitoring - see example for details on how to create the role
//  # by yourself, in case you don't want to create it automatically
//  monitoring_interval = "30"
//  monitoring_role_name = "MyRDSMonitoringRole"
//  create_monitoring_role = true

//  tags = {
//    Owner       = "user"
//    Environment = "dev"
//  }

  # DB subnet group
  subnet_ids = module.vpc.private_subnets

  # DB parameter group
  family = "postgres11"

  # DB option group
  major_engine_version = "11"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "demodb"

  # Database Deletion Protection
//  deletion_protection = true

//  parameters = [
//    {
//      name = "character_set_client"
//      value = "utf8"
//    },
//    {
//      name = "character_set_server"
//      value = "utf8"
//    }
//  ]
}