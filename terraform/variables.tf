variable "region" {
   default = "us-east-2"
}
variable "cluster_name" {}
variable "k8s_namespace" {
    default = "kube-system"
}
variable "k8s_efs_service_account" {
    default = "efs-csi-controller-sa"
}
variable "k8s_efs_sc_name" {
    default = "efs-sc"
}
variable "k8s_efs_helm_repo_url" {
    default = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
}
variable "k8s_efs_helm_release_name" {
    default = "aws-efs-csi-driver"
}
variable "k8s_efs_helm_chart_name" {
    default = "aws-efs-csi-driver"
}
variable "k8s_efs_helm_chart_version" {
    default = "2.5.0"
}
