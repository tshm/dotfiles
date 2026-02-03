# Cloudflare Tunnel Configuration for Traefik

This guide explains how to configure your Cloudflare Tunnel to route traffic to Traefik.

## Current Setup

The current cloudflared deployment is in `manifest/initialSetup/tunnel/cloudflared.yaml` and uses token-based authentication.

## Recommended Configuration

### Option 1: Update via Cloudflare Dashboard (Easiest)

1. Log in to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Navigate to **Access** → **Tunnels**
3. Find your tunnel and click **Configure**
4. Under **Public Hostnames**, add/update entries:

   **For Authentik:**
   - Subdomain: `authentik`
   - Domain: `your-domain.tld`
   - Service: `http://traefik.traefik.svc.cluster.local:80`
   - Additional settings:
     - **No TLS Verify**: Enabled (if using self-signed certs internally)
     - **HTTP Host Header**: `authentik.your-domain.tld`

   **For n8n:**
   - Subdomain: `n8n`
   - Domain: `your-domain.tld`
   - Service: `http://traefik.traefik.svc.cluster.local:80`
   - Additional settings:
     - **HTTP Host Header**: `n8n.your-domain.tld`

   **For Traefik Dashboard (optional):**
   - Subdomain: `traefik`
   - Domain: `your-domain.tld`
   - Service: `http://traefik.traefik.svc.cluster.local:9000`

### Option 2: Use Config File (Advanced)

If you prefer using a config file instead of token authentication:

1. Create a `config.yaml` file:

```yaml
tunnel: <your-tunnel-id>
credentials-file: /etc/cloudflared/creds/credentials.json

ingress:
  # Route for Authentik
  - hostname: authentik.your-domain.tld
    service: http://traefik.traefik.svc.cluster.local:80
    originRequest:
      httpHostHeader: authentik.your-domain.tld
      noTLSVerify: true

  # Route for n8n
  - hostname: n8n.your-domain.tld
    service: http://traefik.traefik.svc.cluster.local:80
    originRequest:
      httpHostHeader: n8n.your-domain.tld
      noTLSVerify: true

  # Catch-all rule (required)
  - service: http_status:404
```

2. Create a ConfigMap:

```bash
kubectl create configmap cloudflared-config \
  --from-file=config.yaml \
  -n default
```

3. Create a Secret for tunnel credentials:

```bash
kubectl create secret generic cloudflared-creds \
  --from-file=credentials.json \
  -n default
```

4. Update the deployment to use the config file instead of `--token`

## TLS Strategy

### Current Recommendation: HTTP between Cloudflare and Traefik

Since Cloudflare Tunnel terminates TLS, the connection between cloudflared and Traefik can be HTTP:

- **Pros**: Simpler setup, no need for cert-manager initially
- **Cons**: Traffic inside the cluster is unencrypted (acceptable if cluster network is trusted)

### Future Enhancement: End-to-End TLS

For production environments, consider enabling TLS between cloudflared and Traefik:

1. Set up cert-manager in the cluster
2. Create an Issuer (Let's Encrypt or self-signed)
3. Request certificates for your domains
4. Configure Traefik to use these certificates
5. Update Cloudflare Tunnel ingress rules to use `https://` and set `noTLSVerify: false`

## Verification Steps

1. After configuring the tunnel, check that cloudflared is running:
   ```bash
   kubectl get pods -l app=cloudflared
   kubectl logs -l app=cloudflared
   ```

2. Test DNS resolution:
   ```bash
   dig authentik.your-domain.tld
   dig n8n.your-domain.tld
   ```

3. Check Traefik is receiving traffic:
   ```bash
   kubectl logs -n traefik -l app.kubernetes.io/name=traefik -f
   ```

4. Access your services:
   - `https://authentik.your-domain.tld` - Should show Authentik login
   - `https://n8n.your-domain.tld` - Should redirect to Authentik for SSO

## Troubleshooting

### Traffic not reaching Traefik

1. Verify the Traefik service exists:
   ```bash
   kubectl get svc -n traefik
   ```

2. Check service endpoints:
   ```bash
   kubectl get endpoints -n traefik
   ```

3. Verify cloudflared can resolve the service:
   ```bash
   kubectl exec -it <cloudflared-pod> -- nslookup traefik.traefik.svc.cluster.local
   ```

### 502/503 Errors

- Check if Traefik pods are running
- Verify IngressRoutes are created
- Check Traefik logs for routing issues
- Ensure services are healthy

### Authentication Loop

- Verify Authentik outpost is running
- Check ForwardAuth middleware configuration
- Review Authentik provider/application settings
- Check that the external URLs match in both Authentik and IngressRoutes

## Security Considerations

1. **Update hostnames**: Replace `domain.tld` with your actual domain in:
   - Cloudflare Tunnel configuration
   - Authentik HelmRelease (`manifest/base/authentik/HelmRelease.yaml`)
   - n8n IngressRoute (`manifest/base/n8n/ingressroute.yaml`)

2. **Enable TLS**: For production, enable end-to-end TLS encryption

3. **Restrict access**: Use Cloudflare Access policies to add an extra layer of protection

4. **Monitor logs**: Regularly check Traefik and Authentik logs for suspicious activity
