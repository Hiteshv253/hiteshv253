# Jenkins Declarative CI/CD Pipelines

This laboratory implements a structured CI/CD deployment flow using a declarative **Jenkinsfile** pipeline configuration.

## 🧬 Pipeline Structure

The pipeline utilizes five declarative execution stages:
1. **`Checkout`**: Pulls the active repository workspace code.
2. **`Install Dependencies`**: Runs Composer package operations.
3. **`Unit Testing`**: Runs unit test suites.
4. **`Build & Push Docker Image`**: Connects securely to the Docker Hub registry using credentials stored in Jenkins, compiles the image, tags it with the live Jenkins Build ID, and pushes the build targets.
5. **`Deploy`**: Uses SSH credentials via the ssh-agent plugin to execute Docker Compose container reloads and database migrations.

---

## 🚀 Setup Steps

1. Configure **Credentials** in the Jenkins dashboard:
   - `docker-hub-credentials`: Username and password for your Docker Registry.
   - `vps-ssh-key`: SSH Private key to log into target app servers.
2. Install the **SSH Agent Plugin** in Jenkins.
3. Create a new **Pipeline** job pointing to your repository, select "Pipeline script from SCM", and set the script path to `bonus/jenkins-cicd/Jenkinsfile`.
