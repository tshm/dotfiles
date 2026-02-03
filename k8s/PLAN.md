# Plan: Traefik + Authentik SSO via GitOps (Cloudflare Tunnel)

## Goal

Use Traefik as the ingress controller and Authentik as a single SSO layer to protect current (n8n) and future services, managed via Flux/GitOps. Cloudflare Tunnel proxies external access.

## Current State (observed)

- Authentik HelmRelease exists at `manifest/base/authentik/HelmRelease.yaml` but ingressClassName is set to `nginx`.
- Traefik Ingress/IngressRoute examples exist in `manifest/initialSetup/ingress.yaml` and `manifest/initialSetup/ingressroute.yaml`.
- No Traefik HelmRelease/manifests found in the repo (so Traefik likely not deployed via GitOps yet).
- Flux is installed; `manifest/production/gitops` references `appkustomization.yaml`.

## Assumptions

- GitOps/Flux is the desired deployment path for Traefik, Authentik, and application ingress.
- Cloudflare Tunnel (cloudflared) terminates inbound traffic and forwards to Traefik.

## Plan

### 1) Baseline GitOps wiring

1. Verify Flux Kustomization(s) that apply `manifest/production` are enabled and reconciling.
2. Confirm `manifest/base/kustomization.yaml` and `manifest/production/kustomization.yaml` are the right entry points for app resources.

### 2) Deploy Traefik via GitOps

1. Add `manifest/base/traefik/` with:
   - HelmRepository (Traefik chart repo)
   - HelmRelease (Traefik)
   - Namespace manifest if needed
2. Add the new base to `manifest/base/kustomization.yaml` and/or production overlay.
3. Configure Traefik for:
   - IngressClass = `traefik`
   - EntryPoints `web`/`websecure`
   - Forwarded headers / proxy protocol as needed for Cloudflare Tunnel

### 3) Authentik alignment for Traefik

1. Update Authentik HelmRelease to use `ingressClassName: traefik`.
2. Configure Authentik ingress host (Cloudflare DNS).
3. Create Authentik Outpost for forward-auth (Traefik) and expose it internally.

### 4) Traefik SSO middleware

1. Add Traefik `Middleware` resource (forwardAuth) pointing to Authentik outpost.
2. Include required headers (e.g., `X-Authentik-*`) for identity propagation.

### 5) Protect services (n8n as reference)

1. Add/adjust IngressRoute (or Ingress) for n8n:
   - Route host
   - Attach forwardAuth middleware
2. Keep n8n’s built-in auth enabled if desired (double layer).

### 6) Cloudflare Tunnel routing

1. Ensure cloudflared routes the desired hostnames to the Traefik service.
2. Confirm TLS strategy (Cloudflare -> Traefik):
   - If terminating TLS at Cloudflare, Traefik can accept HTTP internally.
   - If end-to-end TLS, ensure certs are issued (cert-manager) and Traefik uses HTTPS.

### 7) Validation

1. `make check` for manifest validation.
2. Flux reconcile/apply Kustomizations.
3. Verify:
   - Traefik pods running
   - Authentik ingress reachable
   - Accessing n8n triggers Authentik login

## Open Questions / Inputs Needed

- Preferred Traefik chart version and configuration values (defaults vs custom).
- Authentik hostname and desired public domain.
- Cloudflare Tunnel configuration file location and how hostnames map to services.
