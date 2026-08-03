# GitOps Continuous Delivery with ArgoCD

This laboratory implements a declarative GitOps pipeline using **ArgoCD** to synchronize cluster state with configurations managed in the Git repository.

## ⚙️ Declarative Application Mapping

The file `argo-app.yaml` defines a custom resource mapping:
- **`repoURL`**: Points to the target Git Repository holding Kubernetes resources.
- **`path`**: Targets the subfolder containing Kubernetes Helm Chart values (`docker-kubernetes-laravel/helm/laravel-app`).
- **`destination`**: Deploys configurations to the internal Cluster IP namespace: `production`.
- **`syncPolicy`**: 
  - **`prune`**: Automatically deletes cluster resources that are removed from Git.
  - **`selfHeal`**: Corrects manual configurations or drifts made inside the cluster by reverting them back to the configuration managed in Git.

---

## 🚀 Execution Steps

1. Install ArgoCD onto the cluster:
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```
2. Apply the application specification resource:
   ```bash
   kubectl apply -f argo-app.yaml
   ```
3. ArgoCD will track commits, detect out-of-sync configurations, and automatically trigger helm dry-runs to reconcile deployments.
