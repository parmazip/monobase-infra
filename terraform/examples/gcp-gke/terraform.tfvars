# GCP GKE Cluster - Example Configuration
# Copy this file and customize for your environment

# Cluster identification
cluster_name = "monobase-prod"
project_id   = "my-gcp-project-123456"  # Change to your GCP project ID
region       = "us-central1"             # us-central1, us-east1, europe-west1, asia-southeast1

# Kubernetes version (see: gcloud container get-server-config --region=us-central1)
kubernetes_version = "1.28"

# Network configuration
network_cidr = "10.0.0.0/16"

# Node pool configuration
# Sized for multi-tenant SaaS platform (5-10 clients initially, scaling to 20-30)
node_pools = {
  general = {
    machine_type = "n2-standard-8"  # 8 vCPU, 32GB RAM per node
    node_count   = 5                # Initial node count
    min_count    = 3                # Minimum for HA
    max_count    = 20               # Scale up for growth
    disk_size_gb = 100              # Boot disk size
  }
}

# Workload Identity (recommended for secure service account access)
enable_workload_identity = true

# Resource labels
tags = {
  Environment = "production"
  ManagedBy   = "terraform"
  Project     = "monobase-infrastructure"
  Team        = "platform"
}

# Cost Estimates (us-central1):
# - Control plane (regional): ~$73/month
# - 5x n2-standard-8 nodes: ~$1,000/month
# - 100GB PD-SSD per node: ~$85/month
# - Egress (estimate): ~$50/month
# Total: ~$1,208/month
#
# Scaling:
# - 10 nodes: ~$2,073/month
# - 20 nodes: ~$4,003/month
