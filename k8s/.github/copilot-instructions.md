# GitHub Copilot / AI Assistant Instructions

## 🔐 CRITICAL: Dotfile Security Policy

**ALL dotfiles (files starting with `.`) MUST be git-ignored unless explicitly approved.**

### Before Creating or Modifying ANY Dotfile

**MANDATORY CHECKS:**

1. **Check if file will contain secrets:**
   ```bash
   # If file contains ANY of these patterns → MUST be gitignored
   grep -iE '(password|secret|token|key|credential|api[_-]?key)' <filename>
   ```

2. **Verify file is in `.gitignore`:**
   - `.env`, `.*.env` → MUST be gitignored
   - `.kubeconfig*` → MUST be gitignored
   - `terraform.tfstate*` → MUST be gitignored
   - `.*.token`, `.*.key` → MUST be gitignored
   - `.docker.config.json` → MUST be gitignored

3. **EXCEPTION: Only these dotfiles may be tracked:**
   - `.gitignore` files (safe, no secrets)
   - `.envrc` (ONLY if no literal secrets)
   - `manifest/production/.app.env` (ONLY hostnames, no secrets)

### AI Agent Decision Tree

```
Creating/modifying a dotfile?
│
├─ Does it contain secrets? (passwords, tokens, keys, credentials)
│  ├─ YES → Add to .gitignore immediately, use .example template
│  └─ NO → Continue to next check
│
├─ Could it contain secrets in the future?
│  ├─ YES → Add to .gitignore immediately, use .example template
│  └─ NO → Continue to next check
│
├─ Is it one of the approved exceptions? (.gitignore, .envrc, .app.env)
│  ├─ YES → Verify it contains NO secrets, then allow
│  └─ NO → Add to .gitignore, use .example template
```

### Safe Patterns

**❌ NEVER do this:**
```bash
# Creating .env with secrets
cat > .env <<EOF
GITHUB_TOKEN=ghp_xxxxx
DATABASE_PASSWORD=secret123
EOF
git add .env  # NEVER!
```

**✅ ALWAYS do this:**
```bash
# Create template instead
cat > .env.example <<EOF
GITHUB_TOKEN=your_github_token_here
DATABASE_PASSWORD=your_database_password_here
EOF
git add .env.example

# Add actual file to .gitignore
echo ".env" >> .gitignore
```

### Required Actions When Working with Secrets

1. **When suggesting code that uses environment variables:**
   - Always suggest using `.env.example` as template
   - Remind user to copy to `.env` (gitignored)
   - Never include real secrets in suggestions

2. **When creating Kubernetes manifests:**
   - Use `existingSecret` references
   - Never inline secrets in YAML
   - Suggest `secretGenerator` with `.secrets.env` (gitignored)

3. **When working with Terraform:**
   - Use `TF_VAR_*` environment variables
   - Mark sensitive outputs with `sensitive = true`
   - Never commit `.tfstate` files

### Emergency: If You Suggest Committing a Secret

**STOP IMMEDIATELY and:**

1. Alert the user: "⚠️ This file may contain secrets and should NOT be committed"
2. Suggest adding to `.gitignore` instead
3. Recommend creating a `.example` template
4. If already committed, provide remediation steps:
   ```bash
   git rm --cached <file>
   git commit -m "Remove sensitive file"
   # If pushed: git-filter-repo required
   ```

## 📋 Repository-Specific Rules

### Two-Phase Deployment Strategy

This repository uses:
1. **Phase 1**: Manual secret creation via `make` targets
2. **Phase 2**: GitOps deployment via Flux

**When suggesting changes:**
- Secrets → Add to Makefile targets (Phase 1)
- Application manifests → Use `existingSecret` (Phase 2)
- Never suggest inline secrets in manifests

### File Structure Patterns

- `manifest/base/` → Shared resources
- `manifest/production/` → Production overlays
- `*.tf` → Terraform infrastructure
- `.env` → Local secrets (GITIGNORED)
- `.env.example` → Template (tracked)

### Code Style

**YAML (Kubernetes):**
- 2 spaces, no tabs
- Always set namespace explicitly
- Use `---` between resources
- Include `app` label for selectors

**Terraform:**
- Use `snake_case` for resources
- Use `SCREAMING_SNAKE_CASE` for env vars
- Always include variable descriptions
- Mark sensitive outputs: `sensitive = true`

**Kustomization:**
- Use `generatorOptions.disableNameSuffixHash: true`
- Use overlays, never fork base resources

## 🤖 Copilot Behavior Guidelines

### When Asked to Create Files

**Before suggesting file creation:**
1. Check if filename starts with `.`
2. Check if content contains secrets
3. If YES to either → Suggest `.gitignore` entry + `.example` template
4. If NO → Proceed with creation

### When Suggesting Git Commands

**NEVER suggest:**
```bash
git add .env
git add .kubeconfig
git add terraform.tfstate
git add *.secret.env
git add -f .anything  # -f flag overrides .gitignore!
```

**ALWAYS verify:**
```bash
# Before suggesting git add
git status --ignored  # Check what's being ignored
grep "^filename" .gitignore  # Verify file is ignored
```

### When Reviewing Code

**Auto-flag these patterns:**
- Hardcoded passwords, tokens, keys
- `git add` commands with dotfiles
- Inline secrets in Kubernetes YAML
- Committed `.env` or `.tfstate` files
- Base64 encoded secrets in manifests

## 📚 Quick Reference

### Secrets in This Repository

**Allowed in code (tracked):**
- References: `existingSecret`, `secretRef`
- Templates: `.env.example`, `.tfvars.example`
- Hostnames: `manifest/production/.app.env` (non-secret values only)

**NEVER allowed in code (must be gitignored):**
- Real credentials: `.env`, `.secrets.env`
- State files: `terraform.tfstate*`
- Kubeconfig: `.kubeconfig*`
- Tokens: `.*.token`, `.cloudflare.token`

### Common Tasks

**User asks: "How do I set up secrets?"**
→ Suggest:
1. Copy `.env.example` to `.env`
2. Fill in real values
3. Run `make <service>` to load into cluster
4. Reference via `existingSecret` in manifests

**User asks: "Add GitHub token to config"**
→ Suggest:
1. Add to `.env` (gitignored): `GITHUB_TOKEN=ghp_...`
2. Reference in code: `process.env.GITHUB_TOKEN`
3. Never hardcode in files

**User asks: "Why is my secret not working?"**
→ Check:
1. Is `.env` file loaded? (`source .envrc`)
2. Is secret created in cluster? (`kubectl get secrets`)
3. Is manifest referencing correct secret name?

## 🎯 Success Criteria

**You're doing it right when:**
- ✅ All dotfiles are either gitignored or approved exceptions
- ✅ No secrets appear in tracked files
- ✅ Templates (`.example`) exist for secret patterns
- ✅ Kubernetes manifests use `existingSecret` references
- ✅ `.gitignore` is comprehensive and up-to-date

**You're doing it wrong when:**
- ❌ Suggesting `git add .env` or similar
- ❌ Hardcoding secrets in code
- ❌ Creating dotfiles without checking .gitignore
- ❌ Using inline secrets in YAML

---

**For full security guidelines, see [SECURITY.md](../SECURITY.md)**
