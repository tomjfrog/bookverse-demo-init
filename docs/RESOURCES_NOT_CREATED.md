# Resources Referenced But Not Created During Setup

This document lists all resources that BookVerse workflows and scripts **reference** but **do NOT create** during the bootstrap/setup process. These must be handled manually.

---

## 🔍 Overview

During BookVerse setup, many resources are created automatically, but some are **prerequisites** that must exist before setup begins, or are **external dependencies** that are referenced but not managed by the setup process.

---

## 📋 Resources NOT Created by Setup

### 1. GitHub Repositories (Service Repos)

**Status**: Must be forked/created manually  
**Location**: Your GitHub organization  
**Created By**: Manual forking via `2_create-clean-res.sh` or GitHub UI

**Repositories**:
- `bookverse-inventory`
- `bookverse-recommendations`
- `bookverse-checkout`
- `bookverse-platform`
- `bookverse-web`
- `bookverse-helm`
- `bookverse-demo-init` (this repository)

**Action Required**:
- Fork from upstream or create manually
- These are NOT deleted by cleanup workflows
- Must be deleted manually if you want to remove them completely

**Referenced In**:
- Switch Platform workflow (updates variables/secrets)
- Setup Platform workflow (references for OIDC setup)
- All CI/CD workflows in service repos

---

### 2. JFrog Platform Instance

**Status**: Must exist (not created by setup)  
**Type**: External infrastructure  
**Created By**: JFrog Platform administrator

**Action Required**:
- **DO NOT DELETE** - This is your JFrog Platform instance
- Only the `bookverse` **project** within it is created/deleted
- The platform instance itself is permanent infrastructure

**Referenced In**:
- All workflows (via `vars.JFROG_URL`)
- All setup scripts (via `JFROG_URL` environment variable)
- All CI/CD workflows

---

### 3. GitHub Organization/Owner

**Status**: Must exist (not created by setup)  
**Type**: GitHub account  
**Created By**: GitHub account creation

**Action Required**:
- **NO ACTION** - This is your GitHub org/user account
- Cannot be "reset" - it's your identity

**Referenced In**:
- All workflows (via `vars.GH_REPOSITORY_OWNER`)
- Switch Platform script (constructs repo paths)
- Setup scripts (for repository access)

---

### 4. Kubernetes Cluster

**Status**: Must exist (not created by setup)  
**Type**: Infrastructure  
**Created By**: Kubernetes cluster setup (Rancher Desktop, cloud provider, etc.)

**Action Required**:
- **NO ACTION** - Only namespaces are created/deleted
- The cluster itself remains
- If using Rancher Desktop: Cluster persists between restarts

**Referenced In**:
- `bookverse-demo.sh` (deployment script)
- Kubernetes validation workflows
- ArgoCD deployment

---

### 5. bookverse-infra Repository

**Status**: Referenced but not created  
**Location**: `yonatanp-jfrog/bookverse-infra` (upstream) or your fork  
**Created By**: External repository (not part of BookVerse setup)

**What It Contains**:
- Shared libraries (`bookverse-core`, `bookverse-devops`)
- Evidence templates
- Shared scripts

**Action Required**:
- If you forked it: Delete your fork if desired
- If using upstream: No action needed
- This repository is cloned during workflows but not created

**Referenced In**:
- Platform aggregation workflow (clones for shared scripts)
- Service CI workflows (references shared libraries)
- Evidence collection (uses templates from this repo)

**Note**: If this repository is deleted or becomes unavailable, workflows will fail.

---

### 6. Evidence Keys in JFrog Platform (Platform Level)

**Status**: Created by Switch Platform, but may persist after project deletion  
**Location**: JFrog Platform (platform-level, not project-level)  
**Created By**: Switch Platform workflow or `3_update_evidence_keys.sh`

**Action Required**:
- Evidence keys are stored at **platform level**, not project level
- They may persist even after `bookverse` project is deleted
- Must be manually deleted if you want complete cleanup

**How to Check**:
```bash
curl -s -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
  "$JFROG_URL/artifactory/api/security/keys/trusted" | \
  jq -r '.keys[] | select(.alias | contains("bookverse"))'
```

**How to Delete**:
```bash
# Get key ID (kid) for the alias
KID=$(curl -s -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
  "$JFROG_URL/artifactory/api/security/keys/trusted" | \
  jq -r --arg alias "bookverse-signing-key" '.keys[] | select(.alias == $alias) | .kid')

# Delete the key
curl -X DELETE \
  -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
  "$JFROG_URL/artifactory/api/security/keys/trusted/$KID"
```

**Referenced In**:
- All evidence collection workflows
- CI/CD workflows that attach evidence
- Evidence library scripts

---

### 7. GitHub Repository Variables in bookverse-demo-init

**Status**: Set manually or by workflows, but NOT cleaned up automatically  
**Location**: `bookverse-demo-init` repository  
**Created By**: Manual setup or Switch Platform workflow

**Variables**:
- `JFROG_URL` - JFrog Platform URL
- `PROJECT_KEY` - Project key (default: "bookverse")
- `DOCKER_REGISTRY` - Docker registry hostname
- `GH_REPOSITORY_OWNER` - GitHub organization name

**Action Required**:
- **NOT automatically cleaned** by cleanup workflows
- Must be manually removed or via script
- These are used by workflows to know where to operate

**Referenced In**:
- All workflows (read these variables)
- Setup scripts (use these for configuration)

---

### 8. GitHub Repository Secrets in bookverse-demo-init

**Status**: Set manually, NOT cleaned up automatically  
**Location**: `bookverse-demo-init` repository  
**Created By**: Manual setup

**Secrets**:
- `JFROG_ADMIN_TOKEN` - Admin token for JFrog Platform
- `GH_TOKEN` - GitHub token for API access

**Action Required**:
- **NOT automatically cleaned** by cleanup workflows
- Must be manually removed
- These contain sensitive credentials

**Referenced In**:
- Cleanup workflow (needs admin token)
- Setup workflows (need tokens for API access)

---

### 9. External Dependencies (Python Libraries)

**Status**: Referenced in code, installed during builds  
**Type**: External packages  
**Created By**: Package managers (pip, npm)

**Examples**:
- `bookverse-core` library (from bookverse-infra)
- FastAPI, uvicorn, pytest (Python packages)
- Various npm packages (for web service)

**Action Required**:
- **NO ACTION** - These are external dependencies
- Installed during Docker builds
- Not "created" by setup, just referenced

**Referenced In**:
- `requirements.txt` files
- `package.json` files
- Dockerfiles
- CI/CD workflows (install during builds)

---

### 10. Docker Images in JFrog Registry

**Status**: Created by CI/CD workflows, NOT by setup  
**Location**: JFrog Docker repositories  
**Created By**: Service CI/CD workflows (build and push)

**Action Required**:
- Cleaned up when repositories are deleted (via cleanup workflow)
- But images may persist if repositories are not deleted
- Manual cleanup may be needed if cleanup workflow fails

**Referenced In**:
- Kubernetes deployments
- CI/CD workflows
- Docker registries

---

## 🔄 Resources Created vs. Referenced

### ✅ Created by Setup Platform Workflow:
- JFrog project (`bookverse`)
- JFrog repositories (Docker, PyPI, npm, etc.)
- AppTrust applications
- Lifecycle stages (DEV, QA, STAGING, PROD)
- Project users
- OIDC integrations
- Unified policies and rules
- Roles

### ✅ Created by Switch Platform Workflow:
- GitHub repository variables (in service repos)
- GitHub repository secrets (in service repos)
- Evidence keys (in JFrog Platform)
- Code changes (PRs with URL replacements)

### ❌ NOT Created (Must Exist):
- GitHub repositories (forked manually)
- JFrog Platform instance (infrastructure)
- GitHub organization (account)
- Kubernetes cluster (infrastructure)
- bookverse-infra repository (external)

### ⚠️ Created But May Persist:
- Evidence keys (platform-level, not project-level)
- GitHub variables in bookverse-demo-init (not cleaned automatically)
- GitHub secrets in bookverse-demo-init (not cleaned automatically)
- Docker images (if repositories not deleted)

---

## 🛠️ Manual Cleanup Required

After running cleanup workflows, you still need to manually clean:

1. **GitHub Repository Variables** (all service repos)
2. **GitHub Repository Secrets** (all service repos)
3. **GitHub PRs** (created by Switch Platform)
4. **Evidence Keys** (in JFrog Platform, if they persist)
5. **bookverse-demo-init Variables/Secrets** (if you want complete reset)
6. **Code Changes** (if PRs were merged)

See [COMPLETE_RESET_GUIDE.md](./COMPLETE_RESET_GUIDE.md) for detailed cleanup instructions.

---

## 📝 Summary

**Resources you must handle manually:**
1. GitHub repositories (delete if you want complete removal)
2. Evidence keys in JFrog (may persist after project deletion)
3. GitHub variables/secrets (not automatically cleaned)
4. GitHub PRs (close/delete manually)
5. Code changes (revert if PRs were merged)

**Resources that persist (infrastructure):**
1. JFrog Platform instance (permanent)
2. GitHub organization (permanent)
3. Kubernetes cluster (permanent)
4. bookverse-infra repository (external dependency)

**Resources automatically cleaned:**
1. JFrog project and all its resources (via cleanup workflow)
2. Kubernetes namespaces (via demo cleanup script)
