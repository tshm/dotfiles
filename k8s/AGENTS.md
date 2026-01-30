# Kubernetes Infrastructure

GitOps-style Kubernetes manifests + Terraform for cloud infrastructure.

## Quick Reference

| Task | Command |
|------|---------|
| Validate all manifests | `make check` |
| Validate single directory | `make manifest/base/n8n` |
| Cluster status | `make status` |
| Apply initial setup | `make config` |
| Apply GitOps | `make gitops` |
| Terraform apply | `make create` |
| Terraform destroy | `make destroy` |

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

- `.env` files (gitignored) for local development
- `secretGenerator` in kustomization.yaml with `.secrets.env` files
- `existingSecret` references in HelmRelease values
- Sealed-secrets or external secret operators for production

Gitignored patterns: `.env`, `.kubeconfig*`, `*.tfstate*`, `.*.env`

## Common Workflows

### Adding a New Application

1. Create directory: `manifest/base/<app-name>/`
2. Add `kustomization.yaml` with resources
3. Add deployment, service, and other manifests
4. Reference from parent kustomization or create production overlay
5. Validate: `make manifest/base/<app-name>`

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
