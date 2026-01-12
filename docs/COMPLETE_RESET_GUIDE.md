# Complete BookVerse Platform Reset Guide

This guide provides step-by-step instructions to completely reset all BookVerse resources back to their original state.

## 📋 Overview

Resetting BookVerse involves cleaning up resources in this order:
1. **JFrog Platform Resources** (projects, repos, applications, policies, etc.)
2. **GitHub Repository Configuration** (variables, secrets, code changes)
3. **Kubernetes Resources** (if demo was deployed)
4. **Local Resources** (environment files, /etc/hosts entries)

---

## 🗑️ Step 1: Clean Up JFrog Platform Resources

### Option A: Use Cleanup Workflow (Recommended)

The `🗑️ Cleanup (Preview & Execute)` workflow handles all JFrog Platform cleanup:

1. **Preview Mode** (Discover what will be deleted):
   ```bash
   # Go to: https://github.com/YOUR-ORG/bookverse-demo-init/actions
   # Select "🗑️ Cleanup (Preview & Execute)" workflow
   # Click "Run workflow"
   # Set:
   #   - Mode: preview
   #   - Confirmation: (leave empty)
   ```

2. **Execute Mode** (Actually delete):
   ```bash
   # After reviewing preview, run again with:
   #   - Mode: execute
   #   - Confirmation: DELETE
   ```

### What Gets Cleaned Up:

The cleanup workflow removes (in dependency order):
- ✅ Application versions (all versions of all applications)
- ✅ Builds (all CI builds)
- ✅ Unified policies and rules
- ✅ Repositories (all artifact repositories)
- ✅ Applications (AppTrust applications)
- ✅ Project users
- ✅ Lifecycle stages (DEV, QA, STAGING, PROD)
- ✅ OIDC integrations
- ✅ Domain users (@bookverse.com users)
- ✅ Project (the `bookverse` project itself)

### Option B: Manual Cleanup Scripts

If you need more granular control:

```bash
# Set environment variables
export JFROG_URL="https://your-instance.jfrog.io"
export JFROG_ADMIN_TOKEN="your-admin-token"
export PROJECT_KEY="bookverse"

# Navigate to setup scripts
cd .github/scripts/setup

# Clean up in order (each script supports dry-run)
source config.sh

# 1. Clean policies (rules first, then policies)
./cleanup_policies.sh false  # true for dry-run

# 2. Clean application versions
./cleanup_realtime.sh app_versions false

# 3. Clean builds
./cleanup_realtime.sh builds false

# 4. Clean repositories
./cleanup_realtime.sh repositories false

# 5. Clean applications
./cleanup_realtime.sh applications false

# 6. Clean users
./cleanup_realtime.sh users false

# 7. Clean stages
./cleanup_realtime.sh stages false

# 8. Clean OIDC
./cleanup_realtime.sh oidc false

# 9. Clean domain users
./cleanup_realtime.sh domain_users false

# 10. Clean project (final)
./cleanup_realtime.sh project false
```

---

## 🔧 Step 2: Clean Up GitHub Repository Configuration

### A. Remove Repository Variables

The Switch Platform workflow sets these variables in all service repos:
- `JFROG_URL`
- `DOCKER_REGISTRY`
- `PROJECT_KEY`
- `EVIDENCE_KEY_ALIAS`
- `EVIDENCE_PUBLIC_KEY`

**Manual Removal** (for each repository):

```bash
# List of repositories
REPOS=(
  "bookverse-inventory"
  "bookverse-recommendations"
  "bookverse-checkout"
  "bookverse-platform"
  "bookverse-web"
  "bookverse-helm"
  "bookverse-demo-init"
)

# For each repo, remove variables
for repo in "${REPOS[@]}"; do
  echo "Cleaning $repo..."
  gh variable delete JFROG_URL --repo "YOUR-ORG/$repo" || true
  gh variable delete DOCKER_REGISTRY --repo "YOUR-ORG/$repo" || true
  gh variable delete PROJECT_KEY --repo "YOUR-ORG/$repo" || true
  gh variable delete EVIDENCE_KEY_ALIAS --repo "YOUR-ORG/$repo" || true
  gh variable delete EVIDENCE_PUBLIC_KEY --repo "YOUR-ORG/$repo" || true
done
```

**Automated Script** (create a cleanup script):

```bash
#!/bin/bash
# cleanup_github_vars.sh

GH_ORG="${1:-YOUR-ORG}"
REPOS=(
  "bookverse-inventory"
  "bookverse-recommendations"
  "bookverse-checkout"
  "bookverse-platform"
  "bookverse-web"
  "bookverse-helm"
  "bookverse-demo-init"
)

VARS=(
  "JFROG_URL"
  "DOCKER_REGISTRY"
  "PROJECT_KEY"
  "EVIDENCE_KEY_ALIAS"
  "EVIDENCE_PUBLIC_KEY"
)

for repo in "${REPOS[@]}"; do
  echo "Cleaning variables in $GH_ORG/$repo..."
  for var in "${VARS[@]}"; do
    gh variable delete "$var" --repo "$GH_ORG/$repo" 2>/dev/null || echo "  ⚠️  $var not found or already deleted"
  done
done
```

### B. Remove Repository Secrets

The Switch Platform workflow sets these secrets:
- `JFROG_ADMIN_TOKEN`
- `EVIDENCE_PRIVATE_KEY`
- `GH_REPO_DISPATCH_TOKEN` (optional)

**Manual Removal**:

```bash
for repo in "${REPOS[@]}"; do
  echo "Cleaning secrets in $repo..."
  gh secret delete JFROG_ADMIN_TOKEN --repo "YOUR-ORG/$repo" || true
  gh secret delete EVIDENCE_PRIVATE_KEY --repo "YOUR-ORG/$repo" || true
  gh secret delete GH_REPO_DISPATCH_TOKEN --repo "YOUR-ORG/$repo" || true
done
```

### C. Clean Up Code Changes (PRs)

The Switch Platform workflow creates PRs with hardcoded URL replacements. You need to:

1. **Close/Delete PRs**:
   ```bash
   # List PRs created by Switch Platform
   for repo in "${REPOS[@]}"; do
     gh pr list --repo "YOUR-ORG/$repo" --search "switch platform host" --json number,title
   done
   
   # Close them
   for repo in "${REPOS[@]}"; do
     gh pr list --repo "YOUR-ORG/$repo" --search "switch platform host" --json number | \
       jq -r '.[].number' | \
       xargs -I {} gh pr close {} --repo "YOUR-ORG/$repo" --delete-branch || true
   done
   ```

2. **Revert Code Changes** (if PRs were merged):
   - Check each repository for hardcoded JFrog URLs
   - Revert commits that changed URLs
   - Or manually restore original URLs

### D. Clean Up bookverse-demo-init Repository Variables

The `bookverse-demo-init` repository itself has variables that need cleanup:

```bash
# Remove variables from bookverse-demo-init
gh variable delete JFROG_URL --repo "YOUR-ORG/bookverse-demo-init" || true
gh variable delete PROJECT_KEY --repo "YOUR-ORG/bookverse-demo-init" || true
gh variable delete DOCKER_REGISTRY --repo "YOUR-ORG/bookverse-demo-init" || true
gh variable delete GH_REPOSITORY_OWNER --repo "YOUR-ORG/bookverse-demo-init" || true

# Remove secrets
gh secret delete JFROG_ADMIN_TOKEN --repo "YOUR-ORG/bookverse-demo-init" || true
gh secret delete GH_TOKEN --repo "YOUR-ORG/bookverse-demo-init" || true
```

---

## ☸️ Step 3: Clean Up Kubernetes Resources

If you ran the demo deployment:

```bash
# Use the cleanup script
cd /path/to/bookverse-demo-init
./scripts/bookverse-demo.sh --cleanup

# Or manually:
kubectl delete namespace bookverse --ignore-not-found=true
kubectl delete namespace argocd --ignore-not-found=true

# Clean up port forwards
pkill -f "kubectl.*port-forward" 2>/dev/null || true
```

### Clean Up /etc/hosts Entries

```bash
# Remove demo domain entries
sudo sed -i.bak '/bookverse\.demo\|argocd\.demo/d' /etc/hosts

# Or manually edit /etc/hosts and remove:
# 127.0.0.1 bookverse.demo
# 127.0.0.1 argocd.demo
```

---

## 💻 Step 4: Clean Up Local Resources

### A. Remove Local Environment File

```bash
# Remove your local environment.sh (contains secrets)
rm -f /path/to/bookverse-demo-init/environment.sh

# Note: environment.sh.example should remain (it's a template)
```

### B. Clean Up Local Git State

```bash
# If you have local branches from Switch Platform PRs
cd /path/to/bookverse-demo-init
git fetch origin
git branch -D chore/switch-platform-* 2>/dev/null || true

# Clean up any local changes
git reset --hard origin/main
git clean -fd
```

---

## 🔍 Step 5: Resources Referenced But NOT Created

These resources are **referenced** by workflows but **NOT created** during setup. You need to handle them manually:

### 1. GitHub Repositories

**Status**: Forked manually (not created by setup)

**Action Required**:
- If you want to completely remove: Delete the forked repositories
- If you want to keep: No action needed (they're just code repos)

```bash
# List repositories
REPOS=(
  "bookverse-inventory"
  "bookverse-recommendations"
  "bookverse-checkout"
  "bookverse-platform"
  "bookverse-web"
  "bookverse-helm"
)

# Delete repositories (⚠️ DESTRUCTIVE - only if you want to remove everything)
for repo in "${REPOS[@]}"; do
  read -p "Delete $repo? (yes/no): " confirm
  if [[ "$confirm" == "yes" ]]; then
    gh repo delete "YOUR-ORG/$repo" --yes
  fi
done
```

### 2. JFrog Platform Instance

**Status**: Must exist (not created by setup)

**Action Required**: 
- **DO NOT DELETE** - This is your JFrog Platform instance
- Only the `bookverse` project within it is deleted by cleanup

### 3. GitHub Organization/Owner

**Status**: Must exist (not created by setup)

**Action Required**: 
- **NO ACTION** - This is your GitHub org/user account

### 4. Kubernetes Cluster

**Status**: Must exist (not created by setup)

**Action Required**:
- **NO ACTION** - Only namespaces are cleaned up
- The cluster itself remains

### 5. bookverse-infra Repository

**Status**: Referenced but not created

**Location**: `yonatanp-jfrog/bookverse-infra` (or your fork)

**Action Required**:
- If you forked it: Delete your fork if desired
- If using upstream: No action needed

### 6. Evidence Keys in JFrog Platform

**Status**: Created by Switch Platform workflow, but may persist after cleanup

**Action Required** (if cleanup workflow didn't remove them):

```bash
# List evidence keys
curl -s -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
  "$JFROG_URL/artifactory/api/security/keys/trusted" | \
  jq -r '.keys[] | select(.alias | contains("bookverse")) | .alias'

# Delete evidence keys manually
KEY_ALIAS="bookverse-signing-key"
curl -s -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
  "$JFROG_URL/artifactory/api/security/keys/trusted" | \
  jq -r --arg alias "$KEY_ALIAS" '.keys[] | select(.alias == $alias) | .kid' | \
  xargs -I {} curl -X DELETE \
    -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
    "$JFROG_URL/artifactory/api/security/keys/trusted/{}"
```

---

## ✅ Verification Checklist

After cleanup, verify everything is reset:

### JFrog Platform
- [ ] Project `bookverse` does not exist
- [ ] No repositories with `bookverse-` prefix
- [ ] No applications in AppTrust
- [ ] No unified policies with "BookVerse" in name
- [ ] No OIDC integrations for BookVerse services
- [ ] No project users
- [ ] Evidence keys removed (if applicable)

### GitHub
- [ ] All repository variables removed from service repos
- [ ] All repository secrets removed from service repos
- [ ] All PRs from Switch Platform closed/deleted
- [ ] Code changes reverted (if PRs were merged)
- [ ] bookverse-demo-init variables/secrets cleaned

### Kubernetes
- [ ] `bookverse` namespace deleted
- [ ] `argocd` namespace deleted (if created)
- [ ] Port forwards stopped
- [ ] /etc/hosts entries removed

### Local
- [ ] `environment.sh` removed
- [ ] Local branches cleaned up
- [ ] No uncommitted changes

---

## 🚨 Important Notes

1. **Irreversible Operations**: 
   - Deleting GitHub repositories is permanent
   - Deleting JFrog project is permanent (artifacts are lost)
   - Make sure you have backups if needed

2. **Dependencies**:
   - Cleanup must happen in dependency order (workflow handles this)
   - Don't skip steps - dependencies will prevent deletion

3. **Evidence Keys**:
   - Evidence keys may persist in JFrog even after project deletion
   - They're stored at platform level, not project level
   - Manual cleanup may be required

4. **GitHub Secrets/Variables**:
   - These are NOT automatically cleaned up by any workflow
   - Must be removed manually or with custom script

5. **Code Changes**:
   - PRs created by Switch Platform must be closed/deleted manually
   - If merged, code changes must be reverted manually

---

## 🔄 Quick Reset Script

Here's a complete reset script (use with caution):

```bash
#!/bin/bash
# complete_reset.sh - Complete BookVerse reset

set -euo pipefail

GH_ORG="${GH_ORG:-YOUR-ORG}"
JFROG_URL="${JFROG_URL:-}"
JFROG_ADMIN_TOKEN="${JFROG_ADMIN_TOKEN:-}"

echo "⚠️  WARNING: This will delete ALL BookVerse resources!"
read -p "Type 'RESET' to confirm: " confirm
if [[ "$confirm" != "RESET" ]]; then
  echo "Reset cancelled"
  exit 1
fi

# Step 1: Run cleanup workflow (manual - user must run in GitHub UI)
echo "Step 1: Run '🗑️ Cleanup (Preview & Execute)' workflow in GitHub Actions"
echo "  - Mode: execute"
echo "  - Confirmation: DELETE"
read -p "Press Enter after cleanup workflow completes..."

# Step 2: Clean GitHub variables and secrets
echo "Step 2: Cleaning GitHub variables and secrets..."
REPOS=(
  "bookverse-inventory"
  "bookverse-recommendations"
  "bookverse-checkout"
  "bookverse-platform"
  "bookverse-web"
  "bookverse-helm"
  "bookverse-demo-init"
)

VARS=("JFROG_URL" "DOCKER_REGISTRY" "PROJECT_KEY" "EVIDENCE_KEY_ALIAS" "EVIDENCE_PUBLIC_KEY")
SECRETS=("JFROG_ADMIN_TOKEN" "EVIDENCE_PRIVATE_KEY" "GH_REPO_DISPATCH_TOKEN")

for repo in "${REPOS[@]}"; do
  echo "  Cleaning $repo..."
  for var in "${VARS[@]}"; do
    gh variable delete "$var" --repo "$GH_ORG/$repo" 2>/dev/null || true
  done
  for secret in "${SECRETS[@]}"; do
    gh secret delete "$secret" --repo "$GH_ORG/$repo" 2>/dev/null || true
  done
done

# Step 3: Close PRs
echo "Step 3: Closing Switch Platform PRs..."
for repo in "${REPOS[@]}"; do
  gh pr list --repo "$GH_ORG/$repo" --search "switch platform host" --json number | \
    jq -r '.[].number' | \
    xargs -I {} gh pr close {} --repo "$GH_ORG/$repo" --delete-branch 2>/dev/null || true
done

# Step 4: Clean Kubernetes
echo "Step 4: Cleaning Kubernetes resources..."
kubectl delete namespace bookverse --ignore-not-found=true
kubectl delete namespace argocd --ignore-not-found=true
pkill -f "kubectl.*port-forward" 2>/dev/null || true

# Step 5: Clean /etc/hosts
echo "Step 5: Cleaning /etc/hosts..."
if grep -q "bookverse\.demo\|argocd\.demo" /etc/hosts 2>/dev/null; then
  sudo sed -i.bak '/bookverse\.demo\|argocd\.demo/d' /etc/hosts
  echo "  ✅ Removed demo domains from /etc/hosts"
fi

# Step 6: Clean local files
echo "Step 6: Cleaning local files..."
if [[ -f "environment.sh" ]]; then
  rm -f environment.sh
  echo "  ✅ Removed environment.sh"
fi

echo ""
echo "✅ Reset complete!"
echo ""
echo "⚠️  Manual steps remaining:"
echo "  1. Verify JFrog Platform cleanup completed"
echo "  2. Verify all GitHub variables/secrets removed"
echo "  3. Revert code changes if PRs were merged"
echo "  4. Delete evidence keys in JFrog if needed"
```

---

## 📚 Related Documentation

- [Setup Platform Workflow](./SETUP_PLATFORM_WORKFLOW.md) - What gets created
- [Switch Platform Workflow](./PLATFORM_SETUP_COMPARISON.md) - Configuration details
- [Getting Started Guide](./GETTING_STARTED.md) - Initial setup process
