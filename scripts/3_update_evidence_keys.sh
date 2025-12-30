#!/usr/bin/env bash
# =============================================================================
# BookVerse Platform - Evidence Key Management Script
# =============================================================================
#
# Comprehensive evidence key generation and distribution for cryptographic signing
#
# 📋 USAGE EXAMPLES - COMPREHENSIVE EXECUTION PATTERNS:
#     This script provides multiple execution patterns for evidence key management
#     across the BookVerse platform, supporting both CI/CD automation and manual
#     operations with comprehensive key lifecycle management capabilities.
#
# 🔧 Basic Usage Patterns:
#     [Quick Key Generation]
#     # Generate new RSA keys and update all repositories
#     ./update_evidence_keys.sh --generate
#     
#     [Advanced Key Generation]
#     # Generate ED25519 keys with custom alias
#     ./update_evidence_keys.sh --generate --key-type ed25519 --alias "prod-evidence-2024"
#     
#     [Existing Key Deployment]
#     # Use existing key files to update repositories
#     ./update_evidence_keys.sh --private-key ./keys/private.pem --public-key ./keys/public.pem
#     
#     [Dry Run Validation]
#     # Test configuration without making changes
#     ./update_evidence_keys.sh --generate --dry-run
#
# 🚀 CI/CD Integration Patterns:
#     [GitHub Actions Workflow Integration]
#     name: Update Evidence Keys
#     on:
#       workflow_dispatch:
#         inputs:
#           key_type:
#             description: 'Key algorithm (rsa, ec, ed25519)'
#             required: true
#             default: 'rsa'
#           alias:
#             description: 'Key alias'
#             required: true
#             default: 'bookverse-signing-key'
#     jobs:
#       update-keys:
#         runs-on: ubuntu-latest
#         steps:
#           - uses: actions/checkout@v4
#           - name: Generate and distribute evidence keys
#             env:
#               JFROG_URL: ${{ secrets.JFROG_URL }}
#               JFROG_ADMIN_TOKEN: ${{ secrets.JFROG_ADMIN_TOKEN }}
#               GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
#             run: |
#               ./scripts/update_evidence_keys.sh \
#                 --generate \
#                 --key-type ${{ github.event.inputs.key_type }} \
#                 --alias ${{ github.event.inputs.alias }}
#     
#     [Jenkins Pipeline Integration]
#     pipeline {
#         agent any
#         parameters {
#             choice(name: 'KEY_TYPE', choices: ['rsa', 'ec', 'ed25519'], description: 'Key Algorithm')
#             string(name: 'KEY_ALIAS', defaultValue: 'bookverse-signing-key', description: 'Key Alias')
#             booleanParam(name: 'DRY_RUN', defaultValue: false, description: 'Dry Run Mode')
#         }
#         environment {
#             JFROG_URL = credentials('jfrog-url')
#             JFROG_ADMIN_TOKEN = credentials('jfrog-admin-token')
#         }
#         stages {
#             stage('Update Evidence Keys') {
#                 steps {
#                     sh """
#                         ./scripts/update_evidence_keys.sh \
#                             --generate \
#                             --key-type ${params.KEY_TYPE} \
#                             --alias ${params.KEY_ALIAS} \
#                             ${params.DRY_RUN ? '--dry-run' : ''}
#                     """
#                 }
#             }
#         }
#     }
#     
#     [Azure DevOps Pipeline Integration]
#     trigger: none
#     pr: none
#     parameters:
#       - name: keyType
#         displayName: 'Key Algorithm'
#         type: string
#         default: 'rsa'
#         values:
#           - rsa
#           - ec
#           - ed25519
#       - name: keyAlias
#         displayName: 'Key Alias'
#         type: string
#         default: 'bookverse-signing-key'
#       - name: dryRun
#         displayName: 'Dry Run Mode'
#         type: boolean
#         default: false
#     jobs:
#       - job: UpdateEvidenceKeys
#         displayName: 'Update Evidence Keys'
#         pool:
#           vmImage: 'ubuntu-latest'
#         steps:
#           - checkout: self
#           - bash: |
#               ./scripts/update_evidence_keys.sh \
#                 --generate \
#                 --key-type ${{ parameters.keyType }} \
#                 --alias ${{ parameters.keyAlias }} \
#                 ${{ eq(parameters.dryRun, true) && '--dry-run' || '' }}
#             displayName: 'Generate and Distribute Evidence Keys'
#             env:
#               JFROG_URL: $(JFROG_URL)
#               JFROG_ADMIN_TOKEN: $(JFROG_ADMIN_TOKEN)
#
# 🛠️ Manual Operation Procedures:
#     [Production Key Rotation]
#     # Step 1: Generate new production keys
#     ./update_evidence_keys.sh --generate --key-type ed25519 --alias "prod-evidence-$(date +%Y%m%d)"
#     
#     # Step 2: Verify deployment with dry run
#     ./update_evidence_keys.sh --generate --key-type ed25519 --alias "prod-evidence-$(date +%Y%m%d)" --dry-run
#     
#     # Step 3: Test signing with new keys
#     echo "test content" | openssl dgst -sha256 -sign ./generated-private.pem | base64
#     
#     [Emergency Key Replacement]
#     # Immediate key replacement for security incident
#     export EMERGENCY_ALIAS="emergency-evidence-$(date +%Y%m%d-%H%M%S)"
#     ./update_evidence_keys.sh --generate --key-type ed25519 --alias "$EMERGENCY_ALIAS"
#     
#     [Development Environment Setup]
#     # Setup development evidence keys
#     ./update_evidence_keys.sh --generate --key-type rsa --alias "dev-evidence-key" --org "your-dev-org"
#     
#     [Staging Environment Sync]
#     # Sync staging with production keys
#     ./update_evidence_keys.sh \
#       --private-key /secure/prod-private.pem \
#       --public-key /secure/prod-public.pem \
#       --alias "staging-sync-$(date +%Y%m%d)" \
#       --org "staging-org"
#
# 🌍 Multi-Environment Execution:
#     [Development Environment]
#     export JFROG_URL="https://dev.jfrog.io"
#     export JFROG_ADMIN_TOKEN="dev-token"
#     ./update_evidence_keys.sh --generate --key-type rsa --alias "dev-evidence-key"
#     
#     [Staging Environment]
#     export JFROG_URL="https://staging.jfrog.io"
#     export JFROG_ADMIN_TOKEN="staging-token"
#     ./update_evidence_keys.sh --generate --key-type ec --alias "staging-evidence-key"
#     
#     [Production Environment]
#     export JFROG_URL="https://prod.jfrog.io"
#     export JFROG_ADMIN_TOKEN="prod-token"
#     ./update_evidence_keys.sh --generate --key-type ed25519 --alias "prod-evidence-key"
#
# 🔍 Testing and Validation Patterns:
#     [Key Validation Testing]
#     # Test key generation without deployment
#     ./update_evidence_keys.sh --generate --dry-run --key-type ed25519
#     
#     # Validate existing keys
#     ./update_evidence_keys.sh \
#       --private-key ./test-private.pem \
#       --public-key ./test-public.pem \
#       --dry-run
#     
#     [Repository Access Testing]
#     # Test GitHub CLI authentication
#     gh auth status
#     gh repo view yonatanp-jfrog/bookverse-inventory
#     
#     [JFrog Integration Testing]
#     # Test JFrog API connectivity
#     curl -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" "$JFROG_URL/artifactory/api/system/ping"
#     
#     [End-to-End Validation]
#     # Complete validation workflow
#     ./update_evidence_keys.sh --generate --dry-run  # Validate configuration
#     ./update_evidence_keys.sh --generate             # Execute deployment
#     gh secret list --repo yonatanp-jfrog/bookverse-inventory | grep EVIDENCE  # Verify secrets
#
# 🛡️ Security Best Practices:
#     [Secure Key Handling]
#     # Use secure temporary directory
#     export TMPDIR="/secure/tmp"
#     mkdir -p "$TMPDIR" && chmod 700 "$TMPDIR"
#     ./update_evidence_keys.sh --generate
#     
#     [Token Management]
#     # Use environment files for tokens
#     echo "JFROG_ADMIN_TOKEN=your-token" > .env.secure
#     chmod 600 .env.secure
#     source .env.secure
#     ./update_evidence_keys.sh --generate
#     
#     [Audit Trail]
#     # Log all operations for audit
#     ./update_evidence_keys.sh --generate 2>&1 | tee evidence-key-update-$(date +%Y%m%d-%H%M%S).log
#
# 🚨 Emergency Procedures:
#     [Compromised Key Response]
#     # Immediate key rotation
#     EMERGENCY_ALIAS="emergency-$(date +%Y%m%d-%H%M%S)"
#     ./update_evidence_keys.sh --generate --key-type ed25519 --alias "$EMERGENCY_ALIAS"
#     
#     # Verify old key removal from JFrog
#     curl -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
#       "$JFROG_URL/artifactory/api/security/keys/trusted" | jq '.keys[].alias'
#     
#     [Rollback Procedures]
#     # Restore previous working keys
#     ./update_evidence_keys.sh \
#       --private-key ./backup/previous-private.pem \
#       --public-key ./backup/previous-public.pem \
#       --alias "rollback-$(date +%Y%m%d)"
#
# 🔧 Advanced Configuration:
#     [Custom Repository List]
#     # Override default repository list
#     export BOOKVERSE_REPOS="custom-repo1 custom-repo2"
#     ./update_evidence_keys.sh --generate
#     
#     [Batch Processing]
#     # Process multiple key types
#     for key_type in rsa ec ed25519; do
#         ./update_evidence_keys.sh \
#           --generate \
#           --key-type "$key_type" \
#           --alias "multi-${key_type}-$(date +%Y%m%d)" \
#           --dry-run
#     done
#     
#     [Parallel Execution]
#     # Update multiple organizations simultaneously
#     ./update_evidence_keys.sh --generate --org "org1" --alias "org1-evidence" &
#     ./update_evidence_keys.sh --generate --org "org2" --alias "org2-evidence" &
#     wait
#
# Authors: BookVerse Platform Team
# Version: 1.0.0
# Last Updated: 2024-01-01
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

PRIVATE_KEY_FILE=""
PUBLIC_KEY_FILE=""
KEY_ALIAS="${EVIDENCE_KEY_ALIAS:-bookverse-signing-key}"  # Default from environment, fallback to default
GITHUB_ORG=""
DRY_RUN=false
GENERATE_KEYS=false
KEY_TYPE="rsa"
TEMP_DIR=""
UPDATE_JFROG=true
JFROG_URL="${JFROG_URL:-}"
JFROG_ADMIN_TOKEN="${JFROG_ADMIN_TOKEN:-}"

BOOKVERSE_REPOS=(
    "bookverse-inventory"
    "bookverse-recommendations" 
    "bookverse-checkout"
    "bookverse-platform"
    "bookverse-web"
    "bookverse-helm"
    "repos/bookverse-demo-assets"
    "bookverse-demo-init"
)


show_usage() {
    cat << 'EOF'
Evidence Key Management Script

Generate evidence keys and/or update them across all BookVerse repositories
using your local GitHub CLI authentication.

USAGE:
    ./update_evidence_keys.sh --generate --org <org> [--key-type <type>] [options]
    
    ./update_evidence_keys.sh --private-key <file> --public-key <file> --org <org> [options]

REQUIRED ARGUMENTS:
    --org <name>            GitHub organization (required)

KEY GENERATION:
    --generate              Generate new key pair
    --key-type <type>       Key algorithm: rsa, ec, or ed25519 (default: rsa)

EXISTING KEYS:
    --private-key <file>    Path to private key PEM file
    --public-key <file>     Path to public key PEM file

OPTIONAL ARGUMENTS:
    --alias <name>          Key alias (default: from EVIDENCE_KEY_ALIAS env var, or bookverse-signing-key)
    --no-jfrog              Skip JFrog Platform update
    --dry-run               Show what would be done without making changes
    --help                  Show this help message

EXAMPLES:
    ./update_evidence_keys.sh --generate --org "your-org"
    
    ./update_evidence_keys.sh --generate --org "your-org" --key-type ed25519
    
    ./update_evidence_keys.sh --private-key private.pem --public-key public.pem --org "your-org"
    
    ./update_evidence_keys.sh --generate --org "your-org" --alias "my_evidence_key_2024"
    
    ./update_evidence_keys.sh --generate --org "your-org" --dry-run

KEY GENERATION:
    Keys are generated using JFrog CLI's 'jf evd generate-key-pair' command,
    which creates keys optimized for JFrog evidence workflows. The key type
    parameter is passed to JFrog CLI, which handles the appropriate algorithm
    selection and formatting.
    
    Supported key types: rsa, ec, ed25519 (default: rsa)

ENVIRONMENT VARIABLES:
    EVIDENCE_KEY_ALIAS       Key alias (default if --alias not provided)
                            Set in environment.sh or export before running script
    JFROG_URL               JFrog Platform URL (required for JFrog updates)
    JFROG_ADMIN_TOKEN       JFrog Platform admin token (required for JFrog updates)

PREREQUISITES:
    1. Install GitHub CLI: https://cli.github.com/
    2. Authenticate: gh auth login
    3. Install JFrog CLI for key generation: https://jfrog.com/getcli/
       (JFrog CLI v2.45.0+ with evidence support required)
    4. For existing key validation: OpenSSL (optional, only needed when using --private-key/--public-key)
    5. Ensure access to BookVerse repositories
    6. Source environment.sh or set EVIDENCE_KEY_ALIAS environment variable (recommended)

EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --generate)
                GENERATE_KEYS=true
                shift
                ;;
            --key-type)
                KEY_TYPE="$2"
                shift 2
                ;;
            --private-key)
                PRIVATE_KEY_FILE="$2"
                shift 2
                ;;
            --public-key)
                PUBLIC_KEY_FILE="$2"
                shift 2
                ;;
            --alias)
                KEY_ALIAS="$2"
                shift 2
                ;;
            --org)
                GITHUB_ORG="$2"
                shift 2
                ;;
            --no-jfrog)
                UPDATE_JFROG=false
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown argument: $1"
                echo ""
                show_usage
                exit 1
                ;;
        esac
    done

    if [[ "$GENERATE_KEYS" == true ]]; then
        if [[ -n "$PRIVATE_KEY_FILE" ]] || [[ -n "$PUBLIC_KEY_FILE" ]]; then
            log_error "Cannot specify --private-key or --public-key when using --generate"
            exit 1
        fi
        
        case "$KEY_TYPE" in
            rsa|ec|ed25519)
                ;;
            *)
                log_error "Invalid key type: $KEY_TYPE. Use: rsa, ec, or ed25519"
                exit 1
                ;;
        esac
    else
        if [[ -z "$PRIVATE_KEY_FILE" ]]; then
            log_error "Private key file is required. Use --private-key <file> or --generate"
            exit 1
        fi

        if [[ -z "$PUBLIC_KEY_FILE" ]]; then
            log_error "Public key file is required. Use --public-key <file> or --generate"
            exit 1
        fi
    fi
    
    # Validate required --org parameter
    if [[ -z "$GITHUB_ORG" ]]; then
        log_error "GitHub organization is required. Use --org <name>"
        echo ""
        show_usage
        exit 1
    fi
}

validate_environment() {
    log_info "Validating environment..."

    if [[ "$GENERATE_KEYS" == true ]]; then
        # When generating keys, JFrog CLI is required
        if ! command -v jf &> /dev/null; then
            log_error "JFrog CLI (jf) is required for key generation but not installed"
            log_info "Install from: https://jfrog.com/getcli/"
            log_info "Or use --private-key and --public-key to use existing keys"
            exit 1
        fi
        
        # Verify JFrog CLI can run evidence commands
        if ! jf evd --help &> /dev/null; then
            log_warning "JFrog CLI evidence commands may not be available"
            log_info "Ensure you have JFrog CLI v2.45.0 or later with evidence support"
        fi
    else
        # When using existing keys, OpenSSL is required for validation
        if ! command -v openssl &> /dev/null; then
            log_error "OpenSSL is required for key validation but not installed"
            exit 1
        fi
    fi

    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed"
        log_info "Install from: https://cli.github.com/"
        exit 1
    fi

    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated"
        log_info "Run: gh auth login"
        exit 1
    fi

    if [[ "$UPDATE_JFROG" == true ]]; then
        if [[ -z "$JFROG_URL" ]]; then
            log_error "JFROG_URL environment variable is required for JFrog Platform updates"
            exit 1
        fi

        if [[ -z "$JFROG_ADMIN_TOKEN" ]]; then
            log_error "JFROG_ADMIN_TOKEN environment variable is required for JFrog Platform updates"
            exit 1
        fi
    fi

    if [[ "$GENERATE_KEYS" == false ]]; then
        if [[ ! -f "$PRIVATE_KEY_FILE" ]]; then
            log_error "Private key file not found: $PRIVATE_KEY_FILE"
            exit 1
        fi

        if [[ ! -f "$PUBLIC_KEY_FILE" ]]; then
            log_error "Public key file not found: $PUBLIC_KEY_FILE"
            exit 1
        fi
    fi

    log_success "Environment validation successful"
}

generate_keys() {
    if [[ "$GENERATE_KEYS" == false ]]; then
        return 0
    fi
    
    log_info "Generating $KEY_TYPE key pair using JFrog CLI..."
    
    TEMP_DIR=$(mktemp -d)
    PRIVATE_KEY_FILE="$TEMP_DIR/private.pem"
    PUBLIC_KEY_FILE="$TEMP_DIR/public.pem"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "  [DRY RUN] Would generate $KEY_TYPE key pair using: jf evd generate-key-pair"
        log_info "  [DRY RUN] Command: jf evd generate-key-pair --alias \"$KEY_ALIAS\" --output-dir \"$TEMP_DIR\""
        log_info "  [DRY RUN] Alias: $KEY_ALIAS"
        log_info "  [DRY RUN] Output directory: $TEMP_DIR"
        # Set placeholder values for dry run
        KEY_ALGORITHM="$KEY_TYPE (dry run)"
        return 0
    fi
    
    # Use JFrog CLI to generate key pair
    # Note: JFrog CLI generates keys optimized for evidence workflows
    # Command syntax: jf evd generate-key-pair (all hyphenated)
    local jfrog_cmd_success=false
    local jfrog_output
    
    # Try: jf evd generate-key-pair (correct hyphenated syntax)
    log_info "Running: jf evd generate-key-pair --alias \"$KEY_ALIAS\" --output-dir \"$TEMP_DIR\""
    if jfrog_output=$(jf evd generate-key-pair --alias "$KEY_ALIAS" --output-dir "$TEMP_DIR" 2>&1); then
        jfrog_cmd_success=true
    # Try with key-type parameter if supported
    elif jfrog_output=$(jf evd generate-key-pair --alias "$KEY_ALIAS" --key-type "$KEY_TYPE" --output-dir "$TEMP_DIR" 2>&1); then
        jfrog_cmd_success=true
    else
        log_warning "JFrog CLI command failed"
        log_info "Command output: $jfrog_output"
    fi
    
    if [[ "$jfrog_cmd_success" == true ]]; then
        # JFrog CLI generates keys with specific naming conventions
        # Check for common output file patterns
        if [[ -f "$TEMP_DIR/${KEY_ALIAS}.key" ]] && [[ -f "$TEMP_DIR/${KEY_ALIAS}.pub" ]]; then
            # JFrog CLI format: alias.key and alias.pub
            PRIVATE_KEY_FILE="$TEMP_DIR/${KEY_ALIAS}.key"
            PUBLIC_KEY_FILE="$TEMP_DIR/${KEY_ALIAS}.pub"
            KEY_ALGORITHM="$KEY_TYPE (JFrog CLI generated)"
        elif [[ -f "$TEMP_DIR/private.pem" ]] && [[ -f "$TEMP_DIR/public.pem" ]]; then
            # Standard PEM format
            PRIVATE_KEY_FILE="$TEMP_DIR/private.pem"
            PUBLIC_KEY_FILE="$TEMP_DIR/public.pem"
            KEY_ALGORITHM="$KEY_TYPE (JFrog CLI generated)"
        elif [[ -f "$TEMP_DIR/private.key" ]] && [[ -f "$TEMP_DIR/public.key" ]]; then
            # Alternative naming
            PRIVATE_KEY_FILE="$TEMP_DIR/private.key"
            PUBLIC_KEY_FILE="$TEMP_DIR/public.key"
            KEY_ALGORITHM="$KEY_TYPE (JFrog CLI generated)"
        else
            # Try to find any key files in the output directory
            local found_private
            local found_public
            found_private=$(find "$TEMP_DIR" -type f \( -name "*private*" -o -name "*.key" \) | head -1)
            found_public=$(find "$TEMP_DIR" -type f \( -name "*public*" -o -name "*.pub" \) | head -1)
            
            if [[ -n "$found_private" ]] && [[ -n "$found_public" ]]; then
                PRIVATE_KEY_FILE="$found_private"
                PUBLIC_KEY_FILE="$found_public"
                KEY_ALGORITHM="$KEY_TYPE (JFrog CLI generated)"
                log_info "Found keys: $PRIVATE_KEY_FILE and $PUBLIC_KEY_FILE"
            else
                log_error "JFrog CLI generated keys but could not locate output files"
                log_info "Contents of $TEMP_DIR:"
                ls -la "$TEMP_DIR" || true
                exit 1
            fi
        fi
        
        # Ensure files are readable
        if [[ ! -r "$PRIVATE_KEY_FILE" ]] || [[ ! -r "$PUBLIC_KEY_FILE" ]]; then
            log_error "Generated key files are not readable"
            exit 1
        fi
        
        log_success "Generated $KEY_ALGORITHM key pair using JFrog CLI"
        log_info "Private key: $PRIVATE_KEY_FILE"
        log_info "Public key: $PUBLIC_KEY_FILE"
    else
        log_error "Failed to generate key pair using JFrog CLI"
        log_error "Command output: $jfrog_output"
        echo ""
        log_info "Troubleshooting:"
        log_info "1. Ensure JFrog CLI is installed: https://jfrog.com/getcli/"
        log_info "2. Verify JFrog CLI version supports evidence commands (v2.45.0+): jf --version"
        log_info "3. Check evidence command availability: jf evd --help"
        log_info "4. Alternative: Use --private-key and --public-key to provide existing keys"
        echo ""
        log_info "If you have existing keys generated with OpenSSL or other tools,"
        log_info "you can use them with: --private-key <file> --public-key <file>"
        exit 1
    fi
}

validate_keys() {
    log_info "Validating key files..."

    if ! openssl pkey -in "$PRIVATE_KEY_FILE" -check -noout 2>/dev/null; then
        log_error "Invalid private key format: $PRIVATE_KEY_FILE"
        exit 1
    fi

    if ! openssl pkey -in "$PUBLIC_KEY_FILE" -pubin -check -noout 2>/dev/null; then
        log_error "Invalid public key format: $PUBLIC_KEY_FILE"
        exit 1
    fi

    local private_pubkey
    private_pubkey=$(openssl pkey -in "$PRIVATE_KEY_FILE" -pubout 2>/dev/null)
    local public_key_content
    public_key_content=$(cat "$PUBLIC_KEY_FILE")

    if [[ "$private_pubkey" != "$public_key_content" ]]; then
        log_error "Private and public keys do not match"
        exit 1
    fi

    local key_type
    key_type=$(openssl pkey -in "$PRIVATE_KEY_FILE" -text -noout 2>/dev/null | head -1)
    
    log_success "Key validation successful"
    log_info "Key type: $key_type"
    log_info "Key alias: $KEY_ALIAS"
}

get_existing_repositories() {
    log_info "Discovering existing BookVerse repositories..." >&2

    local existing_repos=()
    for repo in "${BOOKVERSE_REPOS[@]}"; do
        local full_repo="$GITHUB_ORG/$repo"
        if gh repo view "$full_repo" > /dev/null 2>&1; then
            existing_repos+=("$full_repo")
        else
            log_warning "Repository $full_repo not found - skipping" >&2
        fi
    done

    if [[ ${#existing_repos[@]} -eq 0 ]]; then
        log_error "No BookVerse repositories found" >&2
        exit 1
    fi

    log_info "Found ${#existing_repos[@]} repositories" >&2
    printf '%s\n' "${existing_repos[@]}"
}

update_repository_secrets_and_variables() {
    local repo="$1"
    local private_key_content="$2"
    local public_key_content="$3"
    
    log_info "Updating evidence keys in $repo..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "  [DRY RUN] Would update EVIDENCE_PRIVATE_KEY secret"
        log_info "  [DRY RUN] Would set EVIDENCE_PUBLIC_KEY variable"
        log_info "  [DRY RUN] Would update EVIDENCE_KEY_ALIAS variable"
        return 0
    fi
    
    local success=true
    
    log_info "  → Updating EVIDENCE_PRIVATE_KEY secret..."
    if printf "%s" "$private_key_content" | gh secret set EVIDENCE_PRIVATE_KEY --repo "$repo"; then
        log_success "    ✅ EVIDENCE_PRIVATE_KEY secret updated"
    else
        log_error "    ❌ Failed to update EVIDENCE_PRIVATE_KEY secret"
        success=false
    fi
    
    log_info "  → Setting EVIDENCE_PUBLIC_KEY variable..."
    if gh variable set EVIDENCE_PUBLIC_KEY --body "$public_key_content" --repo "$repo"; then
        log_success "    ✅ EVIDENCE_PUBLIC_KEY variable updated"
    else
        log_error "    ❌ Failed to update EVIDENCE_PUBLIC_KEY variable"
        success=false
    fi
    
    log_info "  → Updating EVIDENCE_KEY_ALIAS variable..."
    if gh variable set EVIDENCE_KEY_ALIAS --body "$KEY_ALIAS" --repo "$repo"; then
        log_success "    ✅ EVIDENCE_KEY_ALIAS variable updated"
    else
        log_error "    ❌ Failed to update EVIDENCE_KEY_ALIAS variable"
        success=false
    fi
    
    if [[ "$success" == true ]]; then
        log_success "✅ $repo updated successfully"
    else
        log_warning "⚠️  $repo partially updated (some operations failed)"
    fi
    
    return 0
}

update_all_repositories() {
    log_info "Updating evidence keys across all repositories..."
    echo ""
    
    if [[ -z "$TEMP_DIR" ]] || [[ ! -d "$TEMP_DIR" ]]; then
        TEMP_DIR=$(mktemp -d)
    fi

    local repos_temp="$TEMP_DIR/repos_list.txt"
    get_existing_repositories > "$repos_temp"
    
    local repo_count=$(wc -l < "$repos_temp" | tr -d ' ')
    
    echo ""
    log_info "Processing $repo_count repositories..."
    echo ""
    
    local private_key_content
    private_key_content=$(cat "$PRIVATE_KEY_FILE")
    local public_key_content
    public_key_content=$(cat "$PUBLIC_KEY_FILE")
    
    local success_count=0
    local total_count="$repo_count"
    
    while IFS= read -r repo || [[ -n "$repo" ]]; do
        [[ -z "$repo" ]] && continue
        if update_repository_secrets_and_variables "$repo" "$private_key_content" "$public_key_content"; then
            ((success_count++))
        fi
        echo ""
    done < "$repos_temp"
    
    log_info "Update Summary:"
    log_info "  Repositories processed: $total_count"
    log_info "  Successfully updated: $success_count"
    
    if [[ $success_count -eq $total_count ]]; then
        log_success "All repositories updated successfully!"
    else
        log_warning "Some repositories had issues (check logs above)"
    fi
}

delete_existing_trusted_key() {
    local alias_to_delete="$1"
    
    log_info "Checking for existing trusted key with alias: $alias_to_delete"
    
    local response_file="$TEMP_DIR/trusted_keys_response.json"
    local http_code
    http_code=$(curl -s -w "%{http_code}" \
        -X GET \
        -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
        "$JFROG_URL/artifactory/api/security/keys/trusted" \
        -o "$response_file")
    
    if [[ "$http_code" != "200" ]]; then
        log_warning "Failed to retrieve trusted keys list (HTTP $http_code)"
        return 1
    fi
    
    local kid
    kid=$(jq -r --arg alias "$alias_to_delete" '.keys[] | select(.alias == $alias) | .kid' "$response_file" 2>/dev/null)
    
    if [[ -n "$kid" ]] && [[ "$kid" != "null" ]]; then
        log_info "Found existing key with ID: $kid"
        log_info "Deleting existing trusted key..."
        
        local delete_response_file="$TEMP_DIR/delete_response.json"
        local delete_code
        delete_code=$(curl -s -w "%{http_code}" \
            -X DELETE \
            -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
            "$JFROG_URL/artifactory/api/security/keys/trusted/$kid" \
            -o "$delete_response_file")
        
        if [[ "$delete_code" == "200" ]] || [[ "$delete_code" == "204" ]]; then
            log_success "✅ Existing trusted key deleted successfully"
            return 0
        else
            log_error "❌ Failed to delete existing trusted key (HTTP $delete_code)"
            if [[ -f "$delete_response_file" ]]; then
                cat "$delete_response_file"
            fi
            return 1
        fi
    else
        log_info "No existing trusted key found with alias: $alias_to_delete"
        return 0
    fi
}

upload_public_key_to_jfrog() {
    if [[ "$UPDATE_JFROG" == false ]]; then
        return 0
    fi

    log_info "Uploading public key to JFrog Platform..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "  [DRY RUN] Would upload public key to $JFROG_URL"
        log_info "  [DRY RUN] Key alias: $KEY_ALIAS"
        return 0
    fi

    if [[ -z "$TEMP_DIR" ]]; then
        TEMP_DIR=$(mktemp -d)
    fi

    local public_key_content
    public_key_content=$(cat "$PUBLIC_KEY_FILE")
    
    local payload
    payload=$(jq -n \
        --arg alias "$KEY_ALIAS" \
        --arg public_key "$public_key_content" \
        '{
            "alias": $alias,
            "public_key": $public_key
        }')
    
    local response_file="$TEMP_DIR/jfrog_response.json"
    local http_code
    http_code=$(curl -s -w "%{http_code}" \
        -X POST \
        -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$JFROG_URL/artifactory/api/security/keys/trusted" \
        -o "$response_file")
    
    if [[ "$http_code" == "200" ]] || [[ "$http_code" == "201" ]]; then
        log_success "✅ Public key uploaded to JFrog Platform"
        
        log_info "🔍 Verifying upload was successful..."
        sleep 2
        local verify_response
        verify_response=$(curl -s \
            -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
            "$JFROG_URL/artifactory/api/security/keys/trusted")
        
        if echo "$verify_response" | jq -e --arg alias "$KEY_ALIAS" '.keys[] | select(.alias == $alias)' >/dev/null 2>&1; then
            local uploaded_kid
            uploaded_kid=$(echo "$verify_response" | jq -r --arg alias "$KEY_ALIAS" '.keys[] | select(.alias == $alias) | .kid')
            log_success "✅ Upload verified! Key found with alias '$KEY_ALIAS' (kid: $uploaded_kid)"
            return 0
        else
            log_error "❌ VERIFICATION FAILED: Key with alias '$KEY_ALIAS' not found in JFrog after upload"
            log_error "This indicates a silent upload failure. Check JFrog permissions and API endpoint."
            return 1
        fi
    elif [[ "$http_code" == "409" ]]; then
        log_warning "⚠️ Trusted key with alias '$KEY_ALIAS' already exists"
        
        if delete_existing_trusted_key "$KEY_ALIAS"; then
            log_info "Retrying upload after deleting existing key..."
            
            http_code=$(curl -s -w "%{http_code}" \
                -X POST \
                -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
                -H "Content-Type: application/json" \
                -d "$payload" \
                "$JFROG_URL/artifactory/api/security/keys/trusted" \
                -o "$response_file")
            
            if [[ "$http_code" == "200" ]] || [[ "$http_code" == "201" ]]; then
                log_success "✅ Public key uploaded to JFrog Platform (after replacing existing key)"
                
                log_info "🔍 Verifying upload was successful..."
                sleep 2
                local verify_response
                verify_response=$(curl -s \
                    -H "Authorization: Bearer $JFROG_ADMIN_TOKEN" \
                    "$JFROG_URL/artifactory/api/security/keys/trusted")
                
                if echo "$verify_response" | jq -e --arg alias "$KEY_ALIAS" '.keys[] | select(.alias == $alias)' >/dev/null 2>&1; then
                    local uploaded_kid
                    uploaded_kid=$(echo "$verify_response" | jq -r --arg alias "$KEY_ALIAS" '.keys[] | select(.alias == $alias) | .kid')
                    log_success "✅ Upload verified! Key found with alias '$KEY_ALIAS' (kid: $uploaded_kid)"
                    return 0
                else
                    log_error "❌ VERIFICATION FAILED: Key with alias '$KEY_ALIAS' not found in JFrog after upload"
                    log_error "This indicates a silent upload failure. Check JFrog permissions and API endpoint."
                    return 1
                fi
            else
                log_error "❌ Failed to upload public key after deletion (HTTP $http_code)"
                if [[ -f "$response_file" ]]; then
                    log_error "Response:"
                    cat "$response_file"
                fi
                return 1
            fi
        else
            log_error "❌ Failed to delete existing key, cannot upload new key"
            return 1
        fi
    else
        log_error "❌ Failed to upload public key to JFrog Platform (HTTP $http_code)"
        if [[ -f "$response_file" ]]; then
            log_error "Response:"
            cat "$response_file"
        fi
        return 1
    fi
}


cleanup() {
    if [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
        log_info "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

main() {
    trap cleanup EXIT
    
    log_info "🔐 Evidence Key Management Script"
    log_info "================================="
    echo ""
    
    parse_arguments "$@"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    if [[ "$GENERATE_KEYS" == true ]]; then
        log_info "Mode: Generate keys and update repositories"
        log_info "Key type: $KEY_TYPE"
    else
        log_info "Mode: Use existing keys"
        log_info "Private key: $PRIVATE_KEY_FILE"
        log_info "Public key: $PUBLIC_KEY_FILE"
    fi
    
    log_info "Key alias: $KEY_ALIAS"
    log_info "Organization: $GITHUB_ORG"
    echo ""
    
    validate_environment
    echo ""
    
    if [[ "$GENERATE_KEYS" == true ]]; then
        generate_keys
        echo ""
    fi
    
    validate_keys
    echo ""
    
    update_all_repositories
    echo ""
    
    if [[ "$UPDATE_JFROG" == true ]]; then
        upload_public_key_to_jfrog
        echo ""
    fi
    
    if [[ "$GENERATE_KEYS" == true ]] && [[ "$DRY_RUN" == false ]]; then
        echo ""
        log_success "🔑 Generated Keys:"
        log_success "=================="
        echo ""
        echo "📄 Private Key (save securely):"
        echo "--------------------------------"
        cat "$PRIVATE_KEY_FILE"
        echo ""
        echo "📄 Public Key:"
        echo "---------------"
        cat "$PUBLIC_KEY_FILE"
        echo ""
        log_warning "⚠️  IMPORTANT: Save the private key securely!"
        log_warning "    The temporary files will be deleted when this script exits."
        echo ""
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log_success "🎯 Dry run completed successfully!"
        log_info "Run without --dry-run to apply changes"
    else
        log_success "🎯 Evidence Key Management Complete!"
        log_success "===================================="
        echo ""
        log_success "✅ Updated in all BookVerse repositories:"
        log_success "  - EVIDENCE_PRIVATE_KEY (secret)"
        log_success "  - EVIDENCE_PUBLIC_KEY (variable)"
        log_success "  - EVIDENCE_KEY_ALIAS (variable)"
        echo ""
        log_info "🔑 Key alias: $KEY_ALIAS"
        echo ""
        log_success "All repositories are now using the evidence keys!"
        echo ""
        log_info "Next steps:"
        if [[ "$UPDATE_JFROG" == true ]]; then
            log_info "1. Test evidence signing with new keys"
            if [[ "$GENERATE_KEYS" == true ]]; then
                log_info "2. Save the private key shown above securely"
            else
                log_info "2. Archive old private key securely (if replacing)"
            fi
        else
            log_info "1. Upload public key to JFrog Platform manually"
            log_info "2. Test evidence signing with new keys"
            if [[ "$GENERATE_KEYS" == true ]]; then
                log_info "3. Save the private key shown above securely"
            else
                log_info "3. Archive old private key securely (if replacing)"
            fi
        fi
    fi
}

main "$@"
