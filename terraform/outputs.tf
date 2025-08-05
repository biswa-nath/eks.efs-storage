output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "storage_class_name" {
  value = kubernetes_storage_class.efs_dynamic.metadata[0].name
}

output "efs_sg_id" {
  value = aws_security_group.efs_sg.id
}

output "efs_sg_name" {
  value = aws_security_group.efs_sg.name
}

output "efs_subnet_ids" {
  value = data.aws_subnets.private.ids
}

output "efs_mount_target_ids" {
  value = [for mt in aws_efs_mount_target.efs_mt : mt.id]
}

output "efs_dns_name" {
  value = aws_efs_file_system.efs.dns_name
}

output "efs_arn" {
  value = aws_efs_file_system.efs.arn
}
