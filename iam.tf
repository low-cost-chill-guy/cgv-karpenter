# EKS 클러스터 역할
resource "aws_iam_role" "eks_clurole" {
  name = "eks-clurole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# EKS 클러스터 역할에 정책 첨부
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_clurole.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_clurole.name
}

# EKS 노드 역할
resource "aws_iam_role" "eks_noderole" {
  name = "eks-noderole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

#eks cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name  # The IAM role for the EKS cluster
  policy_arn = aws_iam_policy.eks_cluster_policy.arn # The policy you want to attach
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "eks_cluster_policy" {
  name = "eks-cluster-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Add the necessary permissions for your EKS cluster
      {
        Action   = "*" # Replace with the actual permissions needed
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# EKS 노드 역할에 정책 첨부
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_noderole.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_noderole.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_noderole.name
}

# 추가 노드 정책
resource "aws_iam_role_policy" "eks_node_policy" {
  name = "eks-node-policy"
  role = aws_iam_role.eks_noderole.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.eks_noderole.arn
      },
      {
        Effect   = "Allow"
        Action   = [
          #"ec2:RunInstances",
          #"ec2:DescribeInstances",
          #"ec2:CreateLaunchTemplate",
          #"ec2:DescribeLaunchTemplates",
          "ec2:*"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "eks:CreateNodegroup",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# Karpenter Node 역할
resource "aws_iam_role" "karpenter_node" {
  name = "${var.name}-karpenter-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Karpenter Controller 정책
resource "aws_iam_role_policy" "karpenter_controller" {
  name = "karpenter-controller-policy"
  role = aws_iam_role.karpenter_controller.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:TerminateInstances",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "iam:PassRole",
          "ssm:GetParameter"
        ]
        Resource = "*"
      }
    ]
  })
}



# Karpenter Controller 역할
resource "aws_iam_role" "karpenter_controller" {
  name = "${var.name}-karpenter-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:karpenter:karpenter",
          "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud": "sts.amazonaws.com"
        }
      }
    }]
  })
}



# Karpenter Node IAM Instance Profile
resource "aws_iam_instance_profile" "karpenter" {
  name = "${var.name}-karpenter"
  role = aws_iam_role.karpenter_node.name
}

# Karpenter Node 역할에 정책 첨부
resource "aws_iam_role_policy_attachment" "karpenter_node_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenter_node.name
}

# EKS 클러스터 역할에 정책 첨부

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "ebs-csi-driver-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::277707137172:oidc-provider/oidc.eks.ap-northeast-2.amazonaws.com/id/F5BF774DED104B2074369F51F7B07535"
        }
        Condition = {
          StringEquals = {
            "oidc.eks.ap-northeast-2.amazonaws.com/id/F5BF774DED104B2074369F51F7B07535:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ebs_csi_driver_policy" {
  name = "ebs-csi-driver-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ebs:*" # Be as specific as possible in production
        ],
        Effect = "Allow",
        Resource = "*"
      },
       {
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:CreateVolume"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  policy_arn = aws_iam_policy.ebs_csi_driver_policy.arn
  role       = aws_iam_role.ebs_csi_driver_role.name
}

resource "kubernetes_service_account" "ebs_csi_controller" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_driver_role.arn
    }
  }
}
