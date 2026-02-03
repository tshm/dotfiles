# Environment Variable Configuration

This setup uses environment variables for dynamic hostname configuration across different environments.

## Configuration File

Edit `manifest/production/.app.env` to set your hostnames:

```bash
APP_ID=testapp
N8N_HOST=n8n.yourdomain.com
AUTHENTIK_HOST=auth.yourdomain.com
```

## How It Works

The configuration uses Kustomize's `replacements` feature to inject environment variables into manifests:

1. **ConfigMap Generation**: Kustomize reads `.app.env` and creates a ConfigMap named `host-config`
2. **Replacements**: Values from the ConfigMap are substituted into specific fields:
   - `N8N_HOST` → IngressRoute match rule for n8n
   - `AUTHENTIK_HOST` → Authentik HelmRelease ingress host

## What Gets Replaced

### n8n IngressRoute
**Before replacement:**
```yaml
spec:
  routes:
    - match: Host(`n8n.domain.tld`)
```

**After replacement (with N8N_HOST=n8n.yourdomain.com):**
```yaml
spec:
  routes:
    - match: Host(`n8n.yourdomain.com`)
```

### Authentik HelmRelease
**Before replacement:**
```yaml
spec:
  values:
    server:
      ingress:
        hosts:
          - authentik.domain.tld
```

**After replacement (with AUTHENTIK_HOST=auth.yourdomain.com):**
```yaml
spec:
  values:
    server:
      ingress:
        hosts:
          - auth.yourdomain.com
```

## Testing Your Configuration

Preview the generated manifests with your environment variables:

```bash
cd manifest/production
kustomize build .
```

Look for your hostnames in the output:
```bash
kustomize build . | grep -E "(Host\(|hosts:)"
```

Expected output:
```
        hosts:
    match: Host(`n8n.yourdomain.com`)
        - auth.yourdomain.com
```

## Validation

After updating `.app.env`, validate all manifests:

```bash
make check
```

## Deployment

### Via Flux (GitOps)
```bash
# Commit your .app.env changes
git add manifest/production/.app.env
git commit -m "Update hostnames for production"
git push

# Trigger reconciliation
flux reconcile kustomization production --with-source
```

### Direct Apply
```bash
kubectl apply -k manifest/production
```

## Adding More Hostnames

To add more services with environment-based hostnames:

1. **Add to .app.env**:
   ```bash
   MY_SERVICE_HOST=service.yourdomain.com
   ```

2. **Update production/kustomization.yaml** replacements:
   ```yaml
   replacements:
     - source:
         kind: ConfigMap
         name: host-config
         fieldPath: data.MY_SERVICE_HOST
       targets:
         - select:
             kind: IngressRoute
             name: my-service
             namespace: my-namespace
           fieldPaths:
             - spec.routes.[kind=Rule].match
           options:
             delimiter: '`'
             index: 1
   ```

## Environment-Specific Configurations

You can create different environments by:

1. **Create overlay directories**:
   ```
   manifest/
     ├── base/
     ├── staging/
     │   ├── kustomization.yaml
     │   └── .app.env  # staging hostnames
     └── production/
         ├── kustomization.yaml
         └── .app.env  # production hostnames
   ```

2. **Different .app.env per environment**:

   **staging/.app.env**:
   ```bash
   N8N_HOST=n8n.staging.yourdomain.com
   AUTHENTIK_HOST=auth.staging.yourdomain.com
   ```

   **production/.app.env**:
   ```bash
   N8N_HOST=n8n.yourdomain.com
   AUTHENTIK_HOST=auth.yourdomain.com
   ```

## Troubleshooting

### Issue: Hostnames not being replaced

1. **Check ConfigMap generation**:
   ```bash
   kustomize build manifest/production | grep -A 5 "kind: ConfigMap"
   ```
   Verify `host-config` ConfigMap contains your variables.

2. **Check .app.env format**:
   - No spaces around `=`
   - No quotes around values
   - Unix line endings (LF, not CRLF)

3. **Verify replacement paths**:
   ```bash
   kustomize build manifest/production --enable-alpha-plugins
   ```

### Issue: Changes not reflected in cluster

1. **Flux may cache**: Force reconciliation
   ```bash
   flux reconcile kustomization production --with-source
   ```

2. **Check Flux logs**:
   ```bash
   flux logs --kind=Kustomization --name=production
   ```

## Security Notes

- **Do not commit sensitive data** to `.app.env`
- Use secrets for credentials (passwords, tokens, API keys)
- `.app.env` is suitable for non-sensitive configuration like hostnames, feature flags, etc.

## Reference

- [Kustomize Replacements](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/replacements/)
- [ConfigMap Generator](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/configmapgenerator/)
