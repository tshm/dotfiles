# Kubernetes Infrastructure

GitOps-style Kubernetes manifests + Terraform for cloud infrastructure.

## Structure

```
k8s/
├── manifest/           # Kustomize manifests
│   ├── base/           # Shared resources
│   ├── initialSetup/   # Bootstrap configs
│   └── production/     # Production overlays
├── aks/                # Azure Kubernetes Terraform
├── k9s/                # K9s terminal UI config
├── *.tf                # Proxmox/infrastructure Terraform
└── Makefile            # Deployment targets
```

## Where to Look

| Task | Location |
|------|----------|
| Add K8s resource | `manifest/base/` |
| Production overlay | `manifest/production/` |
| Azure infra | `aks/k8s.tf` |
| Proxmox VM | `proxmox_k8s.tf` |
| K9s shortcuts | `k9s/hotkeys.yaml` |

## Environments

- **initialSetup/**: First-time cluster bootstrap (gitops, tunnel, logging)
- **base/**: Shared applications (authentik, longhorn, n8n, webdl)
- **production/**: Production-specific overrides

## Conventions

- **Kustomize**: Use overlays, not forks
- **HelmRelease**: Flux-style Helm deployments
- **Secrets**: Never commit; use sealed-secrets or external
- **devbox**: Local tooling via `devbox.json`

## Notes

- `tmp/` is gitignored - contains build artifacts
- `.env` and `.kubeconfig.*` are gitignored secrets
- Uses direnv for environment loading
