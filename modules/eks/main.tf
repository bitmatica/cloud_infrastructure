module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = var.cluster_name
  # EKS master nodes will look for public subnets
  # with tags "kubernetes.io/cluster/${local.cluster_name}" = "shared" and "kubernetes.io/role/elb" = "1"
  # when creating load balancers.
  # This variable is used to determine which subnets to launch worker nodes into,
  # so we only include private subnets.
  # See discussion: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/104
  subnets      = var.worker_node_subnet_ids

  vpc_id = var.vpc_id

  write_kubeconfig = false

  enable_irsa  = true

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

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# This is required since manage_aws_auth = true
# The eks module needs cluster auth to add aws roles/users/accounts
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11.1"
}