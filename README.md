# Monobase Infrastructure

**Reusable Kubernetes Infrastructure Template**

This repository provides production-ready, template-based Kubernetes infrastructure that can be easily customized and deployed to any cluster using modern best practices.

## 🎯 Key Features

- **Fork-Based Workflow** - Clients fork this template and add their configuration
- **100% Parameterized** - No hardcoded client-specific values in base template
- **Multi-Domain Gateway** - Support for both platform subdomains (`*.example.com`) and client-owned custom domains (`app.client.com`)
- **Security by Default** - NetworkPolicies, Pod Security Standards, encryption
- **Compliance Ready** - Built-in security controls and compliance features
- **Modern Stack** - Gateway API, ArgoCD GitOps, External Secrets, Velero backups
- **Scalable** - Designed for <500 users, <1TB data per client (scales further if needed)

## 📦 Scope & Repository Structure

This repository contains **complete infrastructure** for deploying applications on Kubernetes.

### Repository Structure

```
monobase-infra/
├── terraform/               # ← OPTIONAL: OpenTofu/Terraform modules
│   ├── modules/             #    - Reusable infrastructure modules
│   │   ├── aws-eks/         #    - AWS EKS, Azure AKS, GCP GKE
│   │   ├── azure-aks/       #    - K3s on-premises, k3d local
│   │   ├── gcp-gke/         #    Only needed if provisioning clusters
│   │   ├── on-prem-k3s/     #    Can skip if cluster already exists
│   │   └── local-k3d/
│   └── examples/            #    Example cluster configurations
│       ├── aws-eks/         #    AWS EKS example
│       ├── azure-aks/       #    Azure AKS example
│       ├── do-doks/         #    DigitalOcean DOKS example
│       └── k3d/             #    Local k3d example
├── values/                  # ← CONFIGURATION: All deployment values
│   ├── cluster/             # ← YOUR CLUSTER: Terraform config (gitignored)
│   ├── infrastructure/      #    Infrastructure component values
│   └── deployments/         #    Application deployment values
├── charts/                  # ← CORE: Helm charts for applications
│   ├── api/
│   ├── api-worker/
│   └── account/
├── deployments/             # ← CORE: Client/environment deployments
│   ├── example-prod/        #    Production reference example
│   ├── example-staging/     #    Staging reference example
│   └── example-k3d/         #    Local k3d development example
├── infrastructure/          # ← CORE: K8s infrastructure components
│   ├── envoy-gateway/
│   ├── argocd/
│   ├── longhorn/
│   └── ...
├── argocd/                  # ← CORE: GitOps configuration
├── scripts/                 # ← CORE: Automation scripts
└── docs/                    # ← CORE: Documentation
```

### What's Included ✅
- **Cluster Provisioning (Optional)**: OpenTofu modules for AWS/Azure/GCP/on-prem/local
- **Application Deployments**: Monobase API, API Worker, Monobase Account Helm charts
- **Storage Infrastructure**: Longhorn distributed block storage
- **Networking & Routing**: Envoy Gateway with Gateway API
- **Security Layer**: NetworkPolicies, Pod Security Standards, RBAC, encryption
- **Backup & Disaster Recovery**: Velero 3-tier backups
- **Monitoring Stack**: Prometheus + Grafana (optional)
- **GitOps**: ArgoCD with App-of-Apps pattern
- **Secrets Management**: External Secrets Operator + Cloud KMS
- **Configuration Profiles**: Pre-configured small/medium/large deployments

### Prerequisites

**Required:**
- ✅ Existing Kubernetes cluster (EKS, AKS, GKE, or self-hosted)
- ✅ kubectl configured and authenticated
- ✅ Helm 3.x installed
- ✅ Cluster meets [minimum requirements](docs/getting-started/INFRASTRUCTURE-REQUIREMENTS.md)

**Minimum Cluster Specs:**
- 3 worker nodes
- 4 CPU cores per node (12 total)
- 16GB RAM per node (48GB total)
- 100GB storage per node

### Optional: Cluster Provisioning

This repository includes OpenTofu/Terraform modules for provisioning Kubernetes clusters. Use the unified `provision.sh` script for all cluster types:

**Supported Platforms:**
- **AWS EKS** - `./scripts/provision.sh --cluster acme-eks`
- **Azure AKS** - `./scripts/provision.sh --cluster acme-aks`
- **GCP GKE** - `./scripts/provision.sh --cluster acme-gke`
- **DigitalOcean DOKS** - `./scripts/provision.sh --cluster acme-doks`
- **On-Premises K3s** - `./scripts/provision.sh --cluster acme-k3s`
- **Local k3d (Development)** - `./scripts/provision.sh --cluster k3d-local`

**Workflow:**
```bash
# 1. Provision cluster
./scripts/provision.sh --cluster k3d-local

# 2. Bootstrap GitOps auto-discovery
./scripts/bootstrap.sh
```

See [terraform/README.md](terraform/README.md) for module documentation and [docs/getting-started/CLUSTER-PROVISIONING.md](docs/getting-started/CLUSTER-PROVISIONING.md) for detailed provisioning workflows.

**This template works with ANY Kubernetes cluster regardless of how it was provisioned.**

## 🚀 Quick Start

**True GitOps:** Empty cluster → Git-driven auto-deployment

### Prerequisites

- Existing Kubernetes cluster (EKS, AKS, GKE, K3s, or any distribution)
- `kubectl` configured and authenticated
- `helm` 3.x installed

### One-Time Bootstrap

```bash
# 1. Fork and clone
git clone https://github.com/monobaselabs/monobase-infra.git
cd monobase-infra

# 2. Bootstrap GitOps auto-discovery (ONE-TIME)
./scripts/bootstrap.sh
```

**That's it for setup!** The bootstrap script:
- ✅ Installs ArgoCD (if not present)
- ✅ Deploys ApplicationSet for auto-discovery
- ✅ ArgoCD now watches deployments/ directory
- ✅ Outputs ArgoCD UI access info

### Add Your First Client/Environment

```bash
# 3. Create client configuration from example
cp -r deployments/example-prod deployments/acme-prod

# 4. Edit configuration
vim deployments/acme-prod/values.yaml
# Required changes:
#   - global.domain: acme.com
#   - global.namespace: acme-prod
#   - argocd.repoURL: https://github.com/yourorg/monobase-infra.git
#   - api.image.tag: "5.215.2" (pin version, not "latest")
#   - account.image.tag: "1.0.0" (pin version, not "latest")

# 5. Commit and push to deploy
git add deployments/acme-prod/
git commit -m "Add acme-prod"
git push
```

**✓ ArgoCD auto-detects and deploys!** No manual commands needed.

### Monitor Deployment

The bootstrap script outputs ArgoCD UI access information. Use the admin credentials provided to log in and monitor your deployments through the ArgoCD web interface.

### Update Your Deployment (True GitOps)

```bash
# Just edit, commit, and push - ArgoCD syncs automatically
vim deployments/acme-prod/values-production.yaml
git commit -am "Update acme-prod: increase replicas"
git push
# ✓ ArgoCD auto-syncs only acme-prod
```

---

#### **Track 2: I Need to Provision a Cluster** 🏗️ (Optional)

If you need to create a Kubernetes cluster first:

```bash
# 1. Fork and clone (same as above)
git clone https://github.com/monobaselabs/monobase-infra.git
cd monobase-infra

# 2. Provision cluster using unified script
./scripts/provision.sh --cluster k3d-local

# For other platforms:
# ./scripts/provision.sh --cluster myclient-eks
# ./scripts/provision.sh --cluster myclient-aks
# ./scripts/provision.sh --cluster myclient-doks

# 3. Script will:
#    - Initialize Terraform
#    - Create cluster infrastructure
#    - Extract and save kubeconfig to ~/.kube/{cluster-name}
#    - Test cluster connectivity

# 4. Bootstrap GitOps auto-discovery (ONE-TIME)
./scripts/bootstrap.sh

# 5. Create client configuration
cp -r deployments/example-prod deployments/acme-prod

# 6. Edit configuration
vim deployments/acme-prod/values.yaml
# Required changes:
#   - global.domain: acme.com
#   - global.namespace: acme-prod
#   - global.storage.provider: cloud-default (EKS/AKS/GKE) or longhorn (on-prem)
#   - argocd.repoURL: https://github.com/yourorg/monobase-infra.git
#   - api.image.tag: "5.215.2" (pin version, not "latest")
#   - account.image.tag: "1.0.0" (pin version, not "latest")

# 7. Commit and push to deploy
git add deployments/acme-prod/
git commit -m "Add acme-prod"
git push
# ✓ ArgoCD auto-detects and deploys!
```

## ⚙️ Configuration Approach

### Example-Based Configuration

This template provides **complete reference examples** for each environment type:

**Reference Examples:**
- `deployments/example-prod/` - Complete production configuration (HA, backups, security)
- `deployments/example-staging/` - Complete staging configuration (single replicas, Mailpit enabled)
- `deployments/example-k3d/` - Complete local development configuration (minimal resources)

**Your Client Config:**
1. Copy the appropriate example to `deployments/yourclient-{env}/`
2. Edit `values.yaml` to change required values (domain, namespace, image tags)
3. Customize as needed (resources, replicas, optional components)

**Example:**
```bash
# Create production deployment
cp -r deployments/example-prod deployments/acme-prod
vim deployments/acme-prod/values.yaml
# Change: domain, namespace, image tags, backup bucket

# Create staging deployment
cp -r deployments/example-staging deployments/acme-staging
vim deployments/acme-staging/values.yaml
# Change: domain, namespace

git add deployments/acme-*
git commit -m "Add acme deployments"
git push
```

See example READMEs for detailed configuration guides.

## 📋 What's Included

### Required Core Components

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Gateway | Envoy Gateway | Shared Gateway API routing, zero-downtime updates |
| API Backend | Monobase API | Core API service |
| Frontend | Monobase Account | React/Vite frontend application |
| Database | PostgreSQL 16.x | Primary datastore with replication |
| Storage | Cloud-native or Longhorn | Persistent storage for databases |
| GitOps | ArgoCD | Declarative deployments with web UI |
| Secrets | External Secrets Operator | Cloud KMS sync (AWS/Azure/GCP) |

### Storage Provider Options

The infrastructure **automatically selects** the appropriate storage provider based on `global.storage.provider`:

| Provider | Use When | StorageClass | Auto-Deploy Longhorn? |
|----------|----------|--------------|----------------------|
| `ebs-csi` | **AWS EKS** | `gp3` | ❌ No (uses native EBS) |
| `azure-disk` | **Azure AKS** | `managed-premium` | ❌ No (uses Azure Disk) |
| `gcp-pd` | **GCP GKE** | `pd-ssd` | ❌ No (uses GCP PD) |
| `longhorn` | **On-prem/Bare-metal** | `longhorn` | ✅ Yes (self-hosted storage) |
| `local-path` | **k3d/k3s dev** | `local-path` | ❌ No (local development) |
| `cloud-default` | **Any cloud** | (cluster default) | ❌ No (uses provider default) |

**Recommendation:**
- **Cloud deployments** (EKS/AKS/GKE): Use native CSI drivers (`ebs-csi`, `azure-disk`, `gcp-pd`)
- **On-premises/bare-metal**: Use `longhorn` for distributed block storage
- **Development**: Use `local-path` for simplicity

### Optional Add-On Components

| Component | Enable When | Purpose |
|-----------|-------------|---------|
| API Worker | Offline/mobile sync needed | Real-time data synchronization |
| Valkey | Search features needed | Full-text search engine |
| MinIO | Self-hosted S3 needed | Object storage (files, images) |
| Monitoring | Production visibility needed | Prometheus + Grafana metrics |
| Velero | Backup/DR required | Kubernetes-native backups |
| Mailpit | Dev/staging only | Email testing (SMTP capture) |

## 🏗️ Architecture

```
Internet → Envoy Gateway (shared, HA) → HTTPRoutes (per client/env) → Applications
                                                                      ↓
                                                            PostgreSQL + Longhorn Storage
                                                            MinIO (optional)
                                                            Valkey (optional)
```

**Key Design Decisions:**
- **Shared Gateway** - One Gateway in `gateway-system`, HTTPRoutes per client (zero-downtime)
- **Multi-Domain Support** - Platform subdomains (`*.example.com`) + client custom domains (`app.client.com`)
- **Centralized Certificates** - All TLS certificates in `gateway-system` namespace (security best practice)
- **Namespace Isolation** - Each client/environment gets separate namespace (`{client}-{env}`)
- **No Overengineering** - No service mesh, no self-hosted Vault (use cloud KMS)
- **Security First** - NetworkPolicies, PSS, encryption, compliance features built-in

## 📁 Template Structure

```
monobase-infra/                   # Base template repository
├── charts/                       # Custom Helm charts
│   ├── api/                  # Monobase API application chart
│   └── account/                # Monobase Account frontend chart
│
├── infrastructure/               # Infrastructure manifests & configs
│   ├── longhorn/                 # Block storage
│   ├── envoy-gateway/            # Gateway API
│   ├── argocd/                   # GitOps
│   ├── external-secrets-operator/ # Secrets management
│   ├── cert-manager/             # TLS certificates
│   ├── velero/                   # Backup solution
│   ├── security/                 # NetworkPolicies, PSS, encryption
│   └── monitoring/               # Optional Prometheus + Grafana
│
├── argocd/                       # ArgoCD application definitions
│   ├── bootstrap/                # App-of-Apps root
│   ├── infrastructure/           # Infrastructure apps
│   └── applications/             # Application apps
│
├── deployments/                  # Configuration directory
│   ├── example-prod/             # Production reference example ⭐
│   │   ├── values.yaml           #   Complete production config (505 lines)
│   │   └── README.md             #   Production deployment guide
│   ├── example-staging/          # Staging reference example ⭐
│   │   ├── values.yaml           #   Complete staging config (450 lines)
│   │   └── README.md             #   Staging deployment guide
│   ├── example-k3d/              # Local k3d development example ⭐
│   │   ├── values.yaml           #   Complete dev config (155 lines)
│   │   └── README.md             #   Local development guide
│   └── [your-client-env]/        # Your client/env configs go here
│
├── docs/                         # Documentation
└── scripts/                      # Automation scripts
```

## 📚 Documentation

**See [docs/INDEX.md](docs/INDEX.md) for complete documentation index.**

### Quick Links

**🚀 Getting Started:**
- [Client Onboarding](docs/getting-started/CLIENT-ONBOARDING.md) - Fork, configure, deploy
- [Deployment Guide](docs/getting-started/DEPLOYMENT.md) - Step-by-step deployment
- [Example Deployments](deployments/) - Production, staging, and k3d reference examples

**🏗️ Architecture:**
- [System Architecture](docs/architecture/ARCHITECTURE.md) - Design decisions, components
- [GitOps with ArgoCD](docs/architecture/GITOPS-ARGOCD.md) - App-of-Apps pattern
- [Gateway API](docs/architecture/GATEWAY-API.md) - Envoy Gateway, HTTPRoutes
- [Multi-Domain Gateway](docs/architecture/MULTI-DOMAIN-GATEWAY.md) - Client custom domains, certificate management
- [Storage](docs/architecture/STORAGE.md) - Longhorn, cloud CSI drivers

**⚙️ Operations:**
- [Certificate Management](docs/operations/CERTIFICATE-MANAGEMENT.md) - TLS certificates, client domains
- [Backup & DR](docs/operations/BACKUP_DR.md) - 3-tier backup, disaster recovery
- [Scaling Guide](docs/operations/SCALING-GUIDE.md) - HPA, storage expansion
- [Troubleshooting](docs/operations/TROUBLESHOOTING.md) - Common issues

**🔐 Security:**
- [Security Hardening](docs/security/SECURITY-HARDENING.md) - Best practices
- [Compliance](docs/security/SECURITY_COMPLIANCE.md) - HIPAA, SOC2, GDPR

**📖 Reference:**
- [Values Reference](docs/reference/VALUES-REFERENCE.md) - All configuration parameters
- [Optimization Summary](docs/reference/OPTIMIZATION-SUMMARY.md) - Simplification history

## 🔄 Syncing Upstream Changes

Clients can pull template updates from the base repository:

```bash
# In your forked repo (one-time setup)
git remote add upstream https://github.com/monobaselabs/monobase-infra.git

# Pull latest template updates
git fetch upstream
git merge upstream/main

# Resolve any conflicts (usually keep your deployments/, accept upstream changes)
git push origin main
```

## 🔐 Security & Compliance

- **NetworkPolicies** - Default-deny, allow-specific traffic patterns
- **Pod Security Standards** - Restricted security profile enforced
- **Encryption at Rest** - PostgreSQL encryption, Longhorn volume encryption
- **Encryption in Transit** - TLS everywhere via cert-manager
- **RBAC** - Least-privilege service accounts
- **Secrets Management** - Never commit secrets, use External Secrets + KMS
- **Compliance** - See compliance documentation in [docs/](docs/)

## ⚙️ Resource Requirements

### Minimum (Core Only)
- **3 nodes** × 4 CPU × 16GB RAM
- **~7 CPU, ~23Gi memory**
- **~100Gi storage** (PostgreSQL)

### Full Stack (All Optional Components)
- **3-5 nodes** × 8 CPU × 32GB RAM
- **~22 CPU, ~53Gi memory**
- **~1.15TB storage** (PostgreSQL + MinIO)

## 🤝 Contributing

Improvements to the base template are welcome! If you implement a useful feature or fix:

1. Make changes in your fork
2. Test thoroughly
3. Submit a pull request to the base template repository
4. Your contribution helps all clients!

## 📞 Support

- **Issues**: GitHub Issues
- **Documentation**: [docs/](docs/)

## 📄 License

[Add your license here]
