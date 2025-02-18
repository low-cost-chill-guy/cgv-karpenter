resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand"]
  limits:
    resources:
      cpu: 1000
      memory: 1000Gi
  provider:
    subnetSelector:
      Name: "${var.name}-work-*"
    securityGroupSelector:
      kubernetes.io/cluster/${var.name}: owned
  ttlSecondsAfterEmpty: 30
YAML

  depends_on = [
    helm_release.karpenter
  ]
}
