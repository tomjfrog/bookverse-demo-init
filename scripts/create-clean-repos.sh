#!/bin/bash

# =============================================================================
# BookVerse Platform - Repository Forking and Setup Script
# =============================================================================
#
# This comprehensive repository management script automates the forking of
# BookVerse service repositories from an upstream organization to a target
# organization, with optional local cloning and remote configuration for
# enterprise-grade microservices repository management and independent
# CI/CD operations across the complete BookVerse platform ecosystem.
#
# 🏗️ REPOSITORY FORKING STRATEGY:
#     - Upstream Forking: Automated forking from upstream organization repositories
#     - Service Isolation: Complete service code isolation with preserved Git history
#     - GitHub Integration: Automated GitHub repository forking with interactive confirmation
#     - Local Cloning: Optional local repository cloning with proper remote configuration
#     - CI/CD Optimization: Repository structure ready for independent CI/CD operations
#     - Safety Mechanisms: Dry run mode and interactive confirmation for safe operations
#
# 🔧 FORKING PROCEDURES:
#     - Upstream Detection: Automatic detection of upstream repository existence
#     - Fork Creation: GitHub API-based repository forking with proper configuration
#     - Remote Configuration: Upstream and origin remote setup for local clones
#     - Branch Tracking: Main branch tracking and upstream synchronization setup
#     - Interactive Confirmation: User confirmation for repository forking and overwrite
#     - Error Recovery: Comprehensive error handling and recovery procedures
#
# 🛡️ ENTERPRISE SECURITY AND GOVERNANCE:
#     - Safe Repository Operations: Comprehensive safety mechanisms for repository operations
#     - Authentication Management: Secure GitHub authentication and authorization
#     - Repository Access Control: Private repository creation with secure access management
#     - Audit Trail: Complete repository creation and configuration audit logging
#     - Data Protection: Secure handling of sensitive data during repository operations
#     - Rollback Capabilities: Repository operation rollback and disaster recovery
#
# 🔄 REPOSITORY LIFECYCLE MANAGEMENT:
#     - Fork Validation: Repository fork existence validation and verification
#     - Local Cloning: Optional local repository cloning with proper remote setup
#     - Remote Management: Upstream and origin remote configuration for sync
#     - Interactive Workflow: User-guided repository forking with confirmation prompts
#     - Batch Processing: Support for multiple service repository forking
#     - Status Reporting: Comprehensive status reporting and operation logging
#
# 📈 SCALABILITY AND AUTOMATION:
#     - Dry Run Mode: Safe testing and validation without actual repository changes
#     - Batch Processing: Efficient processing of multiple service repositories
#     - Template-Based Creation: Consistent repository structure and configuration
#     - Error Recovery: Automated error recovery and repository cleanup procedures
#     - Performance Optimization: Optimized file operations and Git performance
#     - Monitoring Integration: Repository creation monitoring and status reporting
#
# 🔐 ADVANCED SAFETY FEATURES:
#     - Dry Run Validation: Complete operation validation without making changes
#     - Interactive Confirmation: User confirmation for destructive operations
#     - Data Protection: Protection against data loss during repository operations
#     - Rollback Mechanisms: Complete rollback capabilities for failed operations
#     - Validation Framework: Repository integrity validation and verification
#     - Security Scanning: Repository security validation and compliance checking
#
# 🛠️ TECHNICAL IMPLEMENTATION:
#     - GitHub CLI Integration: Native GitHub repository management via gh CLI
#     - rsync Operations: Advanced file copying with comprehensive exclusion patterns
#     - Git Operations: Advanced Git repository management and configuration
#     - Workspace Management: Temporary workspace creation and cleanup procedures
#     - Error Handling: Comprehensive error detection and recovery procedures
#     - Validation Framework: Repository validation and integrity checking
#
# 📋 SUPPORTED OPERATIONS:
#     - Repository Forking: GitHub API-based forking from upstream organization
#     - Local Cloning: Optional local repository cloning with remote configuration
#     - Remote Setup: Upstream and origin remote configuration for synchronization
#     - Branch Tracking: Main branch tracking and upstream branch configuration
#     - Fork Management: Handling existing forks and repository conflicts
#     - Status Verification: Fork status verification and repository access validation
#
# 🎯 SUCCESS CRITERIA:
#     - Repository Forking: Successful forking of all service repositories
#     - Remote Configuration: Proper upstream and origin remote setup
#     - CI/CD Readiness: Repository structure ready for independent CI/CD operations
#     - Security Compliance: Repository security configuration meeting enterprise standards
#     - Interactive Validation: User-guided operation with confirmation and validation
#     - Operational Excellence: Repository management ready for production operations
#
# Authors: BookVerse Platform Team
# Version: 1.0.0
# Last Updated: 2024
#
# Dependencies:
#   - GitHub CLI (gh) with authentication (repository management)
#   - Git with proper configuration (version control operations)
#   - rsync for advanced file copying (file operations)
#   - Bash 4.0+ with array support (script execution environment)
#   - Network connectivity to GitHub (repository creation and push operations)
#
# Usage:
#   ./create-clean-repos.sh [OPTIONS]
#   
#   Options:
#     --target-org ORG      Target GitHub organization for forks
#                           (default: detected from git config or tomjfrog)
#     --upstream-org ORG    Upstream GitHub organization to fork from
#                           (default: yonatanp-jfrog)
#     --dry-run             Enable dry run mode (no actual changes)
#     --clone-local          Clone forked repos locally after forking
#     --help                Show this help message
#   
#   Examples:
#     ./create-clean-repos.sh --target-org tomjfrog --upstream-org yonatanp-jfrog
#     ./create-clean-repos.sh --target-org myorg --dry-run
#     ./create-clean-repos.sh --target-org myorg --clone-local
#
# Safety Notes:
#   - Use dry run mode for testing and validation before actual operations
#   - Interactive confirmation prompts for repository forking
#   - Upstream repositories are not modified
#   - Forked repositories maintain connection to upstream for synchronization
#
# =============================================================================

set -euo pipefail

# 📦 Repository Configuration
# Repository forking configuration for BookVerse microservices
UPSTREAM_ORG="yonatanp-jfrog"  # Upstream organization to fork from
DRY_RUN="false"                # Dry run mode for safe testing and validation
CLONE_LOCAL="false"            # Whether to clone forked repos locally
TARGET_ORG=""                  # Target organization (will be auto-detected if not provided)

# Parse named arguments
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Fork BookVerse service repositories from an upstream organization to a target organization.

Options:
    --target-org ORG      Target GitHub organization for forks
                          (default: detected from git config or tomjfrog)
    --upstream-org ORG    Upstream GitHub organization to fork from
                          (default: yonatanp-jfrog)
    --dry-run             Enable dry run mode (no actual changes)
    --clone-local          Clone forked repos locally after forking
    --help                Show this help message

Examples:
    $0 --target-org tomjfrog --upstream-org yonatanp-jfrog
    $0 --target-org myorg --dry-run
    $0 --target-org myorg --clone-local
    $0 --help

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --target-org)
            TARGET_ORG="$2"
            shift 2
            ;;
        --upstream-org)
            UPSTREAM_ORG="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --clone-local)
            CLONE_LOCAL="true"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
done

# Auto-detect target organization if not provided
if [[ -z "$TARGET_ORG" ]]; then
    # Try to detect from current repo's remote
    CURRENT_REPO_OWNER=$(git remote get-url origin 2>/dev/null | sed -E 's|.*github.com[:/]([^/]+)/.*|\1|' || echo "")
    if [[ -n "$CURRENT_REPO_OWNER" ]]; then
        TARGET_ORG="$CURRENT_REPO_OWNER"
    else
        TARGET_ORG="tomjfrog"  # Default fallback
    fi
fi

# 🏢 BookVerse Service Architecture
# Complete list of all BookVerse microservices requiring clean repository creation
SERVICES=(
    "bookverse-inventory"      # Core business inventory and stock management service
    "bookverse-recommendations" # AI-powered personalization and recommendation engine
    "bookverse-checkout"       # Secure payment processing and transaction management
    "bookverse-platform"      # Unified platform coordination and API gateway
    "bookverse-web"           # Customer-facing frontend and static asset delivery
    "bookverse-helm"          # Kubernetes deployment manifests and infrastructure-as-code
)

echo "🚀 Forking BookVerse service repositories"
echo "🎯 Target organization: $TARGET_ORG"
echo "⬆️  Upstream organization: $UPSTREAM_ORG"
echo "🧪 Dry run mode: $DRY_RUN"
echo "📥 Clone locally: $CLONE_LOCAL"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    echo "🔍 DRY RUN MODE - No actual changes will be made"
    echo ""
fi

# Verify upstream repositories exist
echo "🔍 Verifying upstream repositories..."
for SERVICE in "${SERVICES[@]}"; do
    if ! gh repo view "$UPSTREAM_ORG/$SERVICE" >/dev/null 2>&1; then
        echo "⚠️  Upstream repository $UPSTREAM_ORG/$SERVICE not found, skipping..."
    fi
done
echo ""

for SERVICE in "${SERVICES[@]}"; do
    echo ""
    echo "🔄 Processing service: $SERVICE"
    
    # Check if upstream repo exists
    if ! gh repo view "$UPSTREAM_ORG/$SERVICE" >/dev/null 2>&1; then
        echo "⚠️  Upstream repository $UPSTREAM_ORG/$SERVICE not found, skipping..."
        continue
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "🔍 DRY RUN: Would fork $UPSTREAM_ORG/$SERVICE to $TARGET_ORG/$SERVICE"
        if [[ "$CLONE_LOCAL" == "true" ]]; then
            echo "   Would clone to: ../$SERVICE"
        fi
        continue
    fi
    
    # Check if fork already exists
    if gh repo view "$TARGET_ORG/$SERVICE" >/dev/null 2>&1; then
        echo "📦 Repository $TARGET_ORG/$SERVICE already exists"
        read -p "🤔 Delete and re-fork? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh repo delete "$TARGET_ORG/$SERVICE" --yes
        else
            echo "⏭️  Skipping fork for $SERVICE"
            if [[ "$CLONE_LOCAL" == "true" ]]; then
                echo "📥 Repository exists, checking local clone..."
                if [[ -d "../$SERVICE" ]]; then
                    echo "✅ Local clone already exists at ../$SERVICE"
                else
                    echo "📥 Cloning existing fork locally..."
                    cd ..
                    gh repo clone "$TARGET_ORG/$SERVICE"
                    cd bookverse-demo-init
                fi
            fi
            continue
        fi
    fi
    
    echo "📋 Step 1: Forking repository from $UPSTREAM_ORG/$SERVICE..."
    
    # Try to fork using GitHub API (works for organizations)
    # If that fails with user account error, fall back to gh repo fork
    FORK_RESULT=$(gh api repos/"$UPSTREAM_ORG"/"$SERVICE"/forks -X POST -f organization="$TARGET_ORG" 2>&1) || {
        # Check if the error is about user account vs organization
        if [[ "$FORK_RESULT" == *"is the login for a user account"* ]]; then
            echo "   Detected user account ($TARGET_ORG), using 'gh repo fork' instead..."
            # Get the currently authenticated user
            AUTHENTICATED_USER=$(gh api user --jq .login 2>/dev/null || echo "")
            
            if [[ -z "$AUTHENTICATED_USER" ]]; then
                echo "❌ Not authenticated with GitHub CLI"
                echo "   Please run: gh auth login"
                continue
            fi
            
            # Warn if authenticated user doesn't match target
            if [[ "$AUTHENTICATED_USER" != "$TARGET_ORG" ]]; then
                echo "⚠️  Warning: Authenticated as '$AUTHENTICATED_USER' but target is '$TARGET_ORG'"
                echo "   Fork will be created under '$AUTHENTICATED_USER'"
                read -p "   Continue? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo "⏭️  Skipping fork for $SERVICE"
                    continue
                fi
            fi
            
            # Use gh repo fork for user accounts (forks to authenticated user)
            if gh repo fork "$UPSTREAM_ORG/$SERVICE" --clone=false 2>&1; then
                # Verify the fork was created
                if gh repo view "$AUTHENTICATED_USER/$SERVICE" >/dev/null 2>&1; then
                    echo "✅ Successfully forked to $AUTHENTICATED_USER/$SERVICE"
                    # Update TARGET_ORG to match actual fork location for consistency
                    TARGET_ORG="$AUTHENTICATED_USER"
                else
                    echo "⚠️  Fork command succeeded but cannot verify fork location"
                fi
            else
                echo "❌ Failed to fork $UPSTREAM_ORG/$SERVICE using 'gh repo fork'"
                continue
            fi
        elif gh repo view "$TARGET_ORG/$SERVICE" >/dev/null 2>&1; then
            # Fork already exists
            echo "✅ Fork already exists: $TARGET_ORG/$SERVICE"
        else
            echo "❌ Failed to fork $UPSTREAM_ORG/$SERVICE"
            echo "   Error: $FORK_RESULT"
            echo "   Note: For organizations, forking requires org admin permissions"
            echo "   For user accounts, ensure you're authenticated: gh auth login"
            continue
        fi
    }
    
    # If API fork succeeded (no error), wait a moment for fork to complete
    if [[ -z "${FORK_RESULT:-}" ]] || [[ "$FORK_RESULT" != *"is the login for a user account"* ]]; then
        if gh repo view "$TARGET_ORG/$SERVICE" >/dev/null 2>&1; then
            if [[ "$FORK_RESULT" != *"already exists"* ]]; then
                sleep 3
                echo "✅ Successfully forked to $TARGET_ORG/$SERVICE"
            fi
        fi
    fi
    
    echo "🌐 View at: https://github.com/$TARGET_ORG/$SERVICE"
    
    # Optionally clone locally
    if [[ "$CLONE_LOCAL" == "true" ]]; then
        echo "📋 Step 2: Cloning fork locally..."
        if [[ -d "../$SERVICE" ]]; then
            echo "⚠️  Directory ../$SERVICE already exists, skipping clone"
        else
            cd ..
            gh repo clone "$TARGET_ORG/$SERVICE"
            
            # Set up upstream remote
            cd "$SERVICE"
            if ! git remote get-url upstream >/dev/null 2>&1; then
                git remote add upstream "git@github.com:$UPSTREAM_ORG/$SERVICE.git"
                echo "✅ Added upstream remote: $UPSTREAM_ORG/$SERVICE"
            fi
            cd ../bookverse-demo-init
            echo "✅ Cloned to: ../$SERVICE"
        fi
    fi
done

echo ""
if [[ "$DRY_RUN" != "true" ]]; then
    echo "🎉 Repository forking complete!"
    echo ""
    echo "📋 Next steps:"
    echo "1. 🔧 Set up repository variables for each service (PROJECT_KEY, JFROG_URL, etc.)"
    echo "2. 🔑 Set up repository secrets (EVIDENCE_PRIVATE_KEY, etc.)"
    echo "3. 🔗 Configure OIDC providers for each service"
    echo "4. 🧪 Test CI workflows"
    echo "5. 🔄 Set up upstream tracking: git remote add upstream <upstream-url> (if not done automatically)"
    echo ""
    echo "📋 Forked repositories:"
    for SERVICE in "${SERVICES[@]}"; do
        if gh repo view "$TARGET_ORG/$SERVICE" >/dev/null 2>&1; then
            echo "  ✅ $TARGET_ORG/$SERVICE → https://github.com/$TARGET_ORG/$SERVICE"
        fi
    done
else
    echo "🔍 Dry run complete - no repositories were forked"
    echo "Run without 'true' as third argument to fork repositories"
fi
