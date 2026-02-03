# 🔐 DOTFILE SECURITY - QUICK REFERENCE

## ⚠️ CRITICAL RULE

**ALL dotfiles (files starting with `.`) MUST be git-ignored unless explicitly approved.**

## Decision Matrix

| File Type | Action | Reason |
|-----------|--------|--------|
| `.env`, `.*.env` | ❌ GITIGNORE | Contains secrets |
| `.kubeconfig*` | ❌ GITIGNORE | Kubernetes credentials |
| `terraform.tfstate*` | ❌ GITIGNORE | Sensitive outputs |
| `.*.token`, `.*.key` | ❌ GITIGNORE | API tokens/keys |
| `.docker.config.json` | ❌ GITIGNORE | Registry credentials |
| `.secret.env`, `.secrets.env` | ❌ GITIGNORE | Application secrets |
| `.gitignore` | ✅ CAN TRACK | No secrets |
| `.envrc` | ⚠️ VERIFY FIRST | Only if no literal secrets |
| `manifest/production/.app.env` | ⚠️ VERIFY FIRST | Only hostnames, no secrets |

## 3-Second Check Before Committing

```bash
# Does it contain secrets?
grep -iE '(password|secret|token|key|credential)' <filename>

# ✅ No output → May be safe to commit (verify content)
# ❌ Any output → MUST be gitignored
```

## Safe Pattern: Use Templates

```bash
# ❌ WRONG
git add .env

# ✅ RIGHT
cp .env .env.example
# Edit .env.example, replace values with placeholders
git add .env.example
echo ".env" >> .gitignore
```

## Emergency: If Secret Already Committed

```bash
# 1. IMMEDIATELY rotate/revoke the exposed credential
# 2. Remove from index
git rm --cached <file>
git commit -m "Remove sensitive file"

# 3. If already pushed → Purge history
git filter-repo --invert-paths --path <file> --force
git push origin --force --all
```

## Current `.gitignore` Protection

This repository already blocks:
- `.env`, `.default.env`, `.*.env`
- `.kubeconfig*`, `.*kubeconfig*.yaml`
- `terraform.tfstate*`
- `.*.token`, `.cloudflare.token`
- `.secret.env`, `.secrets.env`
- `.docker.config.json`

## For AI Agents

**Before creating ANY file starting with `.`:**
1. Will it contain secrets? → Add to `.gitignore`
2. Could it contain secrets later? → Add to `.gitignore`
3. Is it `.gitignore` itself? → OK to track
4. Is it `.envrc` with NO literal secrets? → OK to track
5. Otherwise → Add to `.gitignore`

---

**See [SECURITY.md](SECURITY.md) for complete guidelines**
