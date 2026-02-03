# Quick Setup Guide - Environment Variables

## 🎯 Simple Configuration

Just edit **one file** to configure all hostnames:

```bash
# Edit this file
vim manifest/production/.app.env
```

**Add your hostnames:**
```bash
APP_ID=testapp
N8N_HOST=n8n.yourdomain.com
AUTHENTIK_HOST=auth.yourdomain.com
```

## ✅ That's it!

The hostnames will automatically be injected into:
- ✅ n8n IngressRoute
- ✅ Authentik HelmRelease ingress configuration

## 🧪 Test Your Configuration

```bash
# Preview what will be deployed
cd manifest/production
kustomize build . | grep -E "(Host\(|hosts:)"
```

You should see your hostnames:
```
    match: Host(`n8n.yourdomain.com`)
        - auth.yourdomain.com
```

## 🚀 Deploy

```bash
# Validate
make check

# Deploy via Flux
flux reconcile kustomization production --with-source

# Or apply directly
kubectl apply -k manifest/production
```

## 📚 Full Documentation

See [ENV_CONFIGURATION.md](ENV_CONFIGURATION.md) for:
- How it works under the hood
- Adding more environment variables
- Environment-specific configurations
- Troubleshooting

## 🔧 Update Cloudflare Tunnel

Don't forget to update your Cloudflare Tunnel configuration with your new hostnames:

1. Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Navigate to **Access** → **Tunnels**
3. Add public hostnames:
   - `n8n.yourdomain.com` → `http://traefik.traefik.svc.cluster.local:80`
   - `auth.yourdomain.com` → `http://traefik.traefik.svc.cluster.local:80`

See [CLOUDFLARE_TUNNEL_SETUP.md](CLOUDFLARE_TUNNEL_SETUP.md) for details.
