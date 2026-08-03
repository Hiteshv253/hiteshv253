# Multi-Stage Azure DevOps YAML Pipelines

This repository lab implements a secure, modular CI/CD pipeline using **Azure DevOps Pipelines** (`azure-pipelines.yml`) to orchestrate application deployments to Azure Container Services.

## 🧬 Pipeline Structure

The pipeline uses three distinct sequential stages:
1. **`Build` Stage**:
   - Spawns an ephemeral `ubuntu-latest` agent.
   - Installs PHP 8.2 and Composer dependencies.
   - Executes PHPUnit test suites and saves JUnit output artifacts.
2. **`Push` Stage**:
   - Triggers only when the `Build` stage succeeds.
   - Builds the production Docker image and tag it with the Unique Azure Build ID.
   - Pushes the image to **Azure Container Registry (ACR)**.
3. **`Deploy` Stage**:
   - Deploys the built image tag to **Azure Web App Service for Containers**.
   - Directs deployments into a `staging` app slot to verify integrity prior to swapping slots.
