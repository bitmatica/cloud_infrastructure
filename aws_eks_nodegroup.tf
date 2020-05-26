resource "aws_iam_role" "eks_node_group_role" {
  // TODO add random suffix?
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  // TODO add random suffix?
  node_group_name = "worker_node_group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = [
    aws_subnet.public_subnet_1_block.id,
    aws_subnet.public_subnet_2_block.id,
    aws_subnet.private_subnet_1_block.id,
    aws_subnet.private_subnet_2_block.id
  ]

  scaling_config {
    desired_size = 2
    min_size = 2
    max_size = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]

  // TODO
//  remote_access {
//
//  }

  // TODO
  # Optional: Allow external changes without Terraform plan difference
//  lifecycle {
//    ignore_changes = [scaling_config[0].desired_size]
//  }
}