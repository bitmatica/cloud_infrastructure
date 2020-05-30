data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.6"

  name                 = var.name
  cidr                 = var.cidr
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets

  enable_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    // Required so k8s can discover the subnet
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    // Required so k8s can create public load balancers
    "kubernetes.io/role/elb"                      = "1"
  }

  // These tags are required by EKS to schedule worker nodes
  private_subnet_tags = {
    // Required so k8s can discover the subnet
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    // Required so k8s can create internal load balancers
    "kubernetes.io/role/internal-elb"             = "1"
  }
}