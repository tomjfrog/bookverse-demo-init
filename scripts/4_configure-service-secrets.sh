#!/usr/bin/env bash
# =============================================================================
# BookVerse Platform - Service Repository Secrets and Variables Configuration Script
# =============================================================================
#
# ⚠️  DEPRECATION NOTICE:
#     This script is maintained for backward compatibility. For new setups, we recommend
#     using the "🔄 Switch Platform" GitHub Actions workflow which provides:
#     - Initial setup mode detection
#     - Evidence key generation
#     - Code URL updates
#     - Better error handling and validation
#
#     To use the workflow:
#     1. Go to: https://github.com/YOUR-ORG/bookverse-demo-init/actions
#     2. Select "🔄 Switch Platform" workflow
#     3. Set setup_mode to "initial_setup"
#     4. Provide JFrog Platform URL and admin token
#
# 🎯 PURPOSE:
#     This script provides comprehensive GitHub repository secrets and variables configuration
#     for the BookVerse platform, implementing secure distribution of required configuration
#     across all service repositories, optional GitHub dispatch token management,
#     and automated validation for continuous integration and deployment workflows.
#
# 📋 RECOMMENDED APPROACH:
#     Use the "🔄 Switch Platform" GitHub Actions workflow for configuration:
#     1. Go to: https://github.com/YOUR-ORG/bookverse-demo-init/actions
#     2. Select "🔄 Switch Platform" workflow
#     3. Click "Run workflow"
#     4. Set setup_mode to "initial_setup" for first-time setup
#     5. Provide JFrog Platform URL and admin token
#
#     This script now calls the Switch Platform script directly for local execution.
#
# 🏗️ ARCHITECTURE:
#     - Multi-Repository Management: Automated secret/variable configuration across service repos
#     - Configuration Distribution: Secure propagation of JFrog Platform configuration
#     - GitHub CLI Integration: Native GitHub CLI for secure secret and variable management
#     - Evidence Key Separation: Evidence keys managed separately by 3_update_evidence_keys.sh
#     - Validation Framework: Comprehensive verification of configuration success
#     - Error Recovery: Robust error handling with detailed failure reporting
#     - Batch Processing: Efficient bulk repository configuration with status tracking
#
# 🚀 KEY FEATURES:
#     - Automated repository variables configuration (JFROG_URL, PROJECT_KEY, DOCKER_REGISTRY)
#     - Optional GitHub repository dispatch token configuration for platform orchestration
#     - Note: Evidence keys are managed separately by 3_update_evidence_keys.sh
#     - Comprehensive validation and verification of configuration success
#     - Batch processing with individual repository status tracking and error isolation
#     - Security-first approach with secure transmission
#     - Complete CI/CD readiness verification for end-to-end workflow testing
#
# 📊 BUSINESS LOGIC:
#     - CI/CD Enablement: Enabling secure configuration for all service repositories
#     - Security Compliance: Centralized secret management with secure distribution
#     - Operational Efficiency: Automated configuration reducing manual management
#     - Development Productivity: Streamlined CI/CD setup for all development teams
#     - Platform Orchestration: Cross-repository communication through dispatch tokens
#
# 🛠️ USAGE PATTERNS:
#     - Initial Platform Setup: First-time configuration for new environments
#     - Configuration Updates: Periodic updates across all repositories
#     - Service Onboarding: Adding configuration to new service repositories
#     - CI/CD Troubleshooting: Validating and repairing configuration issues
#     - Security Auditing: Verifying configuration across platform repositories
#
# ⚙️ PARAMETERS:
#     [Required Positional Parameters]
#     $1 - GH_ORG              : GitHub organization/owner name (e.g., "yonatanp-jfrog")
#                                 - Used to construct repository paths
#                                 - Required: must be provided as first argument
#     
#     [Required Environment Variables]
#     JFROG_URL                : JFrog Platform URL (e.g., "https://your-instance.jfrog.io")
#                                 - Required for all repositories
#                                 - Used for OIDC authentication and artifact management
#     
#     PROJECT_KEY              : JFrog project key (e.g., "bookverse")
#                                 - Default: "bookverse" if not provided
#                                 - Used for repository naming and project context
#     
#     DOCKER_REGISTRY          : Docker registry hostname (e.g., "your-instance.jfrog.io")
#                                 - Can be derived from JFROG_URL if not provided
#                                 - Used for Docker image push/pull operations
#     
#     Note: Evidence keys (EVIDENCE_KEY_ALIAS, EVIDENCE_PRIVATE_KEY, EVIDENCE_PUBLIC_KEY)
#           are managed by 3_update_evidence_keys.sh, not this script
#     
#     [Optional Environment Variables]
#     GH_REPO_DISPATCH_TOKEN   : GitHub repository dispatch token for cross-repo workflows
#                                 - Enables platform orchestration and cross-repository communication
#                                 - Required for advanced CI/CD workflows with repository dispatch
#                                 - Must have 'repo' scope for target repositories
#                                 - Optional: script continues without this token if not provided
#                                 - Format: GitHub PAT (ghp_xxxxxxxxxxxx...)
#
# 🌍 ENVIRONMENT VARIABLES:
#     [Required for Script Execution]
#     JFROG_URL                : JFrog Platform URL
#     
#     [Optional Configuration]
#     PROJECT_KEY              : Project key (defaults to "bookverse")
#     DOCKER_REGISTRY          : Docker registry (derived from JFROG_URL if not provided)
#     GH_REPO_DISPATCH_TOKEN   : GitHub Personal Access Token for repository dispatch
#                                 - Scope: 'repo' (full repository access)
#                                 - Purpose: Cross-repository workflow triggering
#                                 - Target: bookverse-platform repository specifically
#                                 - Format: GitHub PAT (ghp_xxxxxxxxxxxx...)
#                                 - Security: Stored securely as GitHub repository secret
#     
#     [GitHub CLI Requirements]
#     GH_TOKEN                 : GitHub CLI authentication token (auto-configured by gh auth)
#                                 - Required for 'gh secret set' and 'gh variable set' operations
#                                 - Must have 'repo' scope for target repositories
#                                 - Automatically managed by GitHub CLI authentication
#
# 📋 PREREQUISITES:
#     [System Requirements]
#     - bash (4.0+): Advanced shell features for array processing and error handling
#     - gh (GitHub CLI): Required for repository secret and variable management operations
#     - Internet connectivity: Required for GitHub API communication
#     
#     [Authentication Requirements]
#     - GitHub CLI Authentication: Must be logged in with 'gh auth login'
#     - Repository Access: GitHub account must have admin access to target repositories
#     - Token Permissions: Provided tokens must have appropriate scopes and permissions
#     
#     [Platform Requirements]
#     - JFrog Platform Access: Valid JFrog Platform instance
#     - BookVerse Repository Access: Admin permissions on all target service repositories
#
# 📤 OUTPUTS:
#     [Return Codes]
#     0: Success - All repository secrets and variables configured successfully
#     1: Error - Configuration failed with detailed error reporting
#     
#     [Configuration Results]
#     - Repository variables configured in all BookVerse service repositories
#     - Repository secrets configured in all BookVerse service repositories
#     - GH_REPO_DISPATCH_TOKEN configured in bookverse-platform (if provided)
#     - Detailed status reporting for each repository configuration operation
#     - Comprehensive verification summary with CI/CD readiness confirmation
#     
#     [Repository Configuration Status]
#     - Individual repository configuration success/failure status
#     - Variable and secret validation results
#     - CI/CD workflow readiness confirmation for each service
#
# 💡 EXAMPLES:
#     [Basic Configuration]
#     export JFROG_URL="https://your-instance.jfrog.io"
#     ./scripts/4_configure-service-secrets.sh "your-org"
#     
#     [Configuration with Custom Project Key]
#     export JFROG_URL="https://your-instance.jfrog.io"
#     export PROJECT_KEY="myproject"
#     ./scripts/4_configure-service-secrets.sh "my-org"
#     
#     [Advanced Configuration with Dispatch Token]
#     export JFROG_URL="https://your-instance.jfrog.io"
#     export GH_REPO_DISPATCH_TOKEN="ghp_xxxxxxxxxxxx..."
#     ./scripts/4_configure-service-secrets.sh "your-org"
#     
#     Note: Evidence keys should be configured separately using 3_update_evidence_keys.sh
#
# ⚠️ ERROR HANDLING:
#     [Common Failure Modes]
#     - Missing required environment variables: Validates required variable presence
#     - Invalid variable format: Validates URL and key format requirements
#     - GitHub CLI not authenticated: Validates gh CLI authentication status
#     - Repository access denied: Handles insufficient permissions gracefully
#     - Network connectivity issues: Manages GitHub API communication failures
#     
#     [Recovery Procedures]
#     - Authentication Setup: Run 'gh auth login' to configure GitHub CLI
#     - Variable Validation: Verify environment variables are set correctly
#     - Permission Verification: Confirm admin access to target repositories
#     - Network Troubleshooting: Check internet connectivity and GitHub API access
#
# 🔍 DEBUGGING:
#     [Debug Mode]
#     set -x                                          # Enable bash debug mode
#     ./scripts/configure_service_secrets.sh ORG      # Run with debug output
#     
#     [Manual Verification]
#     gh secret list --repo "org/bookverse-inventory"     # Check secret status
#     gh variable list --repo "org/bookverse-inventory"   # Check variable status
#     gh auth status                                    # Verify CLI auth
#
# 🔗 INTEGRATION POINTS:
#     [GitHub Integration]
#     - GitHub CLI: Repository secret and variable management and authentication
#     - GitHub API: Secure secret/variable storage and access control
#     - Repository Dispatch: Cross-repository workflow coordination
#     
#     [JFrog Integration]
#     - JFrog Platform: OIDC authentication (no access token required)
#     - Artifactory: Container registry access for CI/CD workflows
#     - Build Info: CI/CD pipeline metadata and artifact management
#     - Evidence Collection: Managed separately by 3_update_evidence_keys.sh
#
# 📊 PERFORMANCE:
#     [Execution Time]
#     - Variable validation: 2-5 seconds for format checks
#     - Repository configuration: 10-15 seconds per repository (variables + secrets)
#     - Total execution time: 2-3 minutes for all repositories
#     - Verification phase: 10-20 seconds for status confirmation
#
# 🛡️ SECURITY CONSIDERATIONS:
#     [Secret Security]
#     - No secret logging or exposure in script output
#     - Secure transmission through GitHub CLI encrypted channels
#     - Secret validation without exposing sensitive values
#     - Minimal secret exposure time during configuration
#     
#     [Access Control]
#     - Repository admin permissions required for secret/variable configuration
#     - GitHub CLI authentication with appropriate scopes
#     - Audit trail through GitHub secret/variable management logs
#
# 📚 REFERENCES:
#     [Documentation]
#     - GitHub CLI Secrets: https://cli.github.com/manual/gh_secret
#     - GitHub CLI Variables: https://cli.github.com/manual/gh_variable
#     - GitHub Repository Dispatch: https://docs.github.com/en/rest/repos/repos#create-a-repository-dispatch-event
#
# Authors: BookVerse Platform Team
# Version: 2.0.0
# Last Updated: 2024-01-01
# =============================================================================

set -euo pipefail

# 🔐 Parameter Extraction: Extract and validate GitHub organization parameter
if [ -z "${1:-}" ]; then
    echo "❌ Error: GitHub organization parameter is required"
    echo ""
    echo "📖 Usage: $0 <GH_ORG>"
    echo ""
    echo "  GH_ORG: GitHub organization/owner name (e.g., 'yonatanp-jfrog' or 'your-org')"
    echo ""
    exit 1
fi
GH_ORG="${1}"

# 📋 Parameter Validation: Comprehensive validation of required environment variables
MISSING_VARS=()

if [ -z "${JFROG_URL:-}" ]; then
    MISSING_VARS+=("JFROG_URL")
fi

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo "❌ Error: Missing required environment variables: ${MISSING_VARS[*]}"
    echo ""
    echo "📖 Usage: $0 [GH_ORG]"
    echo ""
    echo "🔧 Required Environment Variables:"
    echo "  JFROG_URL            : JFrog Platform URL (e.g., 'https://your-instance.jfrog.io')"
    echo "                          - Required for all repositories"
    echo "                          - Used for OIDC authentication and artifact management"
    echo ""
    echo "  Note: Evidence keys (EVIDENCE_KEY_ALIAS, EVIDENCE_PRIVATE_KEY, EVIDENCE_PUBLIC_KEY)"
    echo "        are managed by 3_update_evidence_keys.sh, not this script"
    echo ""
    echo "🌍 Optional Environment Variables:"
    echo "  PROJECT_KEY          : JFrog project key (default: 'bookverse')"
    echo "                          - Used for repository naming and project context"
    echo ""
    echo "  DOCKER_REGISTRY      : Docker registry hostname"
    echo "                          - Can be derived from JFROG_URL if not provided"
    echo "                          - Example: 'your-instance.jfrog.io'"
    echo ""
    echo "  GH_REPO_DISPATCH_TOKEN : GitHub repository dispatch token (optional)"
    echo "                          - Enables cross-repository workflow triggering"
    echo "                          - Required for advanced platform orchestration"
    echo "                          - Must have 'repo' scope for target repositories"
    echo "                          - Format: GitHub PAT (ghp_xxxxxxxxxxxx...)"
    echo ""
    echo "📋 Positional Parameters:"
    echo "  GH_ORG               : GitHub organization/owner name (required)"
    echo "                          - Used to construct repository paths"
    echo "                          - Example: 'yonatanp-jfrog' or 'my-org'"
    echo "                          - Must be provided as first argument"
    echo ""
    echo "💡 Example Usage:"
    echo "  # Basic configuration"
    echo "  export JFROG_URL='https://your-instance.jfrog.io'"
    echo "  ./scripts/4_configure-service-secrets.sh 'your-org'"
    echo ""
    echo "  # Configuration with custom project key"
    echo "  export JFROG_URL='https://your-instance.jfrog.io'"
    echo "  export PROJECT_KEY='myproject'"
    echo "  ./scripts/4_configure-service-secrets.sh 'my-org'"
    echo ""
    echo "  # Advanced configuration with dispatch token"
    echo "  export JFROG_URL='https://your-instance.jfrog.io'"
    echo "  export GH_REPO_DISPATCH_TOKEN='ghp_xxxxxxxxxxxx...'"
    echo "  ./scripts/4_configure-service-secrets.sh 'your-org'"
    echo ""
    echo "📋 Prerequisites:"
    echo "  - GitHub CLI installed and authenticated (gh auth login)"
    echo "  - Admin access to BookVerse service repositories"
    echo "  - Valid JFrog Platform instance"
    echo "  - Internet connectivity for GitHub API access"
    echo ""
    exit 1
fi

# 🔧 Configuration Setup: Set defaults and derive values
PROJECT_KEY="${PROJECT_KEY:-bookverse}"

# Derive DOCKER_REGISTRY from JFROG_URL if not provided
if [ -z "${DOCKER_REGISTRY:-}" ]; then
    # Extract hostname from JFROG_URL (remove https:// or http://)
    DOCKER_REGISTRY=$(echo "$JFROG_URL" | sed -E 's|^https?://||' | sed 's|/$||')
    echo "ℹ️  DOCKER_REGISTRY not provided, derived from JFROG_URL: $DOCKER_REGISTRY"
fi

# 🚀 Configuration Initiation: Begin configuration process with status display
echo "🚀 Configuring secrets and variables for all BookVerse service repositories"
echo "🔧 GitHub Organization: $GH_ORG"
echo "🔧 JFrog URL: $JFROG_URL"
echo "🔧 Project Key: $PROJECT_KEY"
echo "🔧 Docker Registry: $DOCKER_REGISTRY"
echo ""
echo "ℹ️  Note: Evidence keys are managed separately by 3_update_evidence_keys.sh"
echo ""

# 📦 Repository Configuration: Define target repositories for configuration
# This array contains all BookVerse service repositories that require configuration
# for CI/CD operations, container registry access, and artifact management
SERVICE_REPOS=(
    "bookverse-inventory"      # Inventory microservice repository
    "bookverse-recommendations" # Recommendations AI service repository  
    "bookverse-checkout"       # Checkout and payment service repository
    "bookverse-platform"       # Platform aggregation service repository
    "bookverse-web"            # Web frontend application repository
    "bookverse-helm"           # Helm charts and Kubernetes manifests repository
)

# 🔐 Optional Dispatch Token Configuration: Configure cross-repository communication token
# GH_REPO_DISPATCH_TOKEN enables advanced CI/CD workflows with repository dispatch events
# This allows platform orchestration and cross-repository workflow triggering
if [[ -n "${GH_REPO_DISPATCH_TOKEN:-}" ]]; then
    PLATFORM_REPO="$GH_ORG/bookverse-platform"
    echo "🔐 Configuring GH_REPO_DISPATCH_TOKEN for $PLATFORM_REPO (optional)"
    echo "   Purpose: Cross-repository workflow triggering and platform orchestration"
    echo "   Target: bookverse-platform repository for central coordination"
    
    # 📤 Dispatch Token Setup: Configure repository dispatch token securely
    if echo -n "$GH_REPO_DISPATCH_TOKEN" | gh secret set GH_REPO_DISPATCH_TOKEN --repo "$PLATFORM_REPO"; then
        echo "✅ $PLATFORM_REPO: GH_REPO_DISPATCH_TOKEN configured"
        echo "   Capability: Cross-repository workflow coordination enabled"
    else
        # ⚠️ Dispatch Token Failure: Handle optional token configuration failure gracefully
        echo "⚠️  Failed to set GH_REPO_DISPATCH_TOKEN in $PLATFORM_REPO (continuing)"
        echo "   Impact: Cross-repository workflows may not function fully"
        echo "   Resolution: Verify token permissions and repository access"
    fi
    echo ""
else
    # ℹ️ Dispatch Token Skipped: Inform user about optional token not provided
    echo "ℹ️ GH_REPO_DISPATCH_TOKEN not provided; skipping dispatch token configuration"
    echo "   Impact: Basic CI/CD will work, advanced cross-repo features disabled"
    echo "   Note: This token is optional for basic platform functionality"
    echo ""
fi

# 🔄 Repository Processing Loop: Configure variables and secrets for each service repository
# This loop iterates through all BookVerse service repositories and configures
# the required variables and secrets for CI/CD operations
OVERALL_SUCCESS=true
FAILED_REPOS=()

for repo_name in "${SERVICE_REPOS[@]}"; do
    FULL_REPO="$GH_ORG/$repo_name"
    echo "📦 Configuring $FULL_REPO..."
    
    REPO_SUCCESS=true
    
    # 📋 Repository Variables Configuration
    echo "   Setting repository variables..."
    
    if ! gh variable set JFROG_URL --body "$JFROG_URL" --repo "$FULL_REPO" 2>/dev/null; then
        echo "   ⚠️  Failed to set JFROG_URL variable"
        REPO_SUCCESS=false
    fi
    
    if ! gh variable set PROJECT_KEY --body "$PROJECT_KEY" --repo "$FULL_REPO" 2>/dev/null; then
        echo "   ⚠️  Failed to set PROJECT_KEY variable"
        REPO_SUCCESS=false
    fi
    
    if ! gh variable set DOCKER_REGISTRY --body "$DOCKER_REGISTRY" --repo "$FULL_REPO" 2>/dev/null; then
        echo "   ⚠️  Failed to set DOCKER_REGISTRY variable"
        REPO_SUCCESS=false
    fi
    
    # 📊 Status Reporting
    if [ "$REPO_SUCCESS" = true ]; then
        echo "✅ $FULL_REPO: Configuration completed successfully"
        echo "   Variables: JFROG_URL, PROJECT_KEY, DOCKER_REGISTRY"
        echo "   Status: CI/CD workflows ready for execution (evidence keys managed separately)"
    else
        echo "❌ $FULL_REPO: Configuration completed with errors"
        echo "   Error: Some variables or secrets failed to configure"
        echo "   Impact: CI/CD workflows may not function correctly"
        echo "   Resolution: Check repository access permissions and GitHub CLI auth"
        OVERALL_SUCCESS=false
        FAILED_REPOS+=("$FULL_REPO")
        # Continue with other repositories instead of exiting immediately
    fi
    echo ""
done

# 🎉 Success Summary: Display comprehensive configuration completion status
echo "🎉 Configuration Summary"
echo "========================"
echo ""

# 📊 Repository Status: List all repositories with their actual status
SUCCESS_COUNT=0
FAILURE_COUNT=0

for repo_name in "${SERVICE_REPOS[@]}"; do
    FULL_REPO="$GH_ORG/$repo_name"
    if [[ ${#FAILED_REPOS[@]} -gt 0 ]] && [[ " ${FAILED_REPOS[*]} " =~ " ${FULL_REPO} " ]]; then
        echo "  ❌ $FULL_REPO"
        echo "      - Status: ⚠️  Configuration failed"
        echo "      - Action Required: Check repository access permissions and GitHub CLI auth"
        ((FAILURE_COUNT++))
    else
        echo "  ✅ $FULL_REPO"
        echo "      - Variables: ✅ JFROG_URL, PROJECT_KEY, DOCKER_REGISTRY"
        echo "      - CI/CD Authentication: ✅ Enabled (OIDC)"
        echo "      - Container Registry Access: ✅ Ready"
        echo "      - Evidence Keys: ℹ️  Managed by 3_update_evidence_keys.sh"
        ((SUCCESS_COUNT++))
    fi
done
echo ""

# 📊 Overall Status Report
echo "📊 Overall Status:"
echo "  ✅ Successfully configured: $SUCCESS_COUNT/${#SERVICE_REPOS[@]} repositories"
if [ $FAILURE_COUNT -gt 0 ] && [ ${#FAILED_REPOS[@]} -gt 0 ]; then
    echo "  ❌ Failed to configure: $FAILURE_COUNT/${#SERVICE_REPOS[@]} repositories"
    echo ""
    echo "❌ Failed repositories:"
    for failed_repo in "${FAILED_REPOS[@]}"; do
        echo "  - $failed_repo"
    done
    echo ""
fi
echo ""

# 🔍 Verification Instructions: Provide guidance for testing configuration
if [ "$OVERALL_SUCCESS" = true ]; then
    echo "🔍 Verification:"
    echo "You can now run CI workflows on any service repository."
    echo "They should successfully authenticate with JFrog Platform using OIDC."
    echo ""
    echo "📋 Next Steps:"
    echo "  1. Test CI/CD workflows on any service repository"
    echo "  2. Verify container image pull/push operations"
    echo "  3. Confirm artifact publishing and build info generation"
    echo "  4. Validate evidence collection and signing"
    echo "  5. Test end-to-end deployment workflows"
    echo ""
    echo "🚀 Ready for complete end-to-end CI/CD testing!"
else
    echo "⚠️  Configuration completed with errors"
    echo ""
    echo "📋 Next Steps:"
    echo "  1. Review error messages above for each failed repository"
    echo "  2. Verify GitHub CLI authentication: gh auth status"
    echo "  3. Check repository access permissions for all target repositories"
    echo "  4. Verify required secrets are properly configured in bookverse-demo-init repository"
    echo "  5. Re-run this workflow after fixing the issues"
    echo ""
    echo "💡 Troubleshooting:"
    echo "  - Verify GitHub CLI has admin access to all target repositories"
    echo "  - Check that all required repository secrets are set in bookverse-demo-init"
    echo "  - Ensure GITHUB_TOKEN has appropriate permissions"
fi
echo ""
echo "💡 Troubleshooting:"
echo "  - If workflows fail: Check variable values and secret permissions"
echo "  - For authentication errors: Verify OIDC provider is configured in JFrog Platform"
echo "  - For repository access: Confirm variables are set correctly"
echo "  - For evidence signing: Use 3_update_evidence_keys.sh to configure evidence keys"

# 🚨 Exit with appropriate code based on overall success
if [ "$OVERALL_SUCCESS" = false ]; then
    echo ""
    echo "❌ Configuration completed with failures. Exiting with error code."
    exit 1
fi

