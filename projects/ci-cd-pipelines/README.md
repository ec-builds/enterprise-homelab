# 🔁 CI/CD Pipelines

**Status: 📋 Planned**

Automated build, validation, and deployment workflows with GitHub Actions — the connective tissue of modern cloud engineering teams.

## Objectives

- Build CI pipelines that lint, validate, and test on every pull request
- Validate Terraform/IaC automatically before changes merge
- Build and publish container images from source
- Deploy applications to the k3s cluster automatically
- Practice pipeline security: secrets management, least-privilege tokens, environments

## Technologies

- GitHub Actions (workflows, runners, environments)
- Terraform validation (`fmt`, `validate`, `plan` in CI)
- Docker image build & registry (GitHub Container Registry)
- kubectl/Helm deployment steps
- Self-hosted runner on the homelab (for deploying to private infrastructure)

## Key Tasks

- [ ] Create a CI workflow that lints markdown/YAML across this repo
- [ ] Add Terraform validation workflow for [infrastructure-automation](../infrastructure-automation/)
- [ ] Build and push a container image to GHCR on tagged release
- [ ] Deploy a self-hosted runner VM and document the security tradeoffs
- [ ] Create a CD workflow deploying to the [k3s cluster](../kubernetes-lab/)
- [ ] Use GitHub Environments with approvals for "production" deploys
- [ ] Manage pipeline secrets correctly; document the approach
- [ ] Add a status badge to the root README

## Folder Structure

```
ci-cd-pipelines/
├── workflows/       # Reference copies / documentation of .github/workflows
├── docs/            # Pipeline architecture, build notes, lessons learned
└── screenshots/     # Visual documentation
```

> Note: live workflow files reside in `.github/workflows/` at the repo root; this folder documents their design and evolution.
