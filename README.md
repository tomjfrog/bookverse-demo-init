# BookVerse Platform

## Enterprise Microservices Platform with Secure Software Supply Chain Management

![BookVerse Homepage](images/bookverse-homepage.png)
*BookVerse web application showcasing the complete microservices platform with product catalog, recommendations, and checkout functionality*

BookVerse is a comprehensive microservices platform that delivers modern software development practices, secure CI/CD pipelines, and enterprise-grade deployment automation. Built with industry-leading technologies, BookVerse provides organizations with a complete reference architecture for scalable, secure, and compliant software delivery.

---


## 🛡️ Enterprise Governance & Policy Framework

BookVerse implements **comprehensive unified policies** that demonstrate enterprise-grade governance, security, and compliance capabilities:

### **🎯 14 Automated Policy Gates**
- **DEV Stage**: Quality gates, security scanning, and traceability requirements
- **QA Stage**: Dynamic security testing and comprehensive API validation  
- **STAGING Stage**: Penetration testing, change management, and infrastructure scanning
- **PROD Release**: Multi-stage completion verification and approval workflows

### **🔒 Security by Design**
- **SLSA Provenance**: Supply chain security with cryptographic verification
- **Multi-Layer Security**: SAST, DAST, penetration testing, and IaC scanning
- **Evidence Collection**: Automated evidence gathering with cryptographic signing
- **Audit Compliance**: Complete audit trails for regulatory and enterprise requirements

### **⚡ Automated Enforcement**
- **CI/CD Integration**: Policies automatically enforced during promotion workflows
- **Real-time Evaluation**: Policy compliance evaluated in real-time during deployments
- **Blocking & Warning Modes**: Configurable enforcement levels for different environments
- **Compliance Reporting**: Comprehensive dashboards and audit reporting

**📋 Learn More**: Explore the complete [Governance Framework](docs/ARCHITECTURE.md#%EF%B8%8F-governance--policy-framework) in our architecture documentation.

---

## 🚀 Initial Setup: Fork Service Repositories

Before you can deploy the BookVerse platform, you need to fork the service repositories from the upstream organization to your own GitHub organization or user account.

### Why Fork?

The BookVerse demo consists of multiple service repositories that need to be under your control to:
- Configure repository secrets and variables
- Set up CI/CD workflows with your JFrog Platform
- Customize settings for your environment
- Maintain your own codebase

### Quick Fork Setup

Use the automated forking script to fork all service repositories at once:

```bash
# Navigate to the bookverse-demo-init repository
cd bookverse-demo-init

# Authenticate with GitHub CLI (if not already done)
gh auth login

# Fork all repositories to your GitHub account/organization
./scripts/create-clean-repos.sh --target-org YOUR_ORG --upstream-org yonatanp-jfrog --clone-local
```

**Script Options:**
- `--target-org ORG`: Your GitHub organization or username (default: auto-detected from current repo)
- `--upstream-org ORG`: Upstream organization to fork from (default: `yonatanp-jfrog`)
- `--dry-run`: Preview what would be forked without making changes
- `--clone-local`: Automatically clone forked repos locally after forking
- `--help`: Show detailed usage information

**Examples:**
```bash
# Fork to your personal GitHub account
./scripts/create-clean-repos.sh --target-org yourusername --clone-local

# Fork to an organization (dry run first to preview)
./scripts/create-clean-repos.sh --target-org your-org --dry-run

# Fork and clone locally in one step
./scripts/create-clean-repos.sh --target-org your-org --upstream-org yonatanp-jfrog --clone-local
```

### What Gets Forked?

The script forks these service repositories:
- `bookverse-inventory` - Product catalog and inventory management
- `bookverse-recommendations` - AI-powered recommendation engine
- `bookverse-checkout` - Order processing and payment management
- `bookverse-platform` - Platform coordination and API gateway
- `bookverse-web` - Frontend web application
- `bookverse-helm` - Kubernetes deployment charts

### After Forking

Once repositories are forked, you'll need to:
1. **Configure Environment Variables**: Set up your JFrog Platform configuration using `environment.sh`
2. **Generate Evidence Keys** (optional): Use `3_update_evidence_keys.sh` to generate new keys
3. **Configure Repository Variables & Secrets**: Use the automated script to configure all service repositories
4. **Set Up OIDC**: Configure OIDC providers for each service (automated via Setup Platform workflow)
5. **Run Setup Platform**: Execute the Setup Platform workflow to provision your JFrog Platform environment

#### Step 1: Configure Environment Variables

Before configuring repository secrets and variables, you need to set up your environment configuration file:

**⚠️ IMPORTANT: Never commit `environment.sh` to Git!** This file contains sensitive secrets and tokens. The `environment.sh` file is already in `.gitignore` to prevent accidental commits.

```bash
# Copy the example template to create your local environment file
# This is a one-time setup step - the template is safe to commit
cp environment.sh.example environment.sh

# Edit environment.sh with your actual values
# Use your preferred editor (nano, vim, code, etc.)
nano environment.sh
# or
code environment.sh

# Required variables to configure:
#   - JFROG_URL: Your JFrog Platform URL (e.g., "https://your-instance.jfrog.io")
#   - JFROG_ADMIN_TOKEN: JFrog Platform admin token (for key generation/upload)
#   - EVIDENCE_KEY_ALIAS: Evidence key alias in JFrog Platform (e.g., "bookverse-signing-key")
#
# Optional variables:
#   - PROJECT_KEY: JFrog project key (defaults to "bookverse")
#   - DOCKER_REGISTRY: Docker registry hostname (auto-derived from JFROG_URL if not set)
#   - EVIDENCE_PRIVATE_KEY: Private key for evidence signing (only if using existing keys)
#   - GH_REPO_DISPATCH_TOKEN: GitHub PAT for cross-repo workflows (optional)

# After editing, source the environment file to export all variables
source environment.sh
```

**Security Best Practices:**
- ✅ Always use `environment.sh.example` as your starting template
- ✅ Keep `environment.sh` local to your machine (it's in `.gitignore`)
- ✅ Never share `environment.sh` in chat, email, or commit it to Git
- ✅ Use strong, unique tokens for each environment
- ✅ Rotate tokens regularly for production environments

**Example `environment.sh` configuration (initial setup):**
```bash
export JFROG_URL="https://your-instance.jfrog.io"
export JFROG_ADMIN_TOKEN="your-jfrog-admin-token"
export EVIDENCE_KEY_ALIAS="bookverse-signing-key"
export PROJECT_KEY="bookverse"
# EVIDENCE_PRIVATE_KEY is not needed initially - will be generated in Step 2
# export GH_REPO_DISPATCH_TOKEN="ghp_xxxxxxxxxxxx..."  # Optional
```

**Note**: `EVIDENCE_PRIVATE_KEY` is optional initially. If you're generating keys with `3_update_evidence_keys.sh`, you don't need to set it in `environment.sh` until after keys are generated.

#### Step 2: Generate Evidence Keys (Optional)

If you need to generate new evidence keys, use the key generation script:

```bash
# Make sure you've sourced environment.sh first
source environment.sh

# Generate new evidence keys and upload to JFrog Platform
./scripts/3_update_evidence_keys.sh --generate --org "your-org"

# After generation, save the private key shown in the output
# You can then add it to environment.sh if needed for configure_service_secrets.sh
```

#### Step 3: Configure Repository Secrets and Variables

Once your environment variables are set, use the automated configuration script to set up all service repositories:

```bash
# Make sure you've sourced environment.sh first
source environment.sh

# Run the configuration script with your GitHub organization
.github/scripts/setup/configure_service_secrets.sh "your-org"
```

This script will automatically configure:
- **Repository Variables**: `JFROG_URL`, `PROJECT_KEY`, `DOCKER_REGISTRY`, `EVIDENCE_KEY_ALIAS`
- **Repository Secrets**: `EVIDENCE_PRIVATE_KEY`
- **Optional Dispatch Token**: `GH_REPO_DISPATCH_TOKEN` (if provided, for cross-repo workflows)

**📋 Next Steps**: Continue with the [Getting Started Guide](docs/GETTING_STARTED.md) for complete setup instructions.

---

## 🎯 Where Do You Want to Start?

Choose your path based on your needs:

- **🚀 Quick Start**: Follow the [Getting Started Guide](docs/GETTING_STARTED.md) for rapid deployment
- **🏗️ Deep Dive**: Explore the [Platform Architecture Overview](docs/ARCHITECTURE.md) for detailed system understanding  
- **🎮 Demo**: Run through the [Demo Runbook](docs/DEMO_RUNBOOK.md) for hands-on experience

---

## 🏗️ Platform Architecture

BookVerse consists of seven integrated components that work together to deliver a complete microservices ecosystem, each showcasing different CI/CD patterns and deployment strategies:

### 📦 **Inventory Service**

#### Product catalog and stock management

- Real-time inventory tracking and availability management
- RESTful API for catalog operations and stock queries
- SQLite database with comprehensive book metadata
- Automated stock level monitoring and alerts

**Build Pattern**: Single-container application - demonstrates basic containerized service deployment with minimal complexity

### 🤖 **Recommendations Service**

#### AI-powered personalized recommendations

- Machine learning recommendation engine with configurable algorithms
- Real-time recommendation generation (sub-200ms response times)
- Scalable worker architecture for background processing
- Configurable recommendation models and scoring factors

**Build Pattern**: Multi-container orchestration - showcases complex service deployment with multiple Docker images, worker processes, and supporting artifacts

### 💳 **Checkout Service**

#### Order processing and payment management

- Complete order lifecycle management from cart to fulfillment
- Integrated payment processing with mock and real payment gateways
- Order state tracking and inventory coordination
- Event-driven architecture with order notifications

**Build Pattern**: Service with dependencies - demonstrates deployment coordination with external services and database migrations

### 🌐 **Web Application**

#### Modern responsive frontend

- Single-page application built with vanilla JavaScript
- Responsive design with mobile-first approach
- Real-time integration with all backend services
- Client-side routing and state management

**Build Pattern**: Static asset deployment - showcases frontend build pipelines with asset optimization and CDN distribution

### 🏢 **Platform Service**

#### Integration testing and validation

- Cross-service integration testing as a unified platform
- End-to-end validation of service interactions
- Platform-wide health verification and monitoring
- Component compatibility and version validation

**Build Pattern**: Aggregation service - demonstrates platform-level testing patterns that validate multiple services working together

### 🏗️ **Infrastructure Libraries**

#### Shared libraries and DevOps tooling

- Core business logic shared across services (bookverse-core)
- DevOps automation and deployment scripts (bookverse-devops)
- Common utilities and configuration management
- Evidence collection and compliance frameworks

**Build Pattern**: Multi-artifact library publishing - showcases shared library management with separate core and DevOps build pipelines

### ⎈ **Helm Charts**

#### Kubernetes deployment automation

- Production-ready Helm charts for all services
- Environment-specific configuration management
- GitOps deployment workflows with ArgoCD integration
- Automated scaling and resource management

**Build Pattern**: Infrastructure as Code - demonstrates versioned deployment artifacts and environment promotion strategies

### 🚀 **Demo Orchestration Layer**

#### Platform setup and configuration automation (Demo Infrastructure)

- Automated JFrog Platform provisioning and configuration
- GitHub repository creation and CI/CD setup
- OIDC integration and security configuration
- Environment validation and health checking

**Build Pattern**: Setup automation - showcases demo environment provisioning and platform configuration (not part of the BookVerse application itself)

### Summary

| Component | Purpose | Technology Stack | Deployment | Build Pattern |
|-----------|---------|------------------|------------|---------------|
| **Inventory** | Product catalog & inventory management | Python, FastAPI, SQLite | Container + K8s | Single-container |
| **Recommendations** | AI-powered recommendation engine | Python, scikit-learn, FastAPI | Container + K8s | Multi-container |
| **Checkout** | Order processing & payments | Python, FastAPI, PostgreSQL | Container + K8s | Service dependencies |
| **Web App** | Frontend user interface | Vanilla JS, Vite, HTML5 | Static + CDN | Static assets |
| **Platform** | Integration testing & validation | Python, FastAPI | Container + K8s | Aggregation service |
| **Infrastructure** | Shared libraries & DevOps tooling | Python, Shell | Multi-artifact | Library publishing |
| **Helm Charts** | K8s deployment automation | Helm 3, YAML | GitOps | Infrastructure as Code |
| **Demo Orchestration** | Platform setup automation | Python, Shell, GitHub Actions | Automation | Setup automation |

---

## 🎯 Use Cases

### 🏢 **Enterprise Development Teams**

- Reference architecture for microservices transformation
- Secure CI/CD pipeline implementation
- Container orchestration and deployment automation
- DevSecOps practices and compliance automation

### 🔧 **DevOps Engineers**

- Complete GitOps workflow implementation
- Multi-environment deployment strategies
- Infrastructure as Code patterns
- Monitoring and observability setup

### 🔐 **Security Teams**

- Software supply chain security implementation
- Zero-trust CI/CD pipeline design
- Vulnerability management workflows
- Compliance and audit trail automation

### 🏗️ **Platform Engineers**

- Microservices architecture patterns
- Service mesh and API gateway configuration
- Cross-service communication strategies
- Platform engineering best practices

---

## 📚 Documentation

### 🚀 **Platform Setup & Architecture**

- [📖 **Getting Started**](docs/GETTING_STARTED.md) - Complete setup and deployment instructions
- [🏗️ **Platform Architecture Overview**](docs/ARCHITECTURE.md) - System design and component relationships
- [🎮 **Demo Runbook**](docs/DEMO_RUNBOOK.md) - Step-by-step demo execution guide
- [⚙️ **Repository Architecture**](docs/REPO_ARCHITECTURE.md) - Code organization and structure

### ⚙️ **Operations & Integration**

- [🔄 **CI/CD Deployment**](docs/CICD_DEPLOYMENT_GUIDE.md) - Pipeline configuration and automation
- [🔐 **OIDC Authentication**](docs/OIDC_AUTHENTICATION.md) - Zero-trust authentication setup
- [🏗️ **Setup Automation**](docs/SETUP_AUTOMATION.md) - Platform provisioning and configuration
- [📈 **Evidence Collection**](docs/EVIDENCE_COLLECTION.md) - Compliance and audit trail automation
- [🚀 **GitOps Deployment**](docs/GITOPS_DEPLOYMENT.md) - Continuous deployment workflows
- [🔗 **JFrog Integration**](docs/JFROG_INTEGRATION.md) - Artifact management and security
- [⭐ **AppTrust Showcase Guide**](docs/APPTRUST_SHOWCASE_GUIDE.md) - How to demonstrate AppTrust features

### 🔧 **Advanced Topics**

- [🔄 **Promotion Workflows**](docs/PROMOTION_WORKFLOWS.md) - Multi-stage deployment strategies
- [🔑 **Evidence Key Deployment**](docs/EVIDENCE_KEY_DEPLOYMENT.md) - Cryptographic key management
- [🔧 **JFrog Platform Switch**](docs/SWITCH_JFROG_PLATFORM.md) - Platform migration procedures

---

## 🌟 Platform Highlights

- **Zero-Trust Security**: OIDC authentication, cryptographic evidence, SBOM generation, and vulnerability scanning
- **Advanced CI/CD**: Multi-stage promotion, intelligent filtering, and comprehensive audit trails  
- **Cloud-Native**: Container-first deployment with Kubernetes and GitOps integration
- **Enterprise Ready**: Scalable architecture with monitoring, automated testing, and multi-environment support

---

## 🚀 Ready to Get Started?

BookVerse provides everything you need to implement enterprise-grade microservices with secure, automated software delivery.

**Choose your next step:**
- **New to BookVerse?** Start with the [Getting Started Guide](docs/GETTING_STARTED.md)
- **Want to understand the architecture?** Read the [Platform Architecture Overview](docs/ARCHITECTURE.md)
- **Ready to run a demo?** Follow the [Demo Runbook](docs/DEMO_RUNBOOK.md)
- **Want to showcase AppTrust features?** See the [AppTrust Showcase Guide](docs/APPTRUST_SHOWCASE_GUIDE.md)

For additional support and documentation, explore the comprehensive guides above or visit the individual service repositories.

---

> **Note**: Individual service documentation is available in each service repository:
> - [Inventory Service](https://github.com/yonatanp-jfrog/bookverse-inventory)
> - [Recommendations Service](https://github.com/yonatanp-jfrog/bookverse-recommendations)  
> - [Checkout Service](https://github.com/yonatanp-jfrog/bookverse-checkout)
> - [Platform Service](https://github.com/yonatanp-jfrog/bookverse-platform)
> - [Web Application](https://github.com/yonatanp-jfrog/bookverse-web)
> - [Helm Charts](https://github.com/yonatanp-jfrog/bookverse-helm)
> - [Infrastructure Libraries](https://github.com/yonatanp-jfrog/bookverse-infra)
