# Proxmox VE Baseline Build

Standard baseline procedure for deploying a Proxmox VE virtualization node in the EC-Builds lab.

The goal is to keep the hypervisor minimal and predictable. Application services run as virtual machines or containers rather than directly on the Proxmox host.

> **Design principle:** Proxmox + networking/storage + non-root administration + updates + lightweight telemetry. Everything else runs as a workload.

## Build Overview

| Step | Task |
|---|---|
| 1 | [Firmware and BIOS Configuration](#1-firmware-and-bios) |
| 2 | [Install Proxmox VE](#2-install-proxmox-ve) |
| 3 | [Configure Management Networking](#3-management-networking) |
| 4 | [Configure Repositories and Updates](#4-repository-and-updates) |
| 5 | [Create Administrative Account](#5-administrative-account) |
| 6 | [Validate Storage](#6-validate-storage) |
| 7 | [Join Proxmox Cluster](#7-join-the-proxmox-cluster) |
| 8 | [Install Node Exporter](#8-install-node-exporter) |
| 9 | [Validate Monitoring](#9-add-the-node-to-prometheus) |


## 1. Firmware and BIOS

Before installing Proxmox, review the system firmware and configure the host for virtualization.

### Firmware

Verify the currently installed BIOS/UEFI version and update it when appropriate using the hardware vendor's supported process.

Do not expose hardware serial numbers or other device-specific identifiers in public documentation.

### Recommended BIOS Settings

Verify the following settings where supported:

| Setting | Recommended |
|---|---|
| Boot Mode | UEFI |
| CPU Virtualization | Enabled |
| VT-d / IOMMU | Enable when required |
| Secure Boot | Enabled |
| Restore After AC Power Loss | Power On |
| TPM | Clear when repurposing hardware, if appropriate |

Do not enable passthrough-specific settings simply because they are available. Configure IOMMU/VFIO only on nodes that require PCIe or GPU passthrough.

## 2. Install Proxmox VE

Install Proxmox VE directly on the physical system using the official installation media.

During installation:

1. Select the dedicated system disk.
2. Configure the appropriate filesystem/storage layout.
3. Set the management network configuration.
4. Configure the node hostname.
5. Set the administrative credentials.
6. Complete the installation and reboot.

Use a sanitized naming convention in public examples:

```text
prox-lab-01.example.internal
prox-lab-02.example.internal
prox-lab-03.example.internal
```

Example management network:

```text
Network:    192.0.2.0/24
Gateway:    192.0.2.1
Node:       192.0.2.10
DNS:        192.0.2.53
```

`192.0.2.0/24` is used for documentation examples and does not represent the production or lab addressing scheme.

## 3. Management Networking

Proxmox normally creates a Linux bridge such as:

```text
vmbr0
```

The physical network interface is attached to the bridge, while the management IP is assigned to the bridge.

Conceptually:

```text
Physical NIC
     │
     ▼
   vmbr0
     │
     ├── Proxmox Management
     ├── VM
     ├── VM
     └── LXC
```

Review the configuration:

```bash
cat /etc/network/interfaces
```

Example:

```text
auto lo
iface lo inet loopback

iface eno1 inet manual

auto vmbr0
iface vmbr0 inet static
        address 192.0.2.10/24
        gateway 192.0.2.1
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
```

Validate addressing:

```bash
ip -br addr
```

Validate routing:

```bash
ip route
```

Test the gateway:

```bash
ping -c 4 192.0.2.1
```

Test DNS resolution:

```bash
getent hosts example.com
```

The Proxmox management interface should then be reachable at:

```text
https://192.0.2.10:8006
```

## 4. Repository and Updates

For a non-subscription lab deployment, configure the appropriate Proxmox VE no-subscription repository.

Repository configuration varies between Proxmox releases, so verify the repository configuration against the documentation for the installed version.

Update package metadata:

```bash
apt update
```

Apply available upgrades:

```bash
apt full-upgrade
```

Reboot when required:

```bash
reboot
```

After rebooting, verify the installed Proxmox version:

```bash
pveversion
```

Review kernel information:

```bash
uname -r
```

## 5. Administrative Account

The root account is retained for emergency or break-glass administration.

Normal administrative work should use a separate named account.

Create the account:

```bash
adduser <admin-user>
```

Install `sudo` if it is not already available:

```bash
apt install sudo
```

Add the account to the `sudo` group:

```bash
usermod -aG sudo <admin-user>
```

Verify:

```bash
groups <admin-user>
```

Test administrative access:

```bash
su - <admin-user>
sudo whoami
```

Expected result:

```text
root
```

### Proxmox Administrative Identity

When using PAM authentication, the corresponding Proxmox identity follows the format:

```text
<admin-user>@pam
```

Assign only the permissions required for the administrator's role.

The intended administrative model is:

```text
Named Administrator
        │
        ├── SSH / console administration
        ├── sudo elevation
        └── Proxmox PAM authentication

root@pam
        │
        └── Break-glass / emergency administration
```

## 6. Validate Storage

Review detected storage:

```bash
lsblk
```

Check filesystem utilization:

```bash
df -h
```

Review Proxmox storage configuration:

```bash
pvesm status
```

Typical deployments may include:

```text
local
local-lvm
```

Additional local storage may be configured depending on the hardware installed in the node.

The baseline does not require shared storage. Node-local storage can be used unless the architecture specifically requires shared storage, high availability, or storage-backed migration.

## 7. Join the Proxmox Cluster

Before joining the node, verify:

- Hostname is correct.
- Management IP is correct.
- DNS/name resolution works.
- System time is synchronized.
- Existing cluster nodes are reachable.
- The new node does not contain workloads that must be preserved.

Cluster creation and membership should be performed using the Proxmox cluster-management workflow.

After joining, verify cluster status:

```bash
pvecm status
```

Review nodes:

```bash
pvecm nodes
```

Expected architecture:

```text
             Proxmox Cluster
                    │
        ┌───────────┼───────────┐
        │           │           │
        ▼           ▼           ▼
 prox-lab-01   prox-lab-02   prox-lab-03
```

Verify that all expected nodes are visible and participating normally before deploying workloads.

## 8. Install Node Exporter

Node Exporter provides lightweight host telemetry to the centralized Prometheus monitoring environment.

It exposes Linux host metrics such as:

- CPU utilization
- Memory utilization
- Filesystem capacity
- Disk activity
- Network interfaces
- Load
- System uptime

Node Exporter should run directly on the Proxmox host rather than requiring a separate monitoring workload on each hypervisor.

### Create Service Account

Create a dedicated system account:

```bash
useradd \
  --system \
  --no-create-home \
  --shell /usr/sbin/nologin \
  node_exporter
```

### Install Node Exporter

> [!note]
> For more detailed notes see `docs/reference/monitoring/node-exporter-installation.md`.

Download the current supported Node Exporter release from the official Prometheus project.

Extract the archive and install the binary:

```bash
install -m 0755 node_exporter /usr/local/bin/node_exporter
```

Verify:

```bash
/usr/local/bin/node_exporter --version
```

### Create systemd Service

Create:

```text
/etc/systemd/system/node_exporter.service
```

Example:

```ini
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Reload systemd:

```bash
systemctl daemon-reload
```

Enable Node Exporter:

```bash
systemctl enable --now node_exporter
```

Verify:

```bash
systemctl status node_exporter
```

Node Exporter listens on TCP port:

```text
9100
```

Verify locally:

```bash
curl http://127.0.0.1:9100/metrics
```

A successful response should return Prometheus-formatted metrics.

## 9. Add the Node to Prometheus

> [!note] For detailed config examples see  `configs/docker/prometheus`.

The centralized Prometheus server scrapes Node Exporter rather than running Prometheus directly on the hypervisor.

Example sanitized configuration:

```yaml
scrape_configs:
  - job_name: "node-exporter-proxmox"

    static_configs:
      - targets:
          - "prox-lab-01.example.internal:9100"
          - "prox-lab-02.example.internal:9100"
          - "prox-lab-03.example.internal:9100"
```

Validate the Prometheus configuration before applying it:

```bash
promtool check config /path/to/prometheus.yml
```

Reload or restart Prometheus using the deployment's normal management procedure.

Verify the target in Prometheus:

```promql
up{job="node-exporter-proxmox"}
```

Each healthy Proxmox node should return:

```text
1
```

## 10. Baseline Validation

Before considering the node complete, verify the following:

| Check | Validation |
|---|---|
| Firmware reviewed | Vendor-supported firmware installed |
| Virtualization | CPU virtualization enabled |
| Management network | Static addressing and `vmbr0` operational |
| Gateway | Reachable |
| DNS | Resolution working |
| Proxmox UI | HTTPS/8006 reachable |
| Packages | System fully updated |
| Admin account | Named administrator operational |
| sudo | Administrative elevation verified |
| Storage | Expected local storage online |
| Cluster | Node visible and healthy |
| Node Exporter | Service active |
| Port 9100 | Metrics endpoint reachable |
| Prometheus | Node reports `up = 1` |
| Grafana | Host metrics visible |

## Baseline Scope

The baseline intentionally keeps the Proxmox host minimal.

The following are **not automatically installed or configured** as part of the baseline:

- Docker
- Prometheus server
- Grafana
- Loki
- Application services
- File-sharing services
- Desktop environments
- Development environments
- GPU/VFIO passthrough
- Additional management platforms

These capabilities should be introduced only when required by the node's role.

## Future Hardening

Potential future improvements include:

| Improvement |
|---|
| SSH key-based authentication |
| Restrict direct root SSH access |
| SSH password-authentication review |
| Host firewall policy |
| Administrative MFA |
| Automated configuration management |
| Centralized syslog forwarding |
| Configuration backup |
| Alerting for Node Exporter availability |

These controls are intentionally tracked separately from the minimum baseline so the lab can distinguish **required build configuration** from **future hardening and operational maturity**.

## Final Architecture

```text
                   Management Network
                           │
                           ▼
                  ┌─────────────────┐
                  │   Proxmox VE    │
                  │                 │
                  │  vmbr0          │
                  │  Local Storage  │
                  │  Node Exporter  │
                  └────────┬────────┘
                           │ :9100
                           ▼
                     Prometheus
                           │
                           ▼
                        Grafana
```

The resulting node provides a minimal virtualization platform with centralized administration and telemetry while keeping monitoring, applications, and supporting services outside the hypervisor itself.
