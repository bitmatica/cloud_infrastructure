output "cluster_id" {
  description = "The ID of the Cluster"
  value       = module.eks.cluster_id
}

output cluster_worker_security_group_id {
  description = "The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console."
  // TODO This should be locked down to private-only security group.  Why doesn't module.eks.worker_security_group_id work?
  value       = module.eks.cluster_primary_security_group_id
}