# Traefik + Authentik SSO Setup

Complete GitOps configuration for Traefik ingress controller with Authentik SSO integration, managed via Flux.

## Overview

This setup provides:
- **Traefik** as the ingress controller
- **Authentik** as the SSO provider
- **ForwardAuth** middleware for protecting services
- **Cloudflare Tunnel** for external access
- **GitOps** deployment via Flux

## Architecture

```
Internet → Cloudflare Tunnel → Traefik → Authentik ForwardAuth → Services (n8n, etc.)
```

## Quick Start

1. **Prerequisites**:
   - Kubernetes cluster with Flux installed
   - Cloudflare Tunnel configured
   - Domain name configured in Cloudflare

2. **Update Configuration**:
   - Edit `manifest/base/authentik/HelmRelease.yaml` - Update `authentik.domain.tld`
   - Edit `manifest/base/n8n/ingressroute.yaml` - Update `n8n.domain.tld`
   - Configure Cloudflare Tunnel (see `CLOUDFLARE_TUNNEL_SETUP.md`)

3. **Create Secrets**:
   ```bash
   kubectl create namespace authentik
   kubectl create secret generic authentik-secrets \
     --from-literal=akadmin-password='<secure-password>' \
     --from-literal=postgresql-password='<secure-password>' \
     --from-literal=redis-password='<secure-password>' \
     -n authentik
   ```

4. **Deploy**:
   ```bash
   # Validate manifests
   make check

   # Apply via GitOps
   flux reconcile kustomization production --with-source

   # Or apply directly
   kubectl apply -k manifest/production
   ```

5. **Configure Authentik**:
   - Follow steps in `manifest/base/traefik/AUTHENTIK_SETUP.md`

6. **Validate**:
   - Follow steps in `DEPLOYMENT_VALIDATION.md`

## Documentation

- **[PLAN.md](PLAN.md)** - Original implementation plan
- **[DEPLOYMENT_VALIDATION.md](DEPLOYMENT_VALIDATION.md)** - Deployment steps and validation guide
- **[CLOUDFLARE_TUNNEL_SETUP.md](CLOUDFLARE_TUNNEL_SETUP.md)** - Cloudflare Tunnel configuration
- **[manifest/base/traefik/AUTHENTIK_SETUP.md](manifest/base/traefik/AUTHENTIK_SETUP.md)** - Authentik outpost setup

## Components

### Traefik (`manifest/base/traefik/`)
- **HelmRepository.yaml** - Traefik Helm chart source
- **HelmRelease.yaml** - Traefik deployment configuration
- **middleware-authentik.yaml** - ForwardAuth middleware for SSO
- **ns.yaml** - Namespace definition

### Authentik (`manifest/base/authentik/`)
- **HelmRelease.yaml** - Authentik deployment (updated for Traefik)
- Uses existing HelmRepository

### n8n (`manifest/base/n8n/`)
- **ingressroute.yaml** - IngressRoute with SSO protection
- Uses existing deployment and service

## Key Features

✅ **GitOps-native**: All resources managed via Flux
✅ **SSO-protected**: ForwardAuth middleware secures all services
✅ **Cloudflare integration**: Trusted forwarded headers configured
✅ **Production-ready**: Includes validation, troubleshooting, and monitoring guides
✅ **Extensible**: Easy to add more protected services

## Adding More Services

To protect additional services with SSO:

1. Create an IngressRoute:
   ```yaml
   apiVersion: traefik.io/v1alpha1
   kind: IngressRoute
   metadata:
     name: my-service
     namespace: my-namespace
   spec:
     entryPoints:
       - web
       - websecure
     routes:
       - match: Host(`service.domain.tld`)
         kind: Rule
         middlewares:
           - name: authentik-forwardauth
             namespace: traefik
         services:
           - name: my-service
             port: 80
   ```

2. Create an Authentik application (via UI or API)

3. Add Cloudflare Tunnel route

## Troubleshooting

See [DEPLOYMENT_VALIDATION.md](DEPLOYMENT_VALIDATION.md#troubleshooting) for detailed troubleshooting steps.

Quick checks:
```bash
# Check all components
kubectl get pods -n traefik
kubectl get pods -n authentik
kubectl get middleware -A
kubectl get ingressroute -A

# View logs
kubectl logs -n traefik -l app.kubernetes.io/name=traefik
kubectl logs -n authentik -l app.kubernetes.io/name=authentik
```

## Security Notes

1. **Update default hostnames**: Replace all instances of `domain.tld` with your actual domain
2. **Secure secrets**: Use strong passwords for Authentik secrets
3. **Enable TLS**: For production, set up cert-manager and enable end-to-end TLS
4. **Review permissions**: Configure Authentik RBAC and user groups appropriately
5. **Monitor access**: Enable logging and monitoring for security events

## Maintenance

- **Update Traefik**: Modify version in `manifest/base/traefik/HelmRelease.yaml`
- **Update Authentik**: Modify version in `manifest/base/authentik/HelmRelease.yaml`
- **Backup Authentik**: Backup PostgreSQL database and secrets regularly
- **Monitor logs**: Set up log aggregation for Traefik and Authentik

## Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Authentik Documentation](https://docs.goauthentik.io/)
- [Flux Documentation](https://fluxcd.io/docs/)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

## License

This configuration is part of your personal dotfiles repository.
