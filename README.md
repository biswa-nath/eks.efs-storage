# EKS Persistent Volume with Amazon EFS

A simple demonstration of using Amazon EFS as persistent storage for EKS workloads with dynamic provisioning.

## What it does

- Creates an EFS file system with proper security groups
- Installs the AWS EFS CSI driver on the EKS cluster
- Deploys a sample nginx application that uses EFS for shared storage

## Prerequisites

- Existing EKS cluster
- AWS CLI and kubectl configured
- Terraform and Helm installed

## Quick Start

1. Set cluster details:
   ```bash
   export TF_VAR_region="us-east-2"
   export TF_VAR_cluster_name="eks-cluster-name"
   ```

2. Deploy everything:
   ```bash
   ./setup.sh
   ```

3. Clean up:
   ```bash
   ./setup.sh destroy
   ```

## What gets created

- EFS file system with mount targets in private subnets
- EFS CSI driver (via Helm)
- Storage class for dynamic EFS provisioning
- Sample nginx deployment with shared EFS volume

## Verification

Check that everything is working:
```bash
kubectl get pods,pvc,svc
kubectl describe pvc efs-pvc
```

The nginx pods will share the same EFS volume mounted at `/var/log/nginx`.
