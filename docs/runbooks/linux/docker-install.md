# Docker Install Runbook — Debian Linux

**Status:** Complete  
**Platform:** Debian Linux  
**Install Method:** Official Docker APT Repository  
**Purpose:** Install Docker Engine and Docker Compose Plugin on a headless Debian server.

**Website Reference:** https://docs.docker.com/engine/install/debian/#install-using-the-repository


---

## Overview

This runbook documents the installation of Docker Engine on Debian using Docker's official APT repository.

Docker will be used to run containerized homelab services such as:

- Uptime Kuma
- Homepage
- Grafana
- Prometheus
- Loki
- Other self-hosted services

This installation does **not** use Docker Desktop or any graphical interface.

---

## Prerequisites

Update package lists:

```bash
sudo apt update
```

Install required packages:

```bash
sudo apt install ca-certificates curl
```

---

## Remove Conflicting Packages

Remove any conflicting Docker-related packages that may have been installed from other repositories.

```bash
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)
```

It is normal if APT reports that some or all packages are not installed.

---

## Add Docker GPG Key

Create the APT keyring directory:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

Download Docker's official signing key:

```bash
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
```

Set permissions:

```bash
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Verify:

```bash
ls -lash /etc/apt/keyrings/
```

Expected output should include:

```text
docker.asc
```

---

## Add Docker Repository

Create the Docker repository source file:

```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

Verify:

```bash
cat /etc/apt/sources.list.d/docker.sources
```

Expected output:

```text
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: <detected automatically>
Components: stable
Architectures: <detected automatically>
Signed-By: /etc/apt/keyrings/docker.asc
```

---

## Update Package Lists

Refresh package metadata:

```bash
sudo apt update
```

Verify that Docker's repository appears in the output.

---

## Install Docker Engine

Install Docker Engine and related components:

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Installed components:

| Package | Purpose |
|----------|----------|
| docker-ce | Docker Engine |
| docker-ce-cli | Docker CLI |
| containerd.io | Container runtime |
| docker-buildx-plugin | Extended image build functionality |
| docker-compose-plugin | Docker Compose support |

---

## Verify Docker Service

Check service status:

```bash
sudo systemctl status docker
```

Enable Docker at startup:

```bash
sudo systemctl enable docker
```

---

## Validate Installation

Run the test container:

```bash
sudo docker run hello-world
```

Expected output:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

---

## Configure Non-Root Access

Add the current user to the Docker group:

```bash
sudo usermod -aG docker $USER
```

Log out and reconnect to the server.

Verify group membership:

```bash
groups
```

Expected output should include:

```text
docker
```

Test Docker without sudo:

```bash
docker ps
docker run hello-world
```

---

## Verify Docker Compose

Check the installed Compose plugin:

```bash
docker compose version
```

Expected output:

```text
Docker Compose version ...
```

---

## Basic Docker Commands

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

List downloaded images:

```bash
docker images
```

Launch a temporary Ubuntu container:

```bash
docker run -it ubuntu bash
```

Exit the container:

```bash
exit
```

Remove stopped containers:

```bash
docker container prune
```

---

## Docker Concepts

### Image

A Docker image is a reusable template.

Examples:

```text
ubuntu:latest
grafana/grafana
louislam/uptime-kuma
```

### Container

A container is a running instance created from an image.

Example:

```text
Ubuntu Image
      ↓
Ubuntu Container
```

### Registry

A registry stores images.

Example:

```text
Docker Hub
```

### Compose

Docker Compose allows multiple containers to be defined and managed using a YAML configuration file.

---

## Files Created or Modified

```text
/etc/apt/keyrings/docker.asc
/etc/apt/sources.list.d/docker.sources
```

Purpose:

```text
docker.asc       = Docker repository signing key
docker.sources   = Docker repository definition
```

---

## Validation Checklist

Verify the following commands complete successfully:

```bash
sudo docker run hello-world
docker ps
docker images
docker compose version
```

---

## Next Steps

Recommended first deployment:

```text
Uptime Kuma
```

Suggested monitoring targets:

- Router
- Debian server
- NAS
- Media services
- Future Grafana instance
- Future Prometheus instance
