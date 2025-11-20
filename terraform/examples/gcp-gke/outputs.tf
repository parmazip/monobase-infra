# GCP GKE Cluster - Outputs

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke_cluster.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke_cluster.cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig for kubectl access (used by provision.ts)"
  value       = module.gke_cluster.kubeconfig
  sensitive   = true
}

output "configure_kubectl" {
  description = "Command to configure kubectl for this cluster"
  value       = module.gke_cluster.configure_kubectl
}

output "external_secrets_sa_email" {
  description = "External Secrets Operator service account email"
  value       = module.gke_cluster.external_secrets_sa_email
}

output "velero_sa_email" {
  description = "Velero backup service account email"
  value       = module.gke_cluster.velero_sa_email
}

output "cert_manager_sa_email" {
  description = "cert-manager service account email"
  value       = module.gke_cluster.cert_manager_sa_email
}

output "network_name" {
  description = "VPC network name"
  value       = module.gke_cluster.network_name
}

output "subnet_name" {
  description = "Subnet name"
  value       = module.gke_cluster.subnet_name
}
