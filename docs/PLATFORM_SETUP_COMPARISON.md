# BookVerse Platform Setup: Switch Platform vs. Bootstrap Scripts Comparison

## Executive Summary

The BookVerse platform has **two parallel approaches** for initial setup and configuration:

1. **Original "Switch Platform" Workflow** - Comprehensive platform migration/configuration tool
2. **Newer Bootstrap Scripts** - Step-by-step local setup scripts

This document compares these approaches and provides recommendations for consolidation.

---

## 🔄 Switch Platform Workflow

**Location**: `.github/workflows/🔄-switch-platform.yml`  
**Script**: `.github/scripts/setup/switch_jfrog_platform.sh`

### What It Does

The Switch Platform workflow is designed for **migrating between JFrog Platform instances** or **refreshing configuration** across all repositories. It performs:

#### 1. Platform Validation
- ✅ Validates new JFrog Platform URL format
- ✅ Tests platform connectivity
- ✅ Verifies authentication with admin token
- ✅ Checks core services availability (Artifactory, Access)

#### 2. Repository Configuration Updates
- ✅ Updates **JFROG_URL** variable across all repos
- ✅ Updates **DOCKER_REGISTRY** variable across all repos  
- ✅ Updates **JFROG_ADMIN_TOKEN** secret across all repos
- ✅ Updates **EVIDENCE_KEY_ALIAS** variable (if configured)
- ✅ Updates **EVIDENCE_PUBLIC_KEY** variable (if configured)
- ✅ Updates **EVIDENCE_PRIVATE_KEY** secret (if configured)

#### 3. Code Updates
- ✅ Scans all repositories for hardcoded JFrog URLs
- ✅ Replaces old platform URLs with new ones
- ✅ Creates PRs with automated replacements
- ✅ Handles multiple old platform patterns (evidencetrial, apptrustswampupc, releases)

#### 4. Verification
- ✅ Retries failed updates with exponential backoff
- ✅ Final verification pass for failed repositories
- ✅ Comprehensive success/failure reporting

### Repositories Updated
```bash
BOOKVERSE_REPOS=(
    "bookverse-inventory"
    "bookverse-recommendations" 
    "bookverse-checkout"
    "bookverse-platform"
    "bookverse-web"
    "bookverse-helm"
    "bookverse-demo-assets"
    "bookverse-demo-init"
)
```

### Key Features
- **Workflow-based**: Runs as GitHub Actions workflow
- **Comprehensive**: Updates both variables AND code
- **Validation**: Extensive platform and authentication validation
- **Retry Logic**: Robust error handling with retries
- **PR Creation**: Automatically creates PRs for code changes

---

## 🚀 Newer Bootstrap Scripts

### Script 1: `create-clean-repos.sh`

**Purpose**: Fork repositories from upstream to target organization

**What It Does**:
- ✅ Forks all BookVerse service repositories
- ✅ Sets up local clones with proper remotes
- ✅ Configures upstream tracking

**Overlap with Switch Platform**: ❌ None (different purpose)

---

### Script 2: `update_evidence_keys.sh`

**Purpose**: Generate and distribute cryptographic evidence keys

**What It Does**:
- ✅ Generates RSA/EC/ED25519 key pairs
- ✅ Uploads public keys to JFrog Platform
- ✅ Sets **EVIDENCE_PRIVATE_KEY** secret in all repos
- ✅ Sets **EVIDENCE_PUBLIC_KEY** variable in all repos
- ✅ Sets **EVIDENCE_KEY_ALIAS** variable in all repos

**Overlap with Switch Platform**: ⚠️ **Partial** - Switch Platform can update evidence keys if they're already set, but doesn't generate them

---

### Script 3: `configure-service-secrets.sh`

**Purpose**: Configure GitHub repository secrets and variables

**What It Does**:
- ✅ Sets **JFROG_URL** variable
- ✅ Sets **PROJECT_KEY** variable  
- ✅ Sets **DOCKER_REGISTRY** variable
- ✅ Optionally sets **GH_REPO_DISPATCH_TOKEN** secret

**Overlap with Switch Platform**: ✅ **Significant Overlap** - Both update the same variables!

**Key Differences**:
| Feature | Switch Platform | `configure-service-secrets.sh` |
|---------|----------------|----------------------------------|
| **JFROG_ADMIN_TOKEN** | ✅ Updates secret | ❌ Does not update |
| **Code Updates** | ✅ Updates hardcoded URLs | ❌ Does not update code |
| **Verification** | ✅ Retry logic with verification | ⚠️ Basic verification |
| **Execution** | GitHub Actions workflow | Local script |
| **EVIDENCE_* vars** | ✅ Updates if present | ❌ Does not update |

---

### Script 4: `apply-environment-values.sh`

**Purpose**: Apply environment values (appears to be a wrapper/helper)

**Overlap**: Minimal - likely a convenience script

---

## 📊 Comparison Matrix

| Functionality | Switch Platform | Bootstrap Scripts | Overlap? |
|--------------|-----------------|-------------------|----------|
| **Update JFROG_URL** | ✅ | ✅ (`configure-service-secrets.sh`) | ✅ **YES** |
| **Update DOCKER_REGISTRY** | ✅ | ✅ (`configure-service-secrets.sh`) | ✅ **YES** |
| **Update JFROG_ADMIN_TOKEN** | ✅ | ❌ | ❌ No |
| **Update EVIDENCE_* vars** | ✅ (if present) | ✅ (`update_evidence_keys.sh`) | ⚠️ **Partial** |
| **Update hardcoded URLs in code** | ✅ | ❌ | ❌ No |
| **Create PRs for code changes** | ✅ | ❌ | ❌ No |
| **Platform validation** | ✅ | ⚠️ Limited | ⚠️ **Partial** |
| **Retry logic** | ✅ | ⚠️ Limited | ⚠️ **Partial** |
| **Generate evidence keys** | ❌ | ✅ (`update_evidence_keys.sh`) | ❌ No |
| **Fork repositories** | ❌ | ✅ (`create-clean-repos.sh`) | ❌ No |

---

## 🔍 Key Differences

### 1. **Execution Context**
- **Switch Platform**: Runs as GitHub Actions workflow (cloud-based)
- **Bootstrap Scripts**: Run locally on developer machines

### 2. **Scope**
- **Switch Platform**: Designed for platform migration/refresh
- **Bootstrap Scripts**: Designed for initial setup from scratch

### 3. **Code Updates**
- **Switch Platform**: ✅ Updates hardcoded URLs in source code
- **Bootstrap Scripts**: ❌ Only updates GitHub variables/secrets

### 4. **Evidence Key Management**
- **Switch Platform**: Updates existing evidence keys
- **Bootstrap Scripts**: Generates new evidence keys

### 5. **JFROG_ADMIN_TOKEN**
- **Switch Platform**: ✅ Updates admin token secret
- **Bootstrap Scripts**: ❌ Does not update admin token

---

## 🎯 Consolidation Recommendations

### Option 1: Enhance Switch Platform (Recommended)

**Make Switch Platform the single source of truth** by adding missing functionality:

1. **Add Initial Setup Mode**
   - Detect if this is initial setup vs. migration
   - If initial setup, skip code URL replacement (no old URLs to replace)
   - Add option to generate evidence keys if not present

2. **Add Evidence Key Generation**
   - Integrate `update_evidence_keys.sh` logic into Switch Platform
   - Generate keys if `EVIDENCE_KEY_ALIAS` is not set
   - Upload to JFrog and distribute to repos

3. **Make Bootstrap Scripts Thin Wrappers**
   - `configure-service-secrets.sh` → Calls Switch Platform workflow via API
   - `update_evidence_keys.sh` → Calls Switch Platform with evidence key generation flag
   - Keep `create-clean-repos.sh` separate (different purpose)

4. **Add Repository Forking Option**
   - Optional step in Switch Platform to fork repos if they don't exist
   - Or keep as separate step but document it as prerequisite

### Option 2: Merge Scripts into Switch Platform

**Consolidate all functionality into Switch Platform workflow**:

1. **Add Setup Mode Detection**
   ```yaml
   inputs:
     setup_mode:
       description: 'Initial setup or platform switch'
       type: choice
       options:
         - initial_setup
         - platform_switch
   ```

2. **Conditional Execution**
   - Initial setup: Create repos, generate keys, configure everything
   - Platform switch: Update existing configuration

3. **Unified Configuration**
   - Single script that handles both scenarios
   - Remove redundant bootstrap scripts

### Option 3: Keep Separate but Document Clearly

**Maintain both but clarify use cases**:

1. **Switch Platform**: Use for platform migration or configuration refresh
2. **Bootstrap Scripts**: Use for initial setup from scratch
3. **Documentation**: Clear decision tree for which to use when

---

## 📋 Recommended Action Plan

### Phase 1: Immediate (Low Risk)
1. ✅ **Document current state** (this document)
2. ✅ **Add Switch Platform to initial setup docs** as alternative
3. ✅ **Update `configure-service-secrets.sh`** to mention Switch Platform alternative

### Phase 2: Short Term (Medium Risk)
1. **Enhance Switch Platform** with initial setup detection
2. **Add evidence key generation** to Switch Platform
3. **Add JFROG_ADMIN_TOKEN update** to `configure-service-secrets.sh` (or deprecate in favor of Switch Platform)

### Phase 3: Long Term (Higher Risk)
1. **Consolidate into single workflow** (Switch Platform)
2. **Deprecate redundant scripts** with migration path
3. **Update all documentation** to use consolidated approach

---

## 🔗 Related Documentation

- [Switch Platform Workflow](https://github.com/yonatanp-jfrog/bookverse-demo-init/blob/main/.github/workflows/%F0%9F%94%84-switch-platform.yml)
- [Setup Platform Workflow](./SETUP_PLATFORM_WORKFLOW.md) - Creates JFrog infrastructure
- [Getting Started Guide](./GETTING_STARTED.md) - Current setup instructions

---

## 💡 Key Insight

**The Switch Platform workflow is more comprehensive** than the bootstrap scripts for configuration management. The bootstrap scripts were likely created to:
1. Provide a local development workflow
2. Break setup into smaller, testable steps
3. Allow developers to run setup without GitHub Actions

However, **Switch Platform already does most of what the bootstrap scripts do**, plus additional features like code updates and better validation.

**Recommendation**: Enhance Switch Platform to handle initial setup scenarios, then use it as the primary configuration tool.
