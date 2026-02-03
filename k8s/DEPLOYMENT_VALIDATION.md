# Deployment and Validation Guide

This guide walks through deploying and validating the Traefik + Authentik SSO integration.

## Pre-Deployment Checklist

Before deploying, ensure:

- [ ] Flux is installed and running in the cluster
- [ ] You have updated domain names in:
  - [ ] `manifest/base/authentik/HelmRelease.yaml` (line 41: `authentik.domain.tld`)
  - [ ] `manifest/base/n8n/ingressroute.yaml` (line 11: `n8n.domain.tld`)
  - [ ] Cloudflare Tunnel configuration (see `CLOUDFLARE_TUNNEL_SETUP.md`)
- [ ] Authentik secrets exist in the cluster:
  ```bash
  kubectl create namespace authentik
  kubectl create secret generic authentik-secrets \
    --from-literal=akadmin-password='<secure-password>' \
    --from-literal=postgresql-password='<secure-password>' \
    --from-literal=redis-password='<secure-password>' \
    -n authentik
  ```
- [ ] n8n secrets and configmaps exist (check existing setup)

## Deployment Steps

### Step 1: Validate Manifests

```bash
make check
```

All manifests should be valid with no errors.

### Step 2: Commit Changes

```bash
git add manifest/
git commit -m "feat: Add Traefik ingress with Authentik SSO integration"
git push
```

### Step 3: Trigger Flux Reconciliation

```bash
# Check Flux Kustomizations
flux get kustomizations

# Force reconciliation of production kustomization
flux reconcile kustomization production --with-source

# Or manually apply if not using Flux yet
kubectl apply -k manifest/production
```

### Step 4: Verify Deployments

#### Check Traefik

```bash
# Check Traefik namespace and resources
kubectl get all -n traefik

# Expected output should include:
# - HelmRelease/traefik (Ready)
# - Deployment/traefik (1/1 Ready)
# - Service/traefik
# - Middleware/authentik-forwardauth

# Check Traefik logs
kubectl logs -n traefik -l app.kubernetes.io/name=traefik -f

# Verify IngressClass
kubectl get ingressclass
```

#### Check Authentik

```bash
# Check Authentik namespace
kubectl get all -n authentik

# Expected output should include:
# - HelmRelease/authentik (Ready)
# - Deployment/authentik-server
# - Deployment/authentik-worker
# - StatefulSet/authentik-postgresql
# - StatefulSet/authentik-redis
# - Service/authentik-server

# Check Authentik logs
kubectl logs -n authentik -l app.kubernetes.io/name=authentik -f

# Wait for all pods to be ready (this may take several minutes)
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=authentik -n authentik --timeout=300s
```

#### Check n8n

```bash
# Check n8n namespace
kubectl get all -n n8n

# Verify IngressRoute was created
kubectl get ingressroute -n n8n

# Check n8n logs
kubectl logs -n n8n -l app=n8n
```

### Step 5: Configure Authentik (First Time Setup)

1. **Access Authentik** via `https://authentik.your-domain.tld`

2. **Complete Initial Setup**:
   - If this is first deployment, Authentik will show initial setup wizard
   - Create admin account
   - Set up email configuration (optional but recommended)

3. **Create Proxy Provider** (see `manifest/base/traefik/AUTHENTIK_SETUP.md` for detailed steps):
   - Navigate to Applications → Providers
   - Create new Proxy Provider
   - Name: `Traefik Forward Auth`
   - Type: `Forward auth (single application)`
   - External host: `https://n8n.your-domain.tld`

4. **Create Application**:
   - Navigate to Applications → Applications
   - Create new Application
   - Name: `n8n`
   - Slug: `n8n`
   - Provider: Select the provider created above

5. **Configure Outpost**:
   - Navigate to Applications → Outposts
   - Use the default `authentik Embedded Outpost` or create new
   - Bind your provider to the outpost
   - Verify it shows as "Healthy"

### Step 6: Configure Cloudflare Tunnel

Follow the guide in `CLOUDFLARE_TUNNEL_SETUP.md` to:
1. Add public hostname routes for `authentik.your-domain.tld` and `n8n.your-domain.tld`
2. Point them to `http://traefik.traefik.svc.cluster.local:80`
3. Set appropriate HTTP host headers

## Validation and Testing

### Test 1: Traefik Health

```bash
# Port-forward to Traefik dashboard
kubectl port-forward -n traefik svc/traefik 9000:9000

# Access dashboard at http://localhost:9000/dashboard/
# You should see:
# - HTTP routers for your services
# - Middleware "authentik-forwardauth"
# - Services showing green status
```

### Test 2: Authentik Accessibility

```bash
# From your browser, access: https://authentik.your-domain.tld
# Expected: Authentik login page loads successfully
# Check for:
# - No SSL/TLS errors
# - Page loads correctly
# - Can log in with admin credentials
```

### Test 3: n8n with SSO Protection

```bash
# From your browser, access: https://n8n.your-domain.tld
# Expected flow:
# 1. Browser is redirected to Authentik login
# 2. After successful login, redirected back to n8n
# 3. n8n application loads

# Debug if issues:
kubectl logs -n traefik -l app.kubernetes.io/name=traefik | grep n8n
kubectl logs -n authentik -l app.kubernetes.io/name=authentik | grep -i forward
```

### Test 4: Middleware Functionality

Check that authentication headers are being passed:

```bash
# Describe the middleware
kubectl describe middleware authentik-forwardauth -n traefik

# Check Traefik can reach Authentik
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -- \
  curl -v http://authentik-server.authentik.svc.cluster.local:9000/outpost.goauthentik.io/auth/traefik
```

### Test 5: End-to-End User Flow

1. **Open incognito/private browser window**
2. **Navigate to**: `https://n8n.your-domain.tld`
3. **Expected**: Redirect to Authentik
4. **Log in** with valid Authentik credentials
5. **Expected**: Redirect back to n8n with successful access
6. **Verify**: User is logged in to n8n
7. **Check headers** (optional): Use browser dev tools to inspect request headers for `X-authentik-*` headers

## Troubleshooting

### Issue: Traefik pods not starting

```bash
kubectl describe pod -n traefik -l app.kubernetes.io/name=traefik
kubectl logs -n traefik -l app.kubernetes.io/name=traefik

# Common causes:
# - HelmRelease not reconciled
# - Invalid values in HelmRelease
# - Resource constraints
```

### Issue: Authentik not reachable

```bash
# Check if Ingress was created
kubectl get ingress -n authentik

# Check Traefik routing
kubectl get ingressroute -A

# Port-forward directly to test service
kubectl port-forward -n authentik svc/authentik-server 9000:9000
# Access http://localhost:9000
```

### Issue: 502 Bad Gateway

```bash
# Check if backend services are running
kubectl get pods -n n8n
kubectl get pods -n authentik

# Check service endpoints
kubectl get endpoints -n traefik traefik
kubectl get endpoints -n authentik authentik-server
kubectl get endpoints -n n8n n8n

# Verify service connectivity from Traefik pod
kubectl exec -n traefik deployment/traefik -- wget -O- http://n8n.n8n.svc.cluster.local
```

### Issue: Authentication loop / Constant redirects

```bash
# Check ForwardAuth middleware configuration
kubectl get middleware authentik-forwardauth -n traefik -o yaml

# Check Authentik outpost status
# Via Authentik UI: Applications → Outposts → Check status

# Verify external URLs match between:
# - Authentik Provider configuration
# - IngressRoute host configuration
# - Cloudflare Tunnel hostname configuration
```

### Issue: SSL/TLS errors

```bash
# Check Cloudflare SSL/TLS mode (should be "Flexible" or "Full")
# If using "Full (strict)", you'll need valid certificates on Traefik

# For now, use "Flexible" mode:
# Cloudflare Dashboard → SSL/TLS → Overview → Choose "Flexible"
```

## Success Criteria

✅ **Deployment successful if**:

1. All pods in `traefik`, `authentik`, and `n8n` namespaces are Running
2. Accessing `https://authentik.your-domain.tld` shows Authentik UI
3. Accessing `https://n8n.your-domain.tld` redirects to Authentik login
4. After Authentik login, user is redirected to n8n application
5. No errors in Traefik or Authentik logs
6. Middleware `authentik-forwardauth` exists and is referenced by n8n IngressRoute

## Next Steps

After successful validation:

1. **Add more services**: Create additional IngressRoutes for other applications
2. **Enable TLS**: Set up cert-manager for end-to-end encryption
3. **Configure RBAC**: Set up user groups and permissions in Authentik
4. **Monitor**: Set up logging and monitoring for Traefik and Authentik
5. **Backup**: Configure backup for Authentik database and configuration
6. **Documentation**: Update with your specific domain names and configurations

## Quick Commands Reference

```bash
# Check everything at once
kubectl get helmrelease -A
kubectl get pods -n traefik
kubectl get pods -n authentik
kubectl get pods -n n8n
kubectl get middleware -A
kubectl get ingressroute -A

# View logs
kubectl logs -n traefik -l app.kubernetes.io/name=traefik -f
kubectl logs -n authentik -l app.kubernetes.io/name=authentik -f
kubectl logs -n n8n -l app=n8n -f

# Restart services
kubectl rollout restart deployment/traefik -n traefik
kubectl rollout restart deployment/authentik-server -n authentik
kubectl rollout restart deployment/n8n -n n8n

# Force Flux reconciliation
flux reconcile kustomization production --with-source
```
