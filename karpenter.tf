resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name = "karpenter-provisioner"
      tags = { # tags 블록 추가
        Name = "karpenter.sh/provisioner-name/karpenter-provisioner"
        "karpenter.sh/discovery" = var.cluster_name # 변수 사용
      }
    }
    spec = {
      requirements = [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["on-demand"]
        },
         {
   	   key      = "eks.amazonaws.com/capacityType"
   	   operator = "In"
    	   values   = ["ON_DEMAND"]
         }
      ]
      limits = {
        resources = {
          cpu    = "1000" # 숫자 값은 따옴표로 묶어줍니다.
          memory = "1000Gi"
        }
      }
      provider = {
        subnetSelector = {
          Name = "${var.name}-work-*"
        }
        securityGroupSelector = {
          "kubernetes.io/cluster/${var.name}" = "owned"
        }
      }
      ttlSecondsAfterEmpty = 30
      taints               = []
    }
  })

  depends_on = [
    helm_release.karpenter
  ]
}

