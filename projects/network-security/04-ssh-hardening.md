# 🔐 SSH Authentication & Hardening

**Status: 🟡 Operational — Hardening in Progress**

SSH is currently used for administrative access to Linux systems throughout the homelab.

The current environment provides SSH access from trusted networks and through the WireGuard VPN. The next phase will strengthen authentication using **Ed25519 public-key authentication** and progressively restrict which administrative devices are permitted to access specific systems.

## Current State

SSH is actively used to administer Linux infrastructure and services.

Current access follows this general model:

```text
Administrative Device
        │
        ├── Trusted Internal Network
        │
        └── WireGuard VPN
                │
                ▼
               SSH
                │
                ▼
          Linux Systems
```

SSH services are not intentionally exposed directly to the Internet. Remote administration is performed through the WireGuard VPN before connecting to internal SSH services.

The current implementation provides functional administrative access, while additional authentication and network-level restrictions remain in progress.

## Target Authentication Standard

The homelab will standardize on:

- **Ed25519** SSH key pairs
- Passphrase-protected private keys
- Named administrative accounts
- `sudo` for privilege elevation
- Public-key authentication
- Password authentication disabled after key authentication is validated
- Direct root SSH login disabled
- Private keys retained only on trusted administrative devices

The goal is to reduce reliance on passwords while maintaining a recoverable migration path during deployment.

## RSA vs. Ed25519

| | RSA | Ed25519 |
|---|---|---|
| **Introduced** | 1977 | 2011 |
| **Cryptography** | RSA public-key cryptography | Edwards-curve digital signatures |
| **Typical SSH Key** | 2048–4096 bits | Fixed Ed25519 parameters |
| **Key Size** | Larger | Small |
| **Performance** | Good | Fast |
| **Legacy Compatibility** | Excellent | Excellent on modern systems |
| **Configuration** | Key size and compatibility considerations | Minimal configuration |
| **Homelab Standard** | Compatibility / legacy use | ✅ **Target Default** |

RSA remains a secure option when appropriately configured. RSA-2048 and stronger keys continue to be usable with modern SSH implementations.

One historical concern is the legacy `ssh-rsa` signature algorithm, which uses SHA-1. Modern SSH implementations can instead use RSA keys with SHA-2 signature algorithms such as `rsa-sha2-256` and `rsa-sha2-512`.

Ed25519 provides a simpler modern default with small keys, strong security, good performance, and fewer configuration decisions.

## Previous Experience

Previous aerospace administration experience used **RSA-4096** SSH keys as the standard for key-based authentication.

RSA-4096 remains a strong authentication method and that implementation was appropriate for the environment in which it was used.

The homelab will transition to **Ed25519** to gain hands-on experience with a newer SSH authentication algorithm and establish a modern standard for newly deployed systems.

> [!NOTE]
> The move from RSA-4096 to Ed25519 is a modernization and learning decision rather than a response to RSA-4096 being considered insecure.

## Target Authentication Architecture

```text
Administrative Workstation
          │
          │ Ed25519 Private Key
          │ + Passphrase
          │
          ▼
       SSH Client
          │
          │ Public-Key Authentication
          ▼
      Linux Server
          │
          ├── Named Admin Account
          ├── Authorized Public Key
          └── sudo
                 │
                 ▼
          Root Privileges
```

The private key remains on the administrative workstation. Managed servers receive only the corresponding public key.

## Key Generation

A new administrative Ed25519 key can be generated with:

```bash
ssh-keygen -t ed25519
```

The private key should be protected with a strong passphrase.

Typical key files:

```text
~/.ssh/id_ed25519       # Private key — never distribute
~/.ssh/id_ed25519.pub   # Public key — deploy to servers
```

## Server Hardening

After public-key authentication has been successfully tested, the target SSH baseline includes:

```text
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin no
```

Administrative access will follow the model:

```text
SSH as named administrator
          │
          ▼
Public-key authentication
          │
          ▼
Standard user session
          │
          ▼
sudo when required
```

Password authentication will not be disabled until key-based authentication has been validated to prevent administrative lockout.

## Access Control

Authentication determines **who can authenticate**, while network controls will determine **which devices can reach SSH services**.

The current trusted network does not yet provide this level of wired segmentation.

The planned VLAN and firewall architecture will allow SSH access to be restricted based on network source and destination.

```text
Administrative Device
        │
        ▼
 Management Network
        │
        ▼
   Firewall Policy
        │
        ├── Allowed ──► Authorized Server
        │
        └── Denied  ──► Unauthorized Systems
```

This will allow administrative access to follow a least-privilege model rather than allowing every trusted device to reach every SSH-enabled system.

Examples of future controls include:

- Permit SSH from designated administrative devices or management networks
- Restrict SSH access to systems that require remote administration
- Prevent guest and IoT networks from reaching SSH services
- Control VPN-to-SSH access through firewall policy
- Log denied and permitted administrative connections where practical

## Ansible Integration

SSH configuration will eventually be incorporated into the Ansible Linux baseline.

Ansible may be used to:

- Create named administrative accounts
- Deploy authorized public keys
- Configure `sudo`
- Apply SSH security settings
- Disable password authentication
- Disable direct root SSH access
- Validate consistent configuration across managed systems

This will allow the same SSH baseline to be applied consistently as additional Linux servers are deployed.

## Remote Access

SSH services will not be intentionally exposed directly to the Internet.

Remote administration follows the existing VPN architecture:

```text
Internet
    │
    ▼
WireGuard VPN
    │
    ▼
Trusted Network
    │
    ▼
SSH
    │
    ▼
Linux Systems
```

The future segmented architecture will further restrict VPN-connected devices to only the systems and services they are authorized to access.

## Hardening Roadmap

- [x] Deploy SSH for Linux administration
- [x] Restrict remote administration to trusted networks or WireGuard VPN
- [ ] Generate dedicated Ed25519 administrative key pair
- [ ] Deploy public keys to managed Linux systems
- [ ] Validate key-based authentication
- [ ] Disable password-based SSH authentication
- [ ] Disable direct root SSH login
- [ ] Restrict SSH access by source network and destination system
- [ ] Integrate SSH restrictions with management VLAN and firewall policies
- [ ] Automate the SSH baseline with Ansible
- [ ] Centralize SSH authentication and security logging
- [ ] Evaluate hardware-backed SSH authentication

## Future Enhancements

Additional SSH security controls may be evaluated as the lab develops, including:

- FIDO2 hardware-backed SSH keys
- Dedicated management VLAN
- Per-system firewall restrictions
- Centralized authentication monitoring
- Automated SSH key lifecycle management
- Administrative access auditing

> [!NOTE]
> **Target homelab SSH standard: trusted administrative device → authorized network path → Ed25519 key + passphrase → named administrator → public-key authentication → `sudo` → password and direct root SSH access disabled.**