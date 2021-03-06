output "cluster_id" {
  description = "ID of created cluster"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "cluster_worker_nodes_security_group_id" {
  description = "Security group ids attached to the worker nodes."
  // TODO This should be locked down to private-only security group.  Why doesn't module.eks.worker_security_group_id work?
  value       = module.eks.cluster_primary_security_group_id
}

output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks.kubeconfig
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.config_map_aws_auth
}

output "node_groups" {
  description = "Outputs from node groups"
  value       = module.eks.node_groups
}

output "cluster_ca_certificate" {
  value = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

output "cluster_token" {
  value = data.aws_eks_cluster_auth.cluster.token
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}
