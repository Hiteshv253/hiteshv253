# Contributing to Hiteshv253 Portfolio

We welcome contributions to improve these enterprise DevOps, IaC, and Kubernetes configurations.

## 🚀 How to Contribute

### 1. Code Standards
- **Terraform**: Must format files using `terraform fmt` and pass `terraform validate` checks.
- **Kubernetes**: Must pass basic dry-run configuration audits.
- **Shell Scripting**: All Bash scripts must be checked via `shellcheck` to prevent execution defects.
- **Docker**: Container structures should follow multi-stage caching standards.

### 2. Git Branching Model
- Fork the repository.
- Create a feature branch matching standard formats:
  `feat/name-of-feature`, `fix/bug-fix-name`, or `docs/update-docs`.

### 3. Commit Message Style (Conventional Commits)
Write clean, brief commit headers:
- `feat: add network isolation policy to Kubernetes configs`
- `fix: correct target groups ports mapping in actions workflow`
- `docs: update troubleshooting FAQs on restore failures`

### 4. Pull Requests
- Keep changes focused and document dependencies.
- Confirm all local integration tests pass.
