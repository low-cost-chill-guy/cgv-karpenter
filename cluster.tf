resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_clurole.arn
  version  = "1.32"

  vpc_config {
    subnet_ids = concat(
      aws_subnet.eksnet_ma[*].id,
      aws_subnet.eksnet_work[*].id
    )
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}
