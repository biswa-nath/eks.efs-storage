# ------------------------------
# StorageClass for Dynamic Provisioning
# ------------------------------
resource "kubernetes_storage_class" "efs_dynamic" {
  metadata {
    name = var.k8s_efs_sc_name
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.efs.id
    directoryPerms   = "700"
    gidRangeStart    = "1000"
    gidRangeEnd      = "2000"
    basePath         = "/dynamic"
  }

  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"
}
