# GCP GKE Cluster Configuration
# This example creates a regional GKE cluster with Workload Identity

terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "gke_cluster" {
  source = "../../modules/gcp-gke"

  cluster_name       = var.cluster_name
  project_id         = var.project_id
  region             = var.region
  kubernetes_version = var.kubernetes_version

  network_cidr = var.network_cidr
  node_pools   = var.node_pools

  enable_workload_identity = var.enable_workload_identity

  tags = var.tags
}
