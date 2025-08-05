
# ------------------------------
# EFS File System + Mount Targets
# ------------------------------

# Get VPC information for security group restrictions
data "aws_vpc" "cluster_vpc" {
  id = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
}

resource "aws_efs_file_system" "efs" {
  creation_token = "eks-efs-dynamic"
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
  tags = {
    Name = "eks-efs-dynamic"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  vpc_id      = data.aws_eks_cluster.eks.vpc_config[0].vpc_id

  # Allow NFS traffic from EKS cluster security group
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [data.aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
  }

  # Allow NFS traffic from EKS node groups (additional security groups)
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.cluster_vpc.cidr_block]
  }

  # Minimal egress - only allow responses back to the VPC
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.cluster_vpc.cidr_block]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.eks.vpc_config[0].vpc_id]
  }

  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}

resource "aws_efs_mount_target" "efs_mt" {
  for_each = toset(data.aws_subnets.private.ids)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}
