# CI Workflow Differences Analysis

This document identifies differences between `bookverse-inventory` CI workflow (which has been updated for latest JF CLI) and the other BookVerse microservices' CI workflows.

**Date**: 2025-01-XX  
**Purpose**: Document differences to apply `bookverse-inventory` updates to other services after repository re-forking

---

## 🔍 Summary of Key Differences

### ✅ **bookverse-inventory** (Updated - Reference Implementation)
- Uses `jfrog/setup-jfrog-cli@v4` (official action)
- Explicit JFrog CLI version `2.88.0` in promotion job
- Modern OIDC token extraction pattern
- Latest evidence assignment patterns

### ⚠️ **Other Services** (Need Updates)
- `bookverse-recommendations`
- `bookverse-checkout`
- `bookverse-web`

All use `EyalDelarea/setup-jfrog-cli@swampUpAppTrust` (custom fork) and may have older patterns.

---

## 📋 Detailed Differences

### 1. JFrog CLI Setup Action

#### ✅ **bookverse-inventory** (CORRECT)
```yaml
- name: "[Setup] JFrog CLI"
  uses: jfrog/setup-jfrog-cli@v4
  id: jfrog-cli-auth
  with:
    oidc-provider-name: bookverse-inventory-github
    oidc-audience: ${{ vars.JFROG_URL }}
  env:
    JF_URL: ${{ vars.JFROG_URL }}
    JF_PROJECT: ${{ vars.PROJECT_KEY }}
```

**Location**: Line 243-251 (build job), Line 623-632 (promotion job)

#### ⚠️ **Other Services** (NEEDS UPDATE)
```yaml
- name: "[Setup] JFrog CLI"
  uses: EyalDelarea/setup-jfrog-cli@swampUpAppTrust
  id: jfrog-cli-auth
  with:
    oidc-provider-name: bookverse-{service}-github
    oidc-audience: ${{ vars.JFROG_URL }}
  env:
    JF_URL: ${{ vars.JFROG_URL }}
    JF_PROJECT: ${{ vars.PROJECT_KEY }}
```

**Services Affected**:
- `bookverse-recommendations`: Line 244, Line 741
- `bookverse-checkout`: Line 230, Line 784
- `bookverse-web`: Line 219, Line 622

**Action Required**: Replace `EyalDelarea/setup-jfrog-cli@swampUpAppTrust` with `jfrog/setup-jfrog-cli@v4`

---

### 2. JFrog CLI Version Specification

#### ✅ **bookverse-inventory** (CORRECT)
```yaml
- name: "[Setup] JFrog CLI"
  uses: jfrog/setup-jfrog-cli@v4
  id: jfrog-cli-auth
  with:
    version: 2.88.0  # Explicit version in promotion job
    oidc-provider-name: bookverse-inventory-github
    oidc-audience: ${{ vars.JFROG_URL }}
```

**Location**: Line 623-632 (promotion job only)

**Note**: The build job doesn't specify version (uses latest from v4), but promotion job explicitly sets `version: 2.88.0`

#### ⚠️ **Other Services** (NEEDS UPDATE)
- No explicit version specified in any job
- Should add `version: 2.88.0` to promotion job's JFrog CLI setup

**Action Required**: Add `version: 2.88.0` to promotion job's `[Setup] JFrog CLI` step

---

### 3. OIDC Token Extraction Pattern

#### ✅ **bookverse-inventory** (CORRECT - Modern Pattern)
```yaml
- name: "[Setup] Extract OIDC Token from JFrog CLI"
  id: extract-token
  run: |
    echo "🔍 Extracting OIDC token from JFrog CLI step output..."
    
    echo "🔍 Debugging JFrog CLI step outputs..."
    echo "Available outputs:"
    echo "  oidc-user: '${{ steps.jfrog-cli-auth.outputs.oidc-user }}'"
    echo "  oidc-token: '${{ steps.jfrog-cli-auth.outputs.oidc-token }}'"
    echo "  access-token: '${{ steps.jfrog-cli-auth.outputs.access-token }}'"
    echo "  token: '${{ steps.jfrog-cli-auth.outputs.token }}'"
    
    OIDC_TOKEN="${{ steps.jfrog-cli-auth.outputs.oidc-token }}"
    if [[ -n "$OIDC_TOKEN" && "$OIDC_TOKEN" != "null" ]]; then
      echo "✅ Successfully retrieved OIDC token from JFrog CLI step output (oidc-token)"
      echo "📋 Token length: ${#OIDC_TOKEN}"
    else
      echo "❌ OIDC token not available from JFrog CLI step output (oidc-token)"
      echo "🔍 Available outputs from jfrog-cli-auth step:"
      echo "  oidc-user: '${{ steps.jfrog-cli-auth.outputs.oidc-user }}'"
      echo "  oidc-token: '${{ steps.jfrog-cli-auth.outputs.oidc-token }}'"
      echo "  access-token: '${{ steps.jfrog-cli-auth.outputs.access-token }}'"
      echo "  token: '${{ steps.jfrog-cli-auth.outputs.token }}'"
      exit 1
    fi
    
    echo "oidc_token=$OIDC_TOKEN" >> $GITHUB_OUTPUT
```

**Location**: Line 253-279 (build job)

**Key Features**:
- Comprehensive debugging output
- Checks for `null` value
- Detailed error messages
- Uses `oidc-token` output (standard from v4 action)

#### ⚠️ **Other Services** (MOSTLY SIMILAR, BUT CHECK)

**bookverse-recommendations**: Line 253-279 - Similar pattern, but uses custom action  
**bookverse-checkout**: Line 239-253 - Similar pattern, but uses custom action  
**bookverse-web**: Line 228-243 - Similar pattern, but uses custom action

**Action Required**: 
- Verify token extraction works with `jfrog/setup-jfrog-cli@v4`
- Ensure `oidc-token` output is available (should be standard in v4)

---

### 4. Promotion Job OIDC Token Extraction

#### ✅ **bookverse-inventory** (CORRECT)
```yaml
- name: "[Setup] Extract OIDC Token for Promotion Job"
  id: extract-promotion-token
  run: |
    echo "🔍 Extracting OIDC token from JFrog CLI step output for promotion job..."
    
    PROMOTION_OIDC_TOKEN="${{ steps.jfrog-cli-auth.outputs.oidc-token }}"
    if [[ -n "$PROMOTION_OIDC_TOKEN" && "$PROMOTION_OIDC_TOKEN" != "null" ]]; then
      echo "✅ Successfully retrieved OIDC token from JFrog CLI step output (oidc-token)"
      echo "📋 Token length: ${#PROMOTION_OIDC_TOKEN}"
      echo "promotion_oidc_token=$PROMOTION_OIDC_TOKEN" >> $GITHUB_OUTPUT
    else
      echo "❌ OIDC token not available from JFrog CLI step output (oidc-token) in promotion job" >&2
      echo "🔍 Available outputs from jfrog-cli-auth step:"
      echo "  oidc-user: '${{ steps.jfrog-cli-auth.outputs.oidc-user }}'"
      echo "  oidc-token: '${{ steps.jfrog-cli-auth.outputs.oidc-token }}'"
      echo "  access-token: '${{ steps.jfrog-cli-auth.outputs.access-token }}'"
      echo "  token: '${{ steps.jfrog-cli-auth.outputs.token }}'"
      exit 1
    fi
```

**Location**: Line 634-652

#### ⚠️ **Other Services** (SIMILAR BUT CHECK)

**bookverse-recommendations**: Line 750-765
- Similar pattern
- Also sets `JF_OIDC_TOKEN` environment variable: `echo "JF_OIDC_TOKEN=$PROMOTION_OIDC_TOKEN" >> $GITHUB_ENV`
- Has additional comment: `echo "✅ OIDC token exchange completed using new standard pattern"`

**bookverse-checkout**: Line 793-808
- Similar pattern
- Also sets `JF_OIDC_TOKEN` environment variable
- Has comment: `echo "✅ OIDC token extraction completed using new standard pattern"`

**bookverse-web**: Line 631-646
- Similar pattern
- Also sets `JF_OIDC_TOKEN` environment variable
- Has comment: `echo "✅ OIDC token exchange completed using shared bookverse-devops script"`

**Action Required**: 
- Verify all services use the same token extraction pattern
- Ensure `JF_OIDC_TOKEN` is set consistently (bookverse-inventory doesn't set it, but others do - may need to add)

---

### 5. Evidence Assignment Patterns

#### ✅ **bookverse-inventory** (CORRECT - Latest Pattern)

All evidence steps follow this pattern:

```yaml
- name: "[Evidence] {Type} Evidence"
  env:
    EVIDENCE_PRIVATE_KEY: ${{ secrets.EVIDENCE_PRIVATE_KEY }}
    EVIDENCE_KEY_ALIAS: ${{ vars.EVIDENCE_KEY_ALIAS }}
  run: |
    echo "🛡️ Generating evidence for {description} using shared library"
    source bookverse-infra/libraries/bookverse-devops/scripts/evidence-lib.sh
    
    # Service-specific setup
    export PACKAGE_NAME="..."
    export PACKAGE_VERSION="..."
    export SERVICE_NAME="..."
    
    # Call appropriate function
    attach_{type}_evidence "$PACKAGE_NAME" "$PACKAGE_VERSION"
    
    echo "✅ Evidence attached via shared library: {evidence-types}"
```

**Evidence Steps in bookverse-inventory**:
1. **Line 521-536**: `[Evidence] Inventory Image Package Evidence`
   - Uses `attach_docker_package_evidence`
   - Sets `PACKAGE_NAME="inventory"`, `PACKAGE_VERSION="$INVENTORY_VERSION"`

2. **Line 573-585**: `[Evidence] Build Evidence`
   - Uses `attach_build_evidence`
   - No package-specific exports needed

3. **Line 752-764**: `[Evidence] Application Version Evidence`
   - Uses `attach_application_unassigned_evidence`
   - No package-specific exports needed

4. **Line 788**: `attach_application_dev_evidence` (in promotion step)
5. **Line 812**: `attach_application_qa_evidence` (in promotion step)
6. **Line 836**: `attach_application_staging_evidence` (in promotion step)
7. **Line 860**: `attach_application_prod_evidence` (in promotion step)

#### ⚠️ **Other Services** (CHECK FOR CONSISTENCY)

**bookverse-recommendations**:
- Line 494-515: API Image Package Evidence - ✅ Similar pattern
- Line 539-553: Config Package Evidence - ✅ Similar pattern
- Line 573-587: Resources Package Evidence - ✅ Similar pattern
- Line 632-645: Worker Image Package Evidence - ✅ Similar pattern
- Line 684-696: Build Evidence - ✅ Similar pattern
- Line 876-888: Application Version Evidence - ✅ Similar pattern
- Promotion steps: ✅ Similar pattern

**bookverse-checkout**:
- Line 500-514: API Image Package Evidence - ✅ Similar pattern
- Line 535-549: OpenAPI Package Evidence - ✅ Similar pattern
- Line 566-580: Contract Package Evidence - ✅ Similar pattern
- Line 620-634: Worker Image Package Evidence - ✅ Similar pattern
- Line 675-689: Migrations Image Package Evidence - ✅ Similar pattern
- Line 731-743: Build Evidence - ✅ Similar pattern
- Line 918-930: Application Version Evidence - ✅ Similar pattern
- Promotion steps: ✅ Similar pattern

**bookverse-web**:
- Line 391-406: Web Assets Package Evidence - ✅ Similar pattern
- Line 513-528: Web Image Package Evidence - ✅ Similar pattern
- Line 570-581: Build Evidence - ✅ Similar pattern
- Line 793-802: Application Version Evidence - ✅ Similar pattern
- Promotion steps: ✅ Similar pattern

**Action Required**: 
- Verify evidence assignment functions are called correctly
- Ensure all services use the same evidence library functions
- Check that `EVIDENCE_PRIVATE_KEY` and `EVIDENCE_KEY_ALIAS` are set correctly

---

### 6. JF_OIDC_TOKEN Environment Variable

#### ⚠️ **bookverse-inventory** (MISSING)
- Does NOT set `JF_OIDC_TOKEN` environment variable in promotion job
- Uses `steps.extract-promotion-token.outputs.promotion_oidc_token` directly in curl commands

#### ✅ **Other Services** (HAVE IT)
- `bookverse-recommendations`: Line 760 - Sets `JF_OIDC_TOKEN=$PROMOTION_OIDC_TOKEN`
- `bookverse-checkout`: Line 803 - Sets `JF_OIDC_TOKEN=$PROMOTION_OIDC_TOKEN`
- `bookverse-web`: Line 641 - Sets `JF_OIDC_TOKEN=$PROMOTION_OIDC_TOKEN`

**Action Required**: 
- **DECISION NEEDED**: Should `bookverse-inventory` also set `JF_OIDC_TOKEN` for consistency?
- Or should other services be updated to use direct step output like `bookverse-inventory`?

**Current Usage in bookverse-inventory**:
```yaml
JF_OIDC_TOKEN="${{ steps.extract-promotion-token.outputs.promotion_oidc_token }}"
```

**Current Usage in other services**:
```yaml
if [[ -z "${JF_OIDC_TOKEN:-}" ]]; then
  echo "❌ Missing JF_OIDC_TOKEN. Ensure OIDC exchange step succeeded." >&2
  exit 1
fi
```

**Recommendation**: Standardize on `bookverse-inventory` pattern (direct step output) as it's more explicit and doesn't rely on environment variable propagation.

---

### 7. Docker Registry Authentication

#### ✅ **bookverse-inventory** (CORRECT - Inline Script)
```yaml
- name: "[Build] Docker Registry Authentication"
  run: |
    echo "🔐 Authenticating Docker with JFrog registry..."
    DOCKER_REGISTRY="${{ vars.JFROG_URL }}"
    OIDC_TOKEN="${{ steps.jfrog-cli-auth.outputs.oidc-token }}"
    
    # Extract username from JWT token
    TOKEN_PAYLOAD=$(echo "$OIDC_TOKEN" | cut -d. -f2)
    # Add padding if needed for base64 decode
    case $((${#TOKEN_PAYLOAD} % 4)) in
      2) TOKEN_PAYLOAD="${TOKEN_PAYLOAD}==" ;;
      3) TOKEN_PAYLOAD="${TOKEN_PAYLOAD}=" ;;
    esac
    CLAIMS=$(echo "$TOKEN_PAYLOAD" | tr '_-' '/+' | base64 -d 2>/dev/null || true)
    
    # Try to extract username from JWT claims
    if command -v jq >/dev/null 2>&1 && [[ -n "$CLAIMS" ]]; then
      DOCKER_USER=$(echo "$CLAIMS" | jq -r '.username // .sub // .subject // empty' 2>/dev/null || echo "")
      if [[ "$DOCKER_USER" == *"/users/"* ]]; then
        DOCKER_USER=${DOCKER_USER##*/users/}
      fi
    fi
    
    # Use fallback if extraction failed
    if [[ -z "$DOCKER_USER" || "$DOCKER_USER" == "null" ]]; then
      DOCKER_USER="oauth2_access_token"
    fi
    
    echo "🔍 Using Docker username: $DOCKER_USER"
    echo "$OIDC_TOKEN" | docker login "$DOCKER_REGISTRY" -u "$DOCKER_USER" --password-stdin
    echo "✅ Docker authentication successful"
```

**Location**: Line 455-485

#### ⚠️ **Other Services** (USE ACTION)

**bookverse-recommendations**: Line 446-451
```yaml
- name: "[Build] Docker Registry Authentication"
  uses: yonatanp-jfrog/bookverse-infra/.github/actions/docker-registry-auth@main
  with:
    oidc-token: ${{ steps.jfrog-cli-auth.outputs.oidc-token }}
    registry-url: ${{ vars.JFROG_URL }}
    verbosity: 'feedback'
```

**bookverse-checkout**: Line 458-463
```yaml
- name: "[Build] Docker Registry Authentication"
  uses: yonatanp-jfrog/bookverse-infra/.github/actions/docker-registry-auth@main
  with:
    oidc-token: ${{ steps.jfrog-cli-auth.outputs.oidc-token }}
    registry-url: ${{ vars.JFROG_URL }}
    verbosity: 'feedback'
```

**bookverse-web**: Line 408-478
- Uses inline script similar to `bookverse-inventory`, but more verbose with additional error handling

**Action Required**: 
- **DECISION NEEDED**: Should all services use the reusable action, or inline script?
- `bookverse-inventory` uses inline script (more control, but more code)
- `bookverse-recommendations` and `bookverse-checkout` use reusable action (cleaner, but dependency on external action)
- `bookverse-web` uses inline script with more error handling

**Recommendation**: Standardize on reusable action for consistency, unless there's a specific need for inline script.

---

## 📊 Summary Table

| Feature | bookverse-inventory | bookverse-recommendations | bookverse-checkout | bookverse-web |
|---------|---------------------|---------------------------|-------------------|---------------|
| **JFrog CLI Action** | `jfrog/setup-jfrog-cli@v4` ✅ | `EyalDelarea/...@swampUpAppTrust` ⚠️ | `EyalDelarea/...@swampUpAppTrust` ⚠️ | `EyalDelarea/...@swampUpAppTrust` ⚠️ |
| **CLI Version** | `2.88.0` (promotion) ✅ | Not specified ⚠️ | Not specified ⚠️ | Not specified ⚠️ |
| **OIDC Token Extraction** | Modern pattern ✅ | Similar ✅ | Similar ✅ | Similar ✅ |
| **JF_OIDC_TOKEN Env Var** | Not set ⚠️ | Set ✅ | Set ✅ | Set ✅ |
| **Docker Auth** | Inline script ✅ | Reusable action ✅ | Reusable action ✅ | Inline script ✅ |
| **Evidence Patterns** | Latest ✅ | Latest ✅ | Latest ✅ | Latest ✅ |

---

## 🎯 Action Items for Updates

### Priority 1: Critical Updates
1. ✅ **Replace JFrog CLI Action**: Change `EyalDelarea/setup-jfrog-cli@swampUpAppTrust` → `jfrog/setup-jfrog-cli@v4`
   - **Files**: All service `ci.yml` files
   - **Locations**: Build job and promotion job `[Setup] JFrog CLI` steps

2. ✅ **Add CLI Version**: Add `version: 2.88.0` to promotion job's JFrog CLI setup
   - **Files**: All service `ci.yml` files
   - **Location**: Promotion job `[Setup] JFrog CLI` step

### Priority 2: Consistency Updates
3. ⚠️ **Standardize JF_OIDC_TOKEN**: Decide whether to:
   - Option A: Add `JF_OIDC_TOKEN` to `bookverse-inventory` (for consistency)
   - Option B: Remove `JF_OIDC_TOKEN` from other services (use direct step output like inventory)
   - **Recommendation**: Option B (direct step output is more explicit)

4. ⚠️ **Standardize Docker Auth**: Decide whether to:
   - Option A: Use reusable action (like recommendations/checkout)
   - Option B: Use inline script (like inventory/web)
   - **Recommendation**: Option A (reusable action is cleaner)

### Priority 3: Verification
5. ✅ **Verify Evidence Assignment**: Ensure all evidence steps use correct functions
6. ✅ **Test OIDC Token Extraction**: Verify token extraction works with `jfrog/setup-jfrog-cli@v4`

---

## 📝 Notes

- **Evidence Assignment**: All services appear to use the same evidence library functions, so this should be consistent once JFrog CLI action is updated.

- **OIDC Token**: The `oidc-token` output should be standard in `jfrog/setup-jfrog-cli@v4`, so existing extraction patterns should work.

- **Version Compatibility**: JFrog CLI version `2.88.0` is specified in `bookverse-inventory` promotion job. This ensures compatibility with latest evidence assignment features.

- **Testing**: After applying updates, test each service's CI workflow to ensure:
  1. OIDC authentication works
  2. Evidence assignment succeeds
  3. Application version creation works
  4. Promotion through stages works

---

## 🔗 Related Files

- `bookverse-inventory/.github/workflows/ci.yml` - Reference implementation
- `bookverse-recommendations/.github/workflows/ci.yml` - Needs updates
- `bookverse-checkout/.github/workflows/ci.yml` - Needs updates
- `bookverse-web/.github/workflows/ci.yml` - Needs updates

---

**Next Steps**: After re-forking repositories, apply the Priority 1 updates first, then test. Address Priority 2 items based on team preference for consistency.
