resource "aws_eks_node_group" "core_nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.name}-core-nodes"
  node_role_arn   = aws_iam_role.eks_noderole.arn
  subnet_ids      = aws_subnet.eksnet_work[*].id  # 프라이빗 서브넷 사용

  instance_types  = ["t3.large"]  # 시스템 워크로드를 위한 충분한 리소스
  capacity_type   = "ON_DEMAND"   # 시스템 워크로드는 안정성을 위해 ON_DEMAND
  disk_size       = 50            # 시스템 컴포넌트를 위한 충분한 디스크 공간

  scaling_config {
    desired_size = 2    # 고가용성을 위해 최소 2개 노드
    max_size     = 3    # 필요시 1개 노드 추가 가능
    min_size     = 2    # 항상 2개 노드 유지
  }

  update_config {
    max_unavailable = 1
  }

  # 시스템 워크로드 전용 노드로 지정
  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  labels = {
    role = "core"
    "node.kubernetes.io/purpose" = "core"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    "karpenter.sh/discovery" = aws_eks_cluster.main.name
  }
}
