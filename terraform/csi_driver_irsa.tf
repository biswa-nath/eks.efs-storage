
# ------------------------------
# IRSA for EFS CSI Driver
# ------------------------------

resource "aws_iam_role" "efs_csi_irsa" {
  name = "AmazonEKS_EFS_CSI_DriverRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:${var.k8s_namespace}:${var.k8s_efs_service_account}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "efs_csi_attach" {
  role       = aws_iam_role.efs_csi_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

# ------------------------------
# Install CSI Driver with IRSA
# ------------------------------
resource "helm_release" "efs_csi_driver" {
  name       = var.k8s_efs_helm_release_name
  namespace  = var.k8s_namespace
  repository = var.k8s_efs_helm_repo_url
  chart      = var.k8s_efs_helm_chart_name
  version    = var.k8s_efs_helm_chart_version

  set = [
    {
    name  = "controller.serviceAccount.name"
    value = var.k8s_efs_service_account
    },
    {
    name  = "controller.serviceAccount.create"
    value = "true"
    },
    {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.efs_csi_irsa.arn
    }
  ]
}
