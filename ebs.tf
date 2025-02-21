module "addon-aws-ebs-csi-driver" {
  source             = "./modules/aws-eks/addon/"
  addon-cluster_name = aws_eks_cluster.main.name
  addon-name         = "aws-ebs-csi-driver"
  addon-role         = aws_iam_role.ebs_csi_driver_role.arn
  depends_on         = [aws_eks_node_group.core_nodes, aws_iam_role_policy_attachment.ebs_csi_driver_policy_attachment]
}
