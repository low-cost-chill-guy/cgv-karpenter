# AWS Load Balancer Controller 설치
resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [aws_eks_cluster.main]  # EKS 클러스터 생성 후 설치
  
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.5.5"  # 특정 버전 지정
  
  timeout = 600

  set {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  }
  
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn
  }

  # VPC ID 설정
  set {
    name  = "vpcId"
    value = aws_vpc.eks_vpc.id
  }

  # 리전 설정
  set {
    name  = "region"
    value = var.region
  }

    # Toleration 추가
#  set {
#    name  = "tolerations[0].key"
#    value = "CriticalAddonsOnly"
#  }

#  set {
#    name  = "tolerations[0].operator"
#    value = "Exists"
#  }

#  set {
#    name  = "tolerations[0].effect"
#    value = "NoSchedule"
#  }

}

# Karpenter 설치
resource "helm_release" "karpenter" {
  depends_on = [aws_eks_cluster.main, helm_release.aws_load_balancer_controller]
  
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  version          = "v0.31.0"  # 특정 버전 지정
  
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }
  
  set {
    name  = "settings.aws.clusterName"
    value = aws_eks_cluster.main.name
  }
  
  set {
    name  = "settings.aws.clusterEndpoint"
    value = aws_eks_cluster.main.endpoint
  }
  
  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = aws_sqs_queue.karpenter.name
  }

    # Toleration 추가
  set {
    name  = "tolerations[0].key"
    value = "CriticalAddonsOnly"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }
}


# Prometheus 설치
resource "helm_release" "prometheus" {
  name       = "prometheus"
  chart      = "https://github.com/prometheus-community/helm-charts/releases/download/kube-prometheus-stack-25.0.0/kube-prometheus-stack-25.0.0.tgz"
  namespace  = "monitoring"
  version    = "25.0.0"  # 원하는 Prometheus Helm chart 버전을 설정하세요.

  values = [
    <<-EOT
    tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Exists"
        effect: "NoSchedule"
    podSecurityPolicy:
      enabled: false  # PodSecurityPolicy 비활성화
    grafana:
      enabled: true
      adminPassword: "admin159!!"  # Grafana 관리자 비밀번호 설정
      ingress:
        enabled: true
        host: "cgv.grafana"  # Grafana를 접속할 도메인 주소 설정
    EOT
  ]
}

