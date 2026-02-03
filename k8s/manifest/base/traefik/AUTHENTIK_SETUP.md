# Authentik Configuration for Traefik SSO

This document outlines the steps needed to configure Authentik for use with Traefik as a forward authentication provider.

## Prerequisites

1. Authentik is deployed and accessible via its ingress
2. Traefik is deployed and running
3. Admin access to Authentik UI

## Configuration Steps

### 1. Access Authentik Admin Interface

Navigate to your Authentik instance (e.g., `https://authentik.domain.tld/if/admin/`)

### 2. Create a Proxy Provider

1. Go to **Applications** → **Providers**
2. Click **Create**
3. Select **Proxy Provider**
4. Configure:
   - **Name**: `Traefik Forward Auth`
   - **Authorization flow**: Select your preferred auth flow (default is usually fine)
   - **Type**: `Forward auth (single application)`
   - **External host**: The URL your applications will be accessed at (e.g., `https://n8n.domain.tld`)

### 3. Create an Application

1. Go to **Applications** → **Applications**
2. Click **Create**
3. Configure:
   - **Name**: e.g., `n8n` or a generic name like `Protected Services`
   - **Slug**: `n8n` (or your chosen slug)
   - **Provider**: Select the provider created in step 2

### 4. Create or Configure an Outpost

1. Go to **Applications** → **Outposts**
2. Either use the default `authentik Embedded Outpost` or create a new one
3. If creating new:
   - **Name**: `traefik-outpost`
   - **Type**: `Proxy`
4. Edit the outpost and bind your provider to it
5. Note the service endpoint (default: `authentik-server:9000`)

### 5. Update Middleware (if needed)

The ForwardAuth middleware in `manifest/base/traefik/middleware-authentik.yaml` is pre-configured with:
- Service address: `http://authentik-server.authentik.svc.cluster.local:9000/outpost.goauthentik.io/auth/traefik`

If your Authentik service name is different, update this accordingly.

## Testing

1. Apply the manifests:
   ```bash
   flux reconcile kustomization production
   ```

2. Verify Traefik middleware is created:
   ```bash
   kubectl get middleware -n traefik
   ```

3. Check Authentik outpost status in the admin UI

## Next Steps

- Configure individual services (like n8n) to use the `authentik-forwardauth` middleware
- Create IngressRoutes for your applications
- Set up user groups and permissions in Authentik

## Troubleshooting

If authentication is not working:

1. Check Traefik logs:
   ```bash
   kubectl logs -n traefik -l app.kubernetes.io/name=traefik
   ```

2. Check Authentik logs:
   ```bash
   kubectl logs -n authentik -l app.kubernetes.io/name=authentik
   ```

3. Verify the middleware configuration:
   ```bash
   kubectl describe middleware authentik-forwardauth -n traefik
   ```

4. Ensure the Authentik outpost is running and healthy
