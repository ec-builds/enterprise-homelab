# 🐳 Docker & Self-Hosted Services

**Status: 📋 Planned**

Containerized self-hosted applications managed with Docker Compose on a dedicated VM in the Proxmox lab.

## 🎯 Objectives

- Deploy and maintain self-hosted services as containers
- Manage the stack with version-controlled compose files
- Implement a reverse proxy with automatic TLS
- Apply container best practices: named volumes, custom networks, resource limits, health checks
- Keep images updated and monitor container health

## 🛠️ Technologies

- Docker & Docker Compose
- Reverse proxy (Nginx Proxy Manager, Traefik, or Caddy)
- Container management UI (Portainer or Dockge)
- Update monitoring (Watchtower or Diun)

## 🧩 Candidate Services

| Category | Examples |
|----------|----------|
| Dashboard | Homepage, Heimdall |
| Network | Pi-hole / AdGuard Home |
| Productivity | Nextcloud, Vaultwarden, Paperless-ngx |
| Monitoring | Uptime Kuma |
| Utilities | n8n, Stirling-PDF |

## 📋 Key Tasks

- [ ] Provision and harden the Docker host VM
- [ ] Standardize compose structure with `.env` files (gitignored)
- [ ] Deploy reverse proxy with TLS certificates
- [ ] Segment services with custom Docker networks
- [ ] Configure persistent volumes and add them to backup jobs
- [ ] Document each service: purpose, ports, dependencies

## 🔗 Related Projects

- [kubernetes-lab](../kubernetes-lab/) — selected services later migrate to k3s as an orchestration exercise
- [backup-disaster-recovery](../backup-disaster-recovery/) — volume backup integration

## 📁 Folder Structure

```
docker-self-hosted-services/
├── compose/         # docker-compose.yml per service/stack
├── docs/            # Service documentation, lessons learned
├── scripts/         # Maintenance scripts
└── screenshots/     # Visual documentation
```

## ⚠️ Security Note

`.env` files, passwords, and API keys are never committed. Sanitized `*.env.example` templates are provided instead.
