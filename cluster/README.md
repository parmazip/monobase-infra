# GCP GKE Example Configuration

This directory contains a reference configuration for provisioning Google Kubernetes Engine (GKE) clusters using the Monobase Infrastructure platform.

## Features

- **Regional GKE Cluster** - Multi-zone high availability
- **Workload Identity** - Secure service account access (no static keys)
- **VPC-Native Networking** - Pod and service IP ranges
- **Auto-Scaling Node Pools** - Scale from 3 to 20 nodes
- **Network Policy** - Pod-to-pod communication control
- **Auto-Upgrade & Auto-Repair** - Automated cluster maintenance
- **Cloud Logging & Monitoring** - Integrated observability

## Prerequisites

### Required Tools

```bash
# Install mise (tool version manager)
curl https://mise.run | sh

# Install all required tools via mise
mise install

# Or install individually:
# - Terraform/OpenTofu >= 1.6
# - kubectl >= 1.28
# - Helm >= 3.16
# - Bun (latest)
```

### GCP Prerequisites

1. **Create GCP Project**
   ```bash
   gcloud projects create my-project-id
   gcloud config set project my-project-id
   ```

2. **Enable Required APIs**
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable container.googleapis.com
   gcloud services enable secretmanager.googleapis.com
   gcloud services enable cloudresourcemanager.googleapis.com
   ```

3. **Authenticate**
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

4. **Set Up Billing** (if not already configured)
   - Visit: https://console.cloud.google.com/billing

## Quick Start

### 1. Copy Example Configuration

```bash
# From repository root
cp -r terraform/examples/gcp-gke cluster
cd cluster
```

### 2. Customize Configuration

Edit `terraform.tfvars`:

```hcl
cluster_name = "monobase-prod"              # Your cluster name
project_id   = "my-gcp-project-123456"      # Your GCP project ID
region       = "us-central1"                # Your preferred region

# Adjust node pool sizing as needed
node_pools = {
  general = {
    machine_type = "n2-standard-8"
    node_count   = 5
    min_count    = 3
    max_count    = 20
  }
}
```

### 3. Provision Cluster

```bash
# Return to repository root
cd ..

# Provision cluster (15-20 minutes)
mise run provision --merge-kubeconfig

# Or using bun directly:
bun scripts/provision.ts --merge-kubeconfig
```

This will:
- Initialize Terraform
- Create GKE cluster
- Configure VPC networking
- Set up Workload Identity
- Extract kubeconfig to `~/.kube/{cluster_name}`
- Merge kubeconfig into `~/.kube/config`
- Verify cluster connectivity

### 4. Set Up Secrets Infrastructure

```bash
# Full setup: GCP + K8s + TLS infrastructure
export GCP_PROJECT_ID=my-gcp-project-123456
mise run secrets setup --full

# Or using bun:
bun scripts/secrets.ts setup --full --project my-gcp-project-123456
```

This will:
- Enable Secret Manager API
- Create service account for External Secrets
- Grant IAM permissions
- Create Kubernetes secrets
- Generate Let's Encrypt ClusterIssuers
- Create GCP Secret Manager secrets
- Generate ExternalSecret manifests

### 5. Bootstrap GitOps (ArgoCD)

```bash
# Bootstrap and wait for all apps to sync
mise run bootstrap --wait

# Or using bun:
bun scripts/bootstrap.ts --wait
```

This will:
- Install ArgoCD via Helm
- Set up GitHub App authentication (interactive)
- Deploy infrastructure-root Application
- Deploy ApplicationSet for auto-discovery
- Wait for all Applications to sync

### 6. Access Services

```bash
# Port-forward to ArgoCD UI
mise run admin --service argocd

# Or access Grafana
mise run admin --service grafana

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

## Configuration Options

### Machine Types

| Type | vCPU | Memory | Use Case | Cost (us-central1) |
|------|------|--------|----------|-------------------|
| n2-standard-4 | 4 | 16GB | Development | ~$145/month |
| n2-standard-8 | 8 | 32GB | Production (recommended) | ~$291/month |
| n2-standard-16 | 16 | 64GB | High-traffic | ~$582/month |
| n2-highmem-8 | 8 | 64GB | Memory-intensive | ~$389/month |

### Regions

Common GCP regions:
- `us-central1` - Iowa (lowest latency to US)
- `us-east1` - South Carolina
- `us-west1` - Oregon
- `europe-west1` - Belgium
- `asia-southeast1` - Singapore

See all: https://cloud.google.com/compute/docs/regions-zones

### Kubernetes Versions

Check available versions:
```bash
gcloud container get-server-config --region=us-central1
```

## Cost Estimates

### Small Cluster (3 nodes, n2-standard-4)
- Control plane (regional): ~$73/month
- 3x n2-standard-4 nodes: ~$435/month
- Storage (300GB): ~$51/month
- **Total: ~$559/month**

### Medium Cluster (5 nodes, n2-standard-8) - Recommended
- Control plane (regional): ~$73/month
- 5x n2-standard-8 nodes: ~$1,455/month
- Storage (500GB): ~$85/month
- **Total: ~$1,613/month**

### Large Cluster (10 nodes, n2-standard-8)
- Control plane (regional): ~$73/month
- 10x n2-standard-8 nodes: ~$2,910/month
- Storage (1TB): ~$170/month
- **Total: ~$3,153/month**

*Prices as of 2024, us-central1 region, standard persistent disks*

## Remote State (Recommended for Production)

### Create GCS Bucket

```bash
# Create state bucket
gsutil mb -p my-gcp-project-123456 \
  -l us-central1 \
  gs://my-terraform-state-bucket

# Enable versioning (important for recovery)
gsutil versioning set on gs://my-terraform-state-bucket
```

### Configure Backend

```bash
# Copy example backend configuration
cp backend.tf.example backend.tf

# Edit backend.tf with your bucket name
vim backend.tf

# Migrate existing state
terraform init -migrate-state
```

## Workload Identity Setup

Workload Identity is automatically configured for:

1. **External Secrets Operator** - Access GCP Secret Manager
2. **Velero** - Backup to Google Cloud Storage
3. **cert-manager** - DNS-01 challenges via Cloud DNS
4. **External DNS** - Manage DNS records in Cloud DNS

Service account emails are available as Terraform outputs:

```bash
terraform output external_secrets_sa_email
terraform output velero_sa_email
terraform output cert_manager_sa_email
```

## Troubleshooting

### Cluster Creation Fails

```bash
# Check GCP quotas
gcloud compute project-info describe --project=my-project-id

# View detailed error logs
tail -f cluster/terraform.log
```

### Kubeconfig Not Working

```bash
# Regenerate kubeconfig
gcloud container clusters get-credentials CLUSTER_NAME \
  --region=us-central1 \
  --project=my-gcp-project-123456

# Or extract from Terraform
cd cluster
terraform output -raw kubeconfig > ~/.kube/my-cluster
export KUBECONFIG=~/.kube/my-cluster
kubectl get nodes
```

### Node Pool Not Scaling

```bash
# Check autoscaler status
kubectl describe configmap cluster-autoscaler-status \
  -n kube-system

# View autoscaler logs
kubectl logs -n kube-system \
  -l app=cluster-autoscaler \
  --tail=50
```

### Workload Identity Issues

```bash
# Verify service account binding
gcloud iam service-accounts get-iam-policy \
  external-secrets-sa@PROJECT_ID.iam.gserviceaccount.com

# Test from pod
kubectl run -it test --image=google/cloud-sdk:slim \
  --serviceaccount=external-secrets-sa \
  -- gcloud auth list
```

## Cleanup

### Destroy Cluster

```bash
# Preview what will be destroyed
mise run provision --destroy --dry-run

# Destroy cluster (requires confirmation)
mise run provision --destroy

# Or using bun:
bun scripts/provision.ts --destroy
```

### Delete GCP Resources

```bash
# Remove service accounts
gcloud iam service-accounts delete \
  external-secrets-sa@PROJECT_ID.iam.gserviceaccount.com

# Delete secrets
gcloud secrets delete argocd-admin-password
gcloud secrets delete mongodb-root-password
# ... etc

# Delete state bucket (optional)
gsutil rm -r gs://my-terraform-state-bucket
```

## Next Steps

After cluster is running:

1. **Configure DNS** - Point your domain to LoadBalancer IP
2. **Set Up Monitoring** - Enable Grafana dashboards
3. **Configure Backups** - Set up Velero backup schedules
4. **Add Deployments** - Create client deployment configs
5. **Enable Auto-Sync** - Configure ArgoCD auto-sync policies

## Additional Resources

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Workload Identity Guide](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
- [GKE Pricing Calculator](https://cloud.google.com/products/calculator)
- [Monobase Infrastructure Docs](../../docs/)

## Support

For issues or questions:
- Check [Troubleshooting](#troubleshooting) above
- Review [Infrastructure Documentation](../../docs/infrastructure/)
- File an issue on GitHub
