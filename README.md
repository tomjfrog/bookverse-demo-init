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

## 🚀 Initial Setup

The BookVerse platform setup is streamlined using GitHub Actions workflows. Follow these steps to get started:

### Overview

The setup process consists of three main steps:
1. **Fork Service Repositories** - Get your own copies of all service repositories
2. **🔄 Switch Platform Workflow** - Configure all repositories and generate evidence keys (primary method)
3. **🚀 Setup Platform Workflow** - Provision JFrog Platform infrastructure

---

### Step 1: Fork Service Repositories

Before you can deploy the BookVerse platform, you need to fork the service repositories from the upstream organization to your own GitHub organization or user account.

**Why Fork?**
The BookVerse demo consists of multiple service repositories that need to be under your control to:
- Configure repository secrets and variables
- Set up CI/CD workflows with your JFrog Platform
- Customize settings for your environment
- Maintain your own codebase

**Quick Fork Setup:**

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

**What Gets Forked?**

The script forks these service repositories:
- `bookverse-inventory` - Product catalog and inventory management
- `bookverse-recommendations` - AI-powered recommendation engine
- `bookverse-checkout` - Order processing and payment management
- `bookverse-platform` - Platform coordination and API gateway
- `bookverse-web` - Frontend web application
- `bookverse-helm` - Kubernetes deployment charts

---

### Step 2: Configure with Switch Platform Workflow ⭐

**The 🔄 Switch Platform workflow is the primary method for configuring BookVerse.** It automatically configures all repositories, generates evidence keys, and sets up everything you need.

**2a. Configure GitHub Repository Secrets**

Before running the Switch Platform workflow, set up repository secrets in the `bookverse-demo-init` repository:

1. Navigate to: `https://github.com/YOUR-ORG/bookverse-demo-init/settings/secrets/actions`
2. Add the following secrets:
   - **`JFROG_ADMIN_TOKEN`**: Your JFrog Platform admin token (required)
   - **`GH_TOKEN`**: GitHub Personal Access Token (optional - see note below)

**About GitHub Tokens:**

- **`GITHUB_TOKEN`**: Automatically provided by GitHub Actions for each workflow run. It has permissions to the repository where the workflow runs. The Switch Platform workflow uses this by default if `GH_TOKEN` is not set.
  
- **`GH_TOKEN`**: Used by the GitHub CLI (`gh`) for authentication. If you need broader permissions (e.g., to update variables/secrets across multiple repositories in your organization), you can create a Personal Access Token (PAT) with `repo`, `workflow`, and `admin:repo_hook` scopes and set it as the `GH_TOKEN` secret.

**When to set `GH_TOKEN`:**
- ✅ **Required** if the workflow needs to update repositories outside the current repository
- ✅ **Required** if you need organization-level permissions
- ✅ **Optional** if all operations are within the same repository (uses `GITHUB_TOKEN` by default)

**How to create a GitHub PAT for `GH_TOKEN`:**
1. Go to: `https://github.com/settings/tokens`
2. Click "Generate new token" → "Generate new token (classic)"
3. Set expiration and select scopes: `repo`, `workflow`, `admin:repo_hook`
4. Copy the token and add it as the `GH_TOKEN` secret in your repository

**2b. Run Switch Platform Workflow**

The Switch Platform workflow will configure all repositories and generate evidence keys automatically:

1. Navigate to: `https://github.com/YOUR-ORG/bookverse-demo-init/actions`
2. Select **"🔄 Switch Platform"** workflow
3. Click **"Run workflow"**
4. Configure the workflow inputs:
   - **Setup Mode**: `initial_setup` ⭐ (for first-time setup)
   - **JFrog Platform Host**: `https://your-instance.jfrog.io`
   - **Admin Token**: (leave empty - uses `JFROG_ADMIN_TOKEN` secret)
   - **Generate Evidence Keys**: `true` ✅ (recommended for initial setup)
   - **Evidence Key Type**: `rsa` (or `ec`, `ed25519`)
   - **Evidence Key Alias**: `bookverse-signing-key`
   - **Update Code URLs**: `false` (skip for initial setup)
   - **Update K8s**: `false` (unless you have Kubernetes configured)
5. Click **"Run workflow"**

**What the Switch Platform workflow does:**
- ✅ Configures `JFROG_URL`, `DOCKER_REGISTRY`, `PROJECT_KEY` variables in all service repos
- ✅ Sets `JFROG_ADMIN_TOKEN` secret in all service repos
- ✅ Generates evidence keys (RSA/EC/ED25519) automatically
- ✅ Distributes `EVIDENCE_PRIVATE_KEY` secret to all repos
- ✅ Sets `EVIDENCE_PUBLIC_KEY` and `EVIDENCE_KEY_ALIAS` variables in all repos
- ✅ Uploads public keys to JFrog Platform
- ✅ Validates platform connectivity and authentication

---

### Step 3: Provision JFrog Platform Infrastructure

After Switch Platform completes successfully, run the **🚀 Setup Platform** workflow to provision JFrog infrastructure:

1. Navigate to: `https://github.com/YOUR-ORG/bookverse-demo-init/actions`
2. Select **"🚀 Setup Platform"** workflow
3. Click **"Run workflow"** (no inputs required)

**What the Setup Platform workflow does:**
- ✅ Creates the `bookverse` project in JFrog Platform
- ✅ Sets up artifact repositories (Docker, PyPI, npm, etc.)
- ✅ Configures AppTrust applications with lifecycle stages (DEV, QA, STAGING, PROD)
- ✅ Creates OIDC integrations for GitHub authentication
- ✅ Sets up users and role-based access control

---

### ✅ Setup Complete!

After both workflows complete successfully, your BookVerse platform is ready! 

**📋 Next Steps**: Continue with the [Getting Started Guide](docs/GETTING_STARTED.md) for complete setup instructions including Kubernetes deployment.

---

### Alternative: Legacy Local Scripts (Deprecated)

**⚠️ Note**: The old approach using local scripts (`update_evidence_keys.sh`, `configure-service-secrets.sh`) is **deprecated** and only available for backward compatibility. 

**Why use Switch Platform workflow instead?**
- ✅ Better error handling and validation
- ✅ Integrated evidence key generation
- ✅ Automated configuration across all repositories
- ✅ Code URL updates (for platform migrations)
- ✅ Single workflow for all configuration
- ✅ No local environment setup required
- ✅ Workflow-based with comprehensive logging
- ✅ Automatic retry logic for failed operations

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
