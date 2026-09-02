# 🔐 SSH Authentication & Hardening

**Status: ⚪ Planned**

SSH will provide secure administrative access to Linux systems throughout the homelab.

The planned standard is **Ed25519 public-key authentication** using a named administrative account, with password-based and direct root SSH access disabled after key authentication is validated.

## Authentication Standard

The homelab will standardize on:

- **Ed25519** SSH key pairs
- Passphrase-protected private keys
- Named administrative accounts
- `sudo` for privilege elevation
- Public-key authentication
- Password authentication disabled
- Direct root SSH login disabled
- Private keys retained only on trusted administrative devices

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
| **Homelab Standard** | Compatibility / legacy use | ✅ **Default** |

RSA remains a secure option when appropriately configured. RSA-2048 and stronger keys continue to be usable with modern SSH implementations.

One historical concern is the legacy `ssh-rsa` signature algorithm, which uses SHA-1. Modern SSH implementations can instead use RSA keys with SHA-2 signature algorithms such as `rsa-sha2-256` and `rsa-sha2-512`.

Ed25519 provides a simpler modern default with small keys, strong security, good performance, and fewer configuration decisions.

## Previous Experience

Previous aerospace administration experience used **RSA-4096** SSH keys as the standard for key-based authentication.

RSA-4096 remains a strong authentication method and that implementation was appropriate for the environment in which it was used.

The homelab will transition to **Ed25519** to gain hands-on experience with a newer SSH authentication algorithm and establish a modern standard for newly deployed systems.

> [!NOTE]
> The move from RSA-4096 to Ed25519 is a modernization and learning decision rather than a response to RSA-4096 being considered insecure.

## Planned Architecture

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

After public-key authentication has been successfully tested, the planned SSH baseline includes:

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

Password authentication should not be disabled until key-based access has been validated to prevent administrative lockout.

## Ansible Integration

SSH configuration will eventually be incorporated into the Ansible Linux baseline.

Ansible may be used to:

- Create the administrative account
- Deploy authorized public keys
- Configure `sudo`
- Apply SSH security settings
- Disable password authentication
- Disable direct root SSH access
- Validate consistent configuration across managed systems

This allows the same SSH baseline to be applied consistently as additional Linux servers are deployed.

## Remote Access

SSH services should not be exposed directly to the Internet.

Remote administration will occur through trusted internal networks or the homelab VPN, providing an additional network security boundary before SSH authentication occurs.

```text
Internet
    │
    ▼
WireGuard VPN
    │
    ▼
Trusted / Management Network
    │
    ▼
SSH
    │
    ▼
Linux Servers
```

## Future Enhancements

Additional SSH security controls may be evaluated as the lab develops, including:

- FIDO2 hardware-backed SSH keys
- Dedicated management VLAN
- SSH access restrictions through firewall policy
- Centralized logging and authentication monitoring
- Automated SSH key lifecycle management

> [!NOTE]
> **Homelab SSH standard: Ed25519 key + passphrase → named administrator → public-key authentication → `sudo` → password and direct root SSH access disabled.**
