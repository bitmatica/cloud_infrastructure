# Adapted from EKS template: https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-05-08/amazon-eks-vpc-private-subnets.yaml
# Includes 2 public subnets for k8s to schedule load balancers, and 2 private subnets for worker nodes.

# VpcBlock: Choose a CIDR range for your VPC.
# Default gives 2^16=65,536 addresses
variable "vpc_block" {
 default = "192.168.0.0/16"
}

# Specify a CIDR range for public subnet 1.
# Default gives 2^14 = 16,384 addresses
# We recommend that you keep the default value so that you have plenty of IP addresses for load balancers to use.
variable "public_subnet_1_block" {
  default = "192.168.0.0/18"
}

# Specify a CIDR range for public subnet 2.
# Default gives 2^14 = 16,384 addresses
# We recommend that you keep the default value so that you have plenty of IP addresses for load balancers to use.
variable "public_subnet_2_block" {
  default = "192.168.64.0/18"
}


# Specify a CIDR range for private subnet 1.
# Default gives 2^14 = 16,384 addresses
# We recommend that you keep the default value so that you have plenty of IP addresses for pods and load balancers to use.
variable "private_subnet_1_block" {
  default = "192.168.128.0/18"
}

# Specify a CIDR range for private subnet 2.
# Default gives 2^14 = 16,384 addresses
# We recommend that you keep the default value so that you have plenty of IP addresses for pods and load balancers to use.
variable "private_subnet_2_block" {
  default = "192.168.192.0/18"
}

# 2 Availability zones are required by EKS
variable "availability_zone_1" {
  default = "us-east-1b"
}

variable "availability_zone_2" {
  default = "us-east-1c"
}

variable "cluster_name" {
  default = "eks_cluster"
}