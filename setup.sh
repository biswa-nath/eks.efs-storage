#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to deploy infrastructure
deploy_infrastructure() {
    print_status "Starting infrastructure deployment..."
    
    # Change to terraform directory
    cd terraform
    
    print_status "Initializing Terraform..."
    terraform init
    
    print_status "Planning Terraform deployment..."
    terraform plan
    
    print_status "Applying Terraform configuration..."
    terraform apply -auto-approve
    
    print_success "Infrastructure deployment completed"
    
    # Return to original directory
    cd ..
}

# Function to deploy Kubernetes manifests
deploy_manifests() {
    print_status "Deploying Kubernetes manifests..."
    
    # Check if manifests directory exists
    if [ ! -d "manifests" ]; then
        print_error "Manifests directory not found"
        exit 1
    fi

    # Apply all YAML files in manifests directory
    kubectl apply -f manifests/
    
    print_success "Kubernetes manifests deployed successfully"
}

# Function to destroy infrastructure
destroy_infrastructure() {    
    # Delete Kubernetes manifests first
    print_status "Deleting Kubernetes manifests..."
    kubectl delete -f manifests/
    
    print_success "Kubernetes manifests deleted"
    
    # Wait a bit for resources to be cleaned up
    print_status "Waiting for resources to be cleaned up..."
    sleep 10
    
    # Destroy Terraform infrastructure
    cd terraform
    
    print_status "Destroying Terraform infrastructure for EFS..."
    terraform destroy -auto-approve
    
    print_success "Infrastructure for EFS destruction completed"
    
    # Return to original directory
    cd ..
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [destroy]"
    echo ""
    echo "Commands:"
    echo "  (no arguments)  Deploy infrastructure and manifests"
    echo "  destroy         Destroy all resources (manifests and infrastructure)"
    echo ""
    echo "Examples:"
    echo "  $0              # Deploy everything"
    echo "  $0 destroy      # Destroy everything"
}

# Main script logic
main() {
    print_status "EFS Setup Script for EKS Cluster"
    print_status "================================"
    
    case "${1:-}" in
        "destroy")
            print_warning "This will destroy all resources!"
            read -p "Are you sure you want to continue? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                destroy_infrastructure
                print_success "All resources have been destroyed"
            else
                print_status "Operation cancelled"
                exit 0
            fi
            ;;
        "")
            deploy_infrastructure
            deploy_manifests
            print_success "Deployment completed successfully!"
            
            # Show some useful information
            print_status "Getting deployment status..."
            kubectl get pods,pvc,svc
            ;;
        "-h"|"--help"|"help")
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown argument: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
