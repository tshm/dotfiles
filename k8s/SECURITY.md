# Security Guidelines

## 🔐 Dotfile Security Policy

### Critical Rule: Dotfiles Must Be Git-Ignored

**ALL files starting with `.` (dotfiles) MUST be git-ignored** unless explicitly approved, because they often contain:
- API tokens and credentials
- Passwords and secrets
- Private keys and certificates
- Database connection strings
- Cloud provider credentials

### ❌ NEVER Commit These Dotfiles

| File Pattern | Contains | Risk Level |
|--------------|----------|------------|
| `.env`, `.*.env` | Environment variables, API keys, passwords | 🔴 CRITICAL |
| `.kubeconfig*` | Kubernetes cluster credentials, certificates | 🔴 CRITICAL |
| `terraform.tfstate*` | Infrastructure state with sensitive outputs | 🔴 CRITICAL |
| `.cloudflare.token` | Cloudflare API tokens | 🔴 CRITICAL |
| `.*.token`, `.*.key` | API tokens, private keys | 🔴 CRITICAL |
| `.docker.config.json` | Docker registry credentials | 🔴 CRITICAL |
| `.secret.env`, `.secrets.env` | Application secrets | 🔴 CRITICAL |
| `.id_rsa`, `.ssh/*` | SSH private keys | 🔴 CRITICAL |
| `.default.env` | Default credentials (may contain real values) | 🟡 HIGH |
| `.local.envrc` | Local environment overrides | 🟡 HIGH |

### ✅ Approved Dotfiles (Exception List)

Only these dotfiles MAY be tracked in git:

| File | Purpose | Requirements |
|------|---------|-------------|
| `.gitignore` | Git configuration | Safe (no secrets) |
| `.envrc` | Environment loader (direnv) | ONLY if it contains no literal secrets |
| `manifest/production/.app.env` | GitOps hostname config | ONLY non-secret values (hostnames, domains) |

### 🛡️ Before Committing ANY Dotfile

**MANDATORY CHECKS** - Run these commands before `git add`:

```bash
# 1. Check if file contains secret patterns
grep -iE '(password|secret|token|key|credential|api[_-]?key|private[_-]?key)' <filename>

# 2. Check for base64 encoded values (often secrets)
grep -E '[A-Za-z0-9+/]{40,}={0,2}' <filename>

# 3. Check for GitHub tokens
grep -E '(ghp_|gho_|ghu_|ghs_|ghr_)[A-Za-z0-9]{36,}' <filename>

# 4. Check for AWS credentials
grep -E '(AKIA[0-9A-Z]{16}|aws_secret_access_key)' <filename>

# 5. Check for private keys
grep -E 'BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY' <filename>
```

**If ANY pattern matches → The file MUST be gitignored.**

### 📝 Safe Alternative: Use Templates

Instead of tracking dotfiles with secrets:

```bash
# ❌ WRONG: Track .env with real secrets
git add .env  # NEVER DO THIS

# ✅ RIGHT: Create a template
cp .env .env.example
# Edit .env.example to replace real values with placeholders
sed -i 's/=.*/=YOUR_VALUE_HERE/g' .env.example
git add .env.example
```

### 🚨 Emergency Response: If Secrets Were Committed

**If you accidentally committed secrets:**

1. **IMMEDIATELY rotate/revoke the exposed credentials**
   - GitHub tokens: https://github.com/settings/tokens
   - Cloudflare tokens: Cloudflare dashboard → API Tokens
   - Cloud provider credentials: Respective cloud console
   - Database passwords: Update database and all dependent services

2. **Remove from git index** (if not yet pushed):
   ```bash
   git rm --cached <file>
   git commit -m "Remove sensitive file"
   ```

3. **Purge from git history** (if already pushed):
   ```bash
   # Install git-filter-repo
   pip install git-filter-repo

   # Remove file from ALL commits
   git filter-repo --invert-paths --path <file> --force

   # Force push (coordinate with team)
   git push origin --force --all
   ```

4. **Verify removal**:
   ```bash
   git log --all --full-history -- <file>  # Should show nothing
   ```

5. **Notify team** and ensure everyone re-clones the repository

### 🔍 Current Repository Protection

This repository is protected by `.gitignore` with these patterns:

```gitignore
# Environment files
.env
.default.env
.*.env

# Kubernetes credentials
.kubeconfig*
.*.kubeconfig
.*kubeconfig*.yaml

# Terraform state
terraform.tfstate
terraform.tfstate.backup
*.tfstate*
.terraform.lock*

# Cloud tokens
.*.token
.cloudflare.token

# Application secrets
.secret.env
.secrets.env

# Docker credentials
.docker.config.json

# SSH keys
**/.id_rsa

# Build artifacts
tmp/
output/
.terraform/
```

### 🤖 AI Agent Responsibilities

**When creating or modifying files:**

1. **Before creating a dotfile:**
   - Ask: "Does this file contain or will it contain secrets?"
   - If YES → Add to `.gitignore` immediately
   - If NO → Document why it's safe to track

2. **Before committing changes:**
   - Run secret detection checks (see "Before Committing" section)
   - Verify `.gitignore` is up to date
   - Check `git status` for unexpected dotfiles

3. **When suggesting code changes:**
   - Never suggest storing secrets in dotfiles that aren't gitignored
   - Always recommend template files (`.example`) for secret patterns
   - Suggest environment variables or secret management tools

### 🎯 Secret Management Best Practices

**For Kubernetes secrets:**
1. Use `make` targets to generate secrets from `.secrets.env` (gitignored)
2. Reference secrets via `existingSecret` in HelmRelease
3. Use `secretRef` or `envFrom` in Deployments
4. Consider sealed-secrets or external secret operators for production

**For Terraform:**
1. Store credentials in `.env` (gitignored) as `TF_VAR_*`
2. Mark outputs as `sensitive = true`
3. Use `.tfvars` files (gitignored) for variable values
4. Never commit `terraform.tfstate` files

**For local development:**
1. Copy `.env.example` → `.env` and fill in real values
2. Use direnv or similar tools to auto-load environment
3. Keep credentials in password managers, not files when possible

## 🔒 Additional Security Measures

### Pre-commit Hooks (Recommended)

Install pre-commit to automatically check for secrets:

```bash
# Install pre-commit
pip install pre-commit

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml <<EOF
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: check-added-large-files
      - id: detect-private-key
      - id: check-merge-conflict

  - repo: local
    hooks:
      - id: check-dotfiles
        name: Check dotfiles for secrets
        entry: bash -c 'for file in "\$@"; do [[ "\$file" == .* ]] && grep -qiE "(password|secret|token|key|credential)" "\$file" && echo "ERROR: Dotfile \$file contains secrets" && exit 1; done || true'
        language: system
        files: '^\.'
EOF

# Install hooks
pre-commit install
```

### Audit Current Repository

Run this command to check for any tracked dotfiles:

```bash
# Find all tracked dotfiles
git ls-files | grep '^\.' | while read file; do
  echo "=== $file ==="
  grep -iE '(password|secret|token|key|credential)' "$file" 2>/dev/null || echo "No secrets detected"
done
```

### Regular Security Audits

Schedule regular checks:

```bash
# Weekly audit script
#!/bin/bash
echo "🔍 Security Audit - $(date)"

# Check for secrets in working directory
echo "Checking for exposed secrets on disk..."
find . -type f -name ".*env" -o -name "*.tfstate*" -o -name ".*kubeconfig*" 2>/dev/null

# Verify .gitignore is up to date
echo "Verifying .gitignore coverage..."
git status --ignored

# Check for accidentally tracked dotfiles
echo "Checking for tracked dotfiles..."
git ls-files | grep '^\.'
```

## 📚 Resources

- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [git-filter-repo](https://github.com/newren/git-filter-repo)
- [gitleaks](https://github.com/gitleaks/gitleaks) - Secret scanning tool
- [pre-commit](https://pre-commit.com/) - Git hook framework

---

**Remember: Prevention is better than remediation. Always verify before committing dotfiles.**
