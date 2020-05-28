module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = var.cluster_name
  # EKS master nodes will look for public subnets
  # with tags "kubernetes.io/cluster/${local.cluster_name}" = "shared" and "kubernetes.io/role/elb" = "1"
  # when creating load balancers.
  # This variable is used to determine which subnets to launch worker nodes into,
  # so we only include private subnets.
  # See discussion: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/104
  subnets      = var.worker_node_subnets

  vpc_id = var.vpc_id

  write_kubeconfig = false

  node_groups = {
    main = {
      # desired_capacity is just the initial value and updates are ignored by this module.
      # The preferred way to manage capacity is with k8s auto scaling.
      // TODO support autoscaling
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 1

      instance_type = var.instance_type
    }
  }
  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts
}
