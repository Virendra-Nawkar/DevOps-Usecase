<div align="center">

# 🚀 DevOps Portfolio — Azure CI/CD Pipeline

### Next.js App → Docker → Azure Container Registry → Azure Web App for Containers

[![Azure DevOps](https://img.shields.io/badge/Azure%20DevOps-CI%2FCD-0078D4?style=for-the-badge&logo=azuredevops&logoColor=white)](https://dev.azure.com/virendranawkarghrce)
[![Docker](https://img.shields.io/badge/Docker-Multi--Stage%20Build-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Next.js](https://img.shields.io/badge/Next.js-14-000000?style=for-the-badge&logo=nextdotjs&logoColor=white)](https://nextjs.org/)
[![Azure](https://img.shields.io/badge/Azure-Web%20App%20for%20Containers-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![TypeScript](https://img.shields.io/badge/TypeScript-90.8%25-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)

<br/>

> **Use Case:** End-to-end deployment of a Next.js DevOps Portfolio web application using a fully automated Azure DevOps CI/CD pipeline — from code push to live production in under 5 minutes.

<br/>

[🔗 Live App](https://virendra-react-app.azurewebsites.net) &nbsp;·&nbsp; [📋 Azure DevOps Org](https://dev.azure.com/virendranawkarghrce) &nbsp;·&nbsp; [👤 GitHub Profile](https://github.com/Virendra-Nawkar)

</div>

---

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [CI/CD Pipeline Flow](#-cicd-pipeline-flow)
- [Azure Resources](#-azure-resources)
- [Dockerfile Explained](#-dockerfile-explained)
- [Branch Strategy](#-branch-strategy)
- [Pipeline YAML Breakdown](#-pipeline-yaml-breakdown)
- [Environment Variables](#-environment-variables)
- [Problems Faced & Solutions](#-problems-faced--solutions)
- [Local Development](#-local-development)
- [Key Learnings](#-key-learnings)

---

## 🏗️ Architecture Overview

```
Developer (Linux VM)
        │
        │  git push (SSH)
        ▼
┌─────────────────────────────────────────────────────────┐
│                    Azure DevOps                         │
│                                                         │
│  ┌─────────────┐        ┌──────────────────────────┐   │
│  │ Azure Repos │        │     CI/CD Pipeline        │   │
│  │  main + dev │──────▶ │  ubuntu-latest agent      │   │
│  │  (SSH auth) │        │                           │   │
│  │  PR required│        │  CI: build → push to ACR  │   │
│  └─────────────┘        │  CD: deploy → Web App     │   │
│                         └──────────────┬─────────────┘  │
└────────────────────────────────────────│────────────────┘
                                         │
                    ┌────────────────────┼────────────────┐
                    │     Azure Cloud (Central India)     │
                    │                    │                │
                    │   ┌────────────────▼──────────────┐ │
                    │   │  Azure Container Registry     │ │
                    │   │  virendraacr.azurecr.io       │ │
                    │   │  reactapp:latest + :BuildId   │ │
                    │   └────────────────┬──────────────┘ │
                    │                    │  pulls image   │
                    │   ┌────────────────▼──────────────┐ │
                    │   │  Azure Web App for Containers │ │
                    │   │  Next.js — port 3000          │ │
                    │   │  virendra-react-app.azurewebsites.net │
                    │   └───────────────────────────────┘ │
                    └────────────────────────────────────-┘
                                         │
                                    End User (HTTPS)
```

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| **Application** | Next.js 14, TypeScript, Tailwind CSS |
| **Containerization** | Docker — multi-stage build, Alpine base |
| **Container Registry** | Azure Container Registry (ACR) — Basic SKU |
| **CI/CD Platform** | Azure DevOps Pipelines — YAML-based |
| **Hosting** | Azure Web App for Containers — Linux B1 |
| **Source Control** | Azure Repos — SSH authentication |
| **IaC / CLI** | Azure CLI (`az`) |

---

## 📁 Project Structure

```
DevOps-Usecase/
├── app/                        # Next.js app directory (pages, layouts)
├── components/                 # Reusable React components
├── data/                       # JSON data files (certifications, projects, etc.)
│   ├── certifications.json
│   ├── experience.json
│   ├── profile.json
│   ├── projects.json
│   └── skills.json
├── .dockerignore               # Excludes node_modules, .git from build context
├── .gitignore
├── Dockerfile                  # Multi-stage build (builder + runner)
├── azure-pipelines.yml         # CI/CD pipeline definition
├── next.config.js              # Next.js config (output: standalone)
├── package.json
├── tailwind.config.ts
└── tsconfig.json
```

---

## 🔄 CI/CD Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         TRIGGER                                 │
│              Push to main or dev branch                         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
          ┌────────────────▼──────────────────┐
          │          CI STAGE                 │
          │      (runs on both branches)      │
          │                                   │
          │  1. Checkout code from Azure Repos│
          │  2. Login to ACR (service conn.)  │
          │  3. Docker build (multi-stage)    │
          │  4. Push image → ACR              │
          │     tags: :$(Build.BuildId)       │
          │            :latest                │
          └────────────────┬──────────────────┘
                           │
          ┌────────────────▼──────────────────┐
          │       CONDITION CHECK             │
          │  branch == 'refs/heads/main' ?    │
          └─────────┬──────────────┬──────────┘
                    │ YES          │ NO
          ┌─────────▼──────┐  ┌───▼──────────────┐
          │   CD STAGE     │  │  SKIP CD          │
          │                │  │  (dev branch —    │
          │  1. Pull image │  │  build only, no   │
          │     from ACR   │  │  deployment)      │
          │  2. Deploy to  │  └──────────────────-┘
          │  Azure Web App │
          │  3. Container  │
          │  restarts live │
          └────────────────┘
```

> 💡 **Why this design?** Pushing to `dev` only runs CI (build + test image). Only code that passes review and lands on `main` via PR gets deployed to production. This prevents accidental deployments.

---

## ☁️ Azure Resources

### 1. Azure Container Registry (ACR)

| Property | Value |
|---|---|
| Registry Name | `virendraacr` |
| Login Server | `virendraacr.azurecr.io` |
| SKU | Basic |
| Location | Central India |
| Admin User | Enabled |

### 2. App Service Plan

| Property | Value |
|---|---|
| Plan Name | `virendra-plan` |
| OS | Linux |
| Pricing Tier | Basic B1 (1 vCore, 1.75 GB RAM) |
| Region | Central India |

### 3. Azure Web App for Containers

| Property | Value |
|---|---|
| App Name | `virendra-react-app` |
| URL | [virendra-react-app.azurewebsites.net](https://virendra-react-app.azurewebsites.net) |
| Image Source | ACR → `reactapp:latest` |
| Container Port | 3000 |

---

## 🐳 Dockerfile Explained

A **multi-stage Dockerfile** is used — Stage 1 builds the app, Stage 2 runs only the compiled output. The final image has no source code and no build tools.

```dockerfile
# ── Stage 1: Builder ─────────────────────────────────────
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package.json first — Docker caches this layer
# If packages haven't changed, npm install is skipped on rebuild
COPY package*.json ./
RUN npm install

# Copy source code and build
COPY . .
RUN npm run build
# Output goes to .next/standalone/ (because of output: standalone in next.config.js)

# ── Stage 2: Runner ──────────────────────────────────────
FROM node:18-alpine AS runner
WORKDIR /app

# Copy ONLY what's needed to run — not the entire source
COPY --from=builder /app/.next/standalone ./   # self-contained server
COPY --from=builder /app/.next/static ./.next/static  # CSS, JS chunks
COPY --from=builder /app/data ./data           # JSON data files

EXPOSE 3000
ENV NODE_ENV=production

# Run the standalone server directly — no npm overhead
CMD ["node", "server.js"]
```

### Why multi-stage?

| Metric | Single-stage | Multi-stage (this project) |
|---|---|---|
| Final image size | ~500 MB | **~49 MB content** |
| Contains source code | ✅ Yes | ❌ No |
| Contains node_modules | ✅ All of them | ❌ Only runtime deps |
| Build tools in prod | ✅ Yes | ❌ No |

### next.config.js — Standalone Output

```js
const nextConfig = {
  output: 'standalone',  // ← This is the key setting
  images: {
    remotePatterns: [{ protocol: 'https', hostname: 'images.credly.com' }],
  },
}
```

`output: 'standalone'` traces all required files and bundles them — eliminating the need to copy the full `node_modules` folder into the image.

---

## 🌿 Branch Strategy

```
main  ─────────────────────────────────────────────▶  PRODUCTION
        ▲               ▲               ▲
        │ PR + Approve  │ PR + Approve  │ PR + Approve
        │               │               │
dev  ───┴───────────────┴───────────────┴───────────▶  DEVELOPMENT
```

### Branch Policies on `main`

| Policy | Setting |
|---|---|
| Minimum reviewers | 1 required |
| Requestor can approve own PR | ✅ Enabled (solo dev) |
| Comment resolution | Required |
| Merge type | Squash merge only |
| Direct push | ❌ Blocked — error `TF402455` |

> Direct pushes to `main` are blocked. All changes must go through a Pull Request. This mirrors how production-grade teams at companies like Swiggy and Razorpay protect their main branches.

---

## 📄 Pipeline YAML Breakdown

```yaml
trigger:
  branches:
    include:
      - main
      - dev          # CI runs on both; CD only on main

variables:
  acrLoginServer: 'virendraacr.azurecr.io'
  imageName: 'reactapp'
  imageTag: '$(Build.BuildId)'    # unique per run — enables rollback
  webAppName: 'virendra-react-app'

stages:
- stage: CI
  jobs:
  - job: BuildAndPush
    pool:
      vmImage: 'ubuntu-latest'    # Microsoft-hosted agent
    steps:
    - checkout: self

    - task: Docker@2
      inputs:
        command: 'login'
        containerRegistry: 'acr-service-connection'

    - task: Docker@2
      inputs:
        command: 'build'
        repository: '$(imageName)'           # ← image name ONLY, no URL prefix
        containerRegistry: 'acr-service-connection'
        tags: |
          $(imageTag)
          latest

    - task: Docker@2
      inputs:
        command: 'push'
        repository: '$(imageName)'
        containerRegistry: 'acr-service-connection'
        tags: |
          $(imageTag)
          latest

- stage: CD
  dependsOn: CI
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployToWebApp
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebAppContainer@1
            inputs:
              azureSubscription: 'azure-service-connection'
              appName: '$(webAppName)'
              imageName: '$(acrLoginServer)/$(imageName):$(imageTag)'
```

### Service Connections Required

| Name | Type | Purpose |
|---|---|---|
| `acr-service-connection` | Docker Registry | Login, build, push images to ACR |
| `azure-service-connection` | Azure Resource Manager | Deploy container to Web App |

---

## ⚙️ Environment Variables

These must be set on the Azure Web App under **Settings → Environment variables**:

| Variable | Value | Why |
|---|---|---|
| `WEBSITES_PORT` | `3000` | Azure forwards incoming HTTPS traffic to this port |
| `HOSTNAME` | `0.0.0.0` | Next.js must listen on all interfaces, not just localhost |
| `PORT` | `3000` | Explicit port for the standalone `server.js` |

> Without `HOSTNAME=0.0.0.0`, the Next.js server binds only to `localhost` inside the container — Azure's reverse proxy cannot reach it, resulting in an **Application Error**.

---

## 🐛 Problems Faced & Solutions

<details>
<summary><b>1. MissingSubscriptionRegistration — ACR creation failed</b></summary>

**Error:** `The subscription is not registered to use namespace 'Microsoft.ContainerRegistry'`

**Cause:** New Azure subscriptions require one-time namespace registration before using certain services.

**Fix:**
```bash
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.Web
# Wait ~2 min, then check:
az provider show --namespace Microsoft.ContainerRegistry --query registrationState
```
</details>

<details>
<summary><b>2. Docker image pushed to wrong path in ACR</b></summary>

**Error:** `ImagePullUnauthorizedFailure` — image not found at expected path

**Cause:** The `repository` field in `Docker@2` task included the full ACR URL (`virendraacr.azurecr.io/reactapp`). Since the service connection also adds the URL, the image was stored at a doubled path: `virendraacr.azurecr.io/virendraacr.azurecr.io/reactapp`.

**Fix:** Use only the image name in the repository field:
```yaml
# ❌ Wrong
repository: '$(acrLoginServer)/$(imageName)'

# ✅ Correct
repository: '$(imageName)'   # service connection adds the URL automatically
```
</details>

<details>
<summary><b>3. Application Error on Web App after successful deployment</b></summary>

**Error:** `:(  Application Error` on the live URL

**Cause:** Port mismatch — Next.js runs on port 3000, Azure Web App defaults to port 80. Also, `server.js` binds to `localhost` by default inside a container.

**Fix:** Add three environment variables on the Web App:
```
WEBSITES_PORT = 3000
HOSTNAME      = 0.0.0.0
PORT          = 3000
```
</details>

<details>
<summary><b>4. .next/standalone not found during Docker build</b></summary>

**Error:** `failed to compute cache key: "/app/.next/standalone": not found`

**Cause:** `output: 'standalone'` was missing from `next.config.js`. Without it, Next.js doesn't generate the standalone folder.

**Fix:** Add to `next.config.js`:
```js
const nextConfig = {
  output: 'standalone',   // ← add this
  // ... rest of config
}
```
</details>

<details>
<summary><b>5. CD stage skipped — no deployment happening</b></summary>

**Cause:** The pipeline ran from the `dev` branch. The CD stage condition (`eq(variables['Build.SourceBranch'], 'refs/heads/main')`) correctly filtered it out.

**Fix:** Raise a Pull Request from `dev` → `main`, approve, and complete merge. The pipeline then runs both CI + CD.
</details>

---

## 💻 Local Development

### Prerequisites
- Node.js 18+
- Docker Desktop

### Run locally without Docker

```bash
git clone https://github.com/Virendra-Nawkar/DevOps-Usecase.git
cd DevOps-Usecase
npm install
npm run dev
# App available at http://localhost:3000
```

### Run with Docker

```bash
# Build the image
docker build -t devops-portfolio:local .

# Run the container
docker run -p 3000:3000 -e PORT=3000 -e HOSTNAME=0.0.0.0 devops-portfolio:local

# App available at http://localhost:3000
```

### Expected Docker build output
```
[+] Building ~74s (14/14) FINISHED
 => [builder] npm install          ~70s
 => [builder] npm run build        ~58s
 => [runner] COPY standalone        0.4s
 => [runner] COPY static            0.2s
 => [runner] COPY data              0.1s
 => exporting to image              2.3s

IMAGE               SIZE
devops-portfolio    212MB  (49.6MB content)
```

---

## 🧠 Key Learnings

- **Multi-stage Docker builds** with `output: 'standalone'` reduce Next.js image size by ~90%
- **Branch policies** are the backbone of production safety — they enforce review before any code touches `main`
- **Service connections** must be recreated when target Azure resources are deleted and recreated — they store resource IDs, not just credentials
- **`Docker@2` task** with a `containerRegistry` service connection auto-prepends the ACR URL — only the image name should go in the `repository` field
- **`HOSTNAME=0.0.0.0`** is essential for any container serving HTTP inside Azure Web App
- Tagging images with **`$(Build.BuildId)` + `latest`** gives you both convenience and precise rollback capability
- **`az provider register`** is a one-time prerequisite for each Azure service namespace on a new subscription

---

## 👤 Author

**Virendra Santosh Nawkar**  
B.Tech CSE (AI & ML) — G.H. Raisoni College of Engineering, Nagpur  
DevOps Engineer Intern — Cognizant Technology Solutions

[![GitHub](https://img.shields.io/badge/GitHub-Virendra--Nawkar-181717?style=flat-square&logo=github)](https://github.com/Virendra-Nawkar)
[![Email](https://img.shields.io/badge/Email-virendranawkar1%40gmail.com-D14836?style=flat-square&logo=gmail&logoColor=white)](mailto:virendranawkar1@gmail.com)

---

<div align="center">

**If this project helped you, consider giving it a ⭐**

</div>
