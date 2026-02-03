# Kubernetes Infrastructure

GitOps-style Kubernetes manifests + Terraform for cloud infrastructure.

## Deployment Strategy Overview

**IMPORTANT: This repository uses a two-phase deployment strategy:**

### Phase 1: Manual Secret/Config Setup (`make init`)
- **Purpose**: Bootstrap cluster with secrets and configurations
- **Method**: Run `kubectl` commands by hand (via Makefile targets)
- **What it does**:
  - Creates namespaces
  - Generates `.app.env` and `.secrets.env` files from environment variables
  - Uses kustomize `secretGenerator`/`configMapGenerator` to load them into the cluster
  - Creates secrets that GitOps-managed services will reference
- **Examples**: `make n8n`, `make webdl`, `make config`

### Phase 2: GitOps Service Deployment
- **Purpose**: Deploy and manage services declaratively
- **Method**: Flux reconciles manifests from Git
- **What it does**:
  - Deploys applications (Deployments, Services, IngressRoutes, etc.)
  - References secrets created in Phase 1 via `existingSecret`
  - Continuously reconciles desired state from Git
- **Command**: `flux reconcile kustomization production --with-source`

**Why this approach?**
1. Secrets never committed to Git (security)
2. GitOps manages all application state
3. Clear separation: bootstrap secrets (manual) vs. application deployment (automated)

**Before modifying this repository or cluster:**
- Understand which phase you're working in
- Phase 1 changes: Update Makefile targets and `.env` files
- Phase 2 changes: Update manifests in `manifest/` directories

## Quick Reference

| Task | Command | Phase |
|------|---------|-------|
| Validate all manifests | `make check` | Both |
| Validate single directory | `make manifest/base/n8n` | Phase 2 |
| Cluster status | `make status` | - |
| Apply initial setup | `make config` | Phase 1 |
| Setup n8n secrets | `make n8n` | Phase 1 |
| Setup webdl secrets | `make webdl` | Phase 1 |
| Apply GitOps | `make gitops` | Phase 2 |
| Terraform apply | `make create` | Phase 1 |
| Terraform destroy | `make destroy` | - |

## Build & Validation

### Prerequisites

Use devbox for consistent tooling:

```bash
devbox shell  # Activates: kubectl, kustomize, kubeconform, k9s, helm, cloudflared
```

Or ensure direnv is configured (`.envrc` auto-loads devbox).

### Manifest Validation

```bash
# Validate ALL kustomize directories
make check

# Validate a specific directory
make manifest/base/longhorn
make manifest/production

# Manual validation with kubeconform
kubectl kustomize manifest/base/n8n | kubeconform -summary
```

The `check` target uses kubeconform with CRD schemas from datreeio/CRDs-catalog.

### Terraform

```bash
# In root directory (Proxmox/Talos)
terraform init
terraform plan
terraform apply

# In aks/ directory (Azure)
cd aks && terraform init && terraform plan
```

Required environment variables (via `.env` or `TF_VAR_*`):
- `TF_VAR_PROXMOX_API_TOKEN`, `TF_VAR_PROXMOX_USERNAME`, `TF_VAR_PROXMOX_PASSWORD`
- For AKS: `TF_VAR_env`, `TF_VAR_vmtype`, `TF_VAR_minsize`, `TF_VAR_maxsize`

## Project Structure

```
k8s/
├── manifest/
│   ├── base/           # Shared resources (authentik, longhorn, n8n, webdl)
│   ├── initialSetup/   # Bootstrap configs (gitops, tunnel, logging)
│   └── production/     # Production overlays
├── aks/                # Azure Kubernetes Terraform
├── k9s/                # K9s terminal UI config
├── *.tf                # Proxmox/Talos infrastructure Terraform
└── Makefile            # Deployment automation
```

## Code Style Guidelines

### YAML (Kubernetes Manifests)

- **Indentation**: 2 spaces, no tabs
- **Document separator**: Use `---` between resources in same file
- **Comments**: Use `#` with space, place above the line being described
- **Ordering**: `apiVersion`, `kind`, `metadata`, `spec` (standard K8s order)
- **Labels**: Always include `app` label for selectors
- **Namespaces**: Explicitly set in metadata, don't rely on context

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: my-namespace
  labels:
    app: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
```

### Kustomization Files

- Use `resources:` for including other files/directories
- Set `generatorOptions.disableNameSuffixHash: true` for predictable names
- Use overlays (`production/`) to patch base resources, never fork

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../base/n8n

generatorOptions:
  disableNameSuffixHash: true
```

### HelmRelease (Flux)

- Use `helm.toolkit.fluxcd.io/v2` API version
- Set explicit chart versions (avoid `latest`)
- Reference HelmRepository in same namespace
- Use `existingSecret` for credentials, never inline

### Terraform (.tf files)

- **Naming**: `snake_case` for resources and variables
- **Variables**: Use `SCREAMING_SNAKE_CASE` for env-sourced vars
- **Descriptions**: Always include for variables
- **Outputs**: Mark sensitive values with `sensitive = true`
- **Modules**: Pin versions explicitly
- **Tags**: Use `local.common_tags` pattern for consistent tagging

```hcl
variable "PROXMOX_HOST" {
  type        = string
  description = "Proxmox server hostname or IP"
}

resource "azurerm_resource_group" "rg" {
  name     = "home-resources-${random_string.postfix.result}"
  location = "Japan East"
  tags     = local.common_tags
}
```

## Secrets Management

**NEVER commit secrets.** Use these patterns:

### 🔐 CRITICAL: Dotfile Security Rules

**ALL dotfiles (files starting with `.`) MUST be git-ignored** because they often contain sensitive values and should NOT be in public repositories.

**❌ NEVER commit or track these dotfiles:**
- `.env`, `.default.env`, `.*.env` - Environment variables with secrets
- `.kubeconfig*`, `.*kubeconfig*.yaml` - Kubernetes cluster credentials
- `terraform.tfstate*` - Terraform state contains sensitive outputs
- `.cloudflare.token`, `.*.token` - API tokens and credentials
- `.docker.config.json` - Docker registry credentials
- `.secret.env`, `.secrets.env` - Secret environment files
- `**/.id_rsa`, `**/.ssh/` - SSH private keys

**✅ The ONLY dotfiles that MAY be tracked:**
- `.gitignore` files - Git configuration (contains no secrets)
- `.envrc` - Environment loader (ONLY if it contains no literal secrets, just references)
- `.app.env` - Application config (ONLY if it contains ZERO secrets, hostnames only)

**Before committing ANY dotfile, verify:**
```bash
# Check if file contains secrets (GitHub tokens, passwords, keys, etc.)
grep -iE '(password|secret|token|key|credential|api[_-]?key)' <filename>

# If ANY matches found, the file MUST be gitignored
```

**Enforcement:**
- `.gitignore` already blocks most dangerous patterns
- AI agents MUST verify dotfiles contain no secrets before tracking
- When in doubt, gitignore the file and use a `.example` template instead

### Two-Phase Deployment (This Repository's Approach)

1. **Phase 1**: Create secrets manually via `make init` targets (e.g., `make n8n`)
   - Generates `.secrets.env` files from environment variables
   - Uses kustomize `secretGenerator` to load into cluster
   - Secrets are created once during initial setup
2. **Phase 2**: GitOps-managed services reference these secrets
   - HelmRelease uses `existingSecret` to reference Phase 1 secrets
   - Deployments use `secretRef` or `envFrom` to consume secrets
   - No secrets in Git, only references

### General Patterns

- `.env` files (gitignored) for local development
- `secretGenerator` in kustomization.yaml with `.secrets.env` files
- `existingSecret` references in HelmRelease values
- Sealed-secrets or external secret operators for production

**Current gitignored patterns:**
```gitignore
.env
.default.env
.kubeconfig*
*.tfstate*
.*.env
.*.token
.*kubeconfig*.yaml
.cloudflare.token
.secret.env
.secrets.env
.docker.config.json
```

## Common Workflows

### Initial Cluster Setup (Two-Phase Deployment)

**Phase 1: Bootstrap Secrets & Configs**
```bash
# 1. Set environment variables in .env file
cp .default.env .env
vim .env  # Edit with actual values

# 2. Create secrets for each service
make n8n      # Creates n8n secrets and configs
make webdl    # Creates webdl secrets
# Or run all initial setup
make config   # Applies initialSetup manifests

# 3. Verify secrets are created
kubectl get secrets -A
```

**Phase 2: Deploy Services via GitOps**
```bash
# 1. Validate manifests
make check

# 2. Deploy via Flux (GitOps)
make gitops

# 3. Verify deployment
kubectl get helmrelease -A
kubectl get pods -A
```

### Adding a New Application

1. Create directory: `manifest/base/<app-name>/`
2. Add `kustomization.yaml` with resources
3. Add deployment, service, and other manifests
4. Reference from parent kustomization or create production overlay
5. Validate: `make manifest/base/<app-name>`

**If the application needs secrets:**
1. Add Makefile target to create secrets (Phase 1)
2. Use `existingSecret` in manifests (Phase 2)

### Production Overlay

1. Create `manifest/production/<app-name>/kustomization.yaml`
2. Reference base: `resources: [../base/<app-name>]`
3. Add patches or configMapGenerator overrides
4. Apply labels: `commonLabels: { variant: prod }`

### Helm Chart Deployment (Flux)

1. Create HelmRepository resource
2. Create HelmRelease referencing the repository
3. Configure values, use existingSecret for credentials
4. Apply via GitOps or `kubectl apply -k`

## Environment Setup

```bash
# Load environment (direnv auto-runs this)
source .envrc

# Or manually
eval "$(devbox generate direnv --print-envrc)"
dotenv .default.env
dotenv .env
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `status` | Show cluster info and resources |
| `check` | Validate all kustomize manifests |
| `config` | Apply initialSetup manifests |
| `gitops` | Apply GitOps (Flux) configuration |
| `helm` | Add/update Helm repositories |
| `cert-manager` | Install cert-manager with Helm |
| `ingress` | Install Traefik ingress controller |
| `create` | Terraform apply + kubeconfig setup |
| `destroy` | Terraform destroy + cleanup |

## Notes

- `tmp/` and `output/` are gitignored build artifacts
- K9s config in `k9s/` (hotkeys, plugins)
- Uses direnv for automatic environment loading
- Context defaults to `production` (override with `CONTEXT=dev make ...`)
