output "eks_cluster_name"      { value = aws_eks_cluster.this.name }
output "eks_cluster_endpoint"  { value = aws_eks_cluster.this.endpoint }
output "eks_cluster_ca_data"   { value = aws_eks_cluster.this.certificate_authority[0].data }
output "eks_node_role_arn"     { value = aws_iam_role.eks_node_role.arn }