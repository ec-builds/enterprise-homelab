# AdGuard Home Native Installation

## Overview

How to install AdGuard Home natively on a dedicated Debian VM, configure it as a filtering forwarder behind Active Directory DNS, and run it day to day. This is how `adguard-lab-01` and `adguard-lab-02` were built. The design and the reasons for it are in [DNS Filtering with AdGuard Home](../../../projects/network-infrastructure/04-dns-filtering-adguard-home.md).

> [!NOTE]
> The official [AdGuard Home documentation](https://github.com/AdguardTeam/AdGuardHome/wiki) is the authoritative source for installation and upgrades.

Examples use `adguard-lab-01` at `10.0.0.20` and `adguard-lab-02` at `10.0.0.21`, with the DCs at `10.0.0.10` and `10.0.0.11`.

## Prerequisites

1. Build a Debian VM using the [Debian Baseline](../debian/debian-baseline.md). Each instance in the lab has 2 vCPU and 3 GB RAM, and the two run on different Proxmox hosts.
2. Give it a static IP with [Debian Static IP Configuration](../debian/debian-static-ip-configuration.md), and set the hostname with [Debian Hostname Change](../debian/debian-hostname-change.md).
3. Make sure nothing else is listening on port 53:

```bash
sudo ss -tulpn | grep ':53 '
```

No output means the port is free. A stock Debian install doesn't run `systemd-resolved`. If it shows up here, disable its stub listener before going on.

## Install

Run AdGuard's official install script:

```bash
curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
```

The script asks for `sudo` when needed. It downloads the latest release into `/opt/AdGuardHome`, installs `AdGuardHome.service`, and starts it. `-v` shows each step.

Check the service:

```bash
systemctl status AdGuardHome
```

It should be `active (running)`, running `/opt/AdGuardHome/AdGuardHome -s run`.

| Path | Contents |
|---|---|
| `/opt/AdGuardHome/AdGuardHome` | The program |
| `/opt/AdGuardHome/AdGuardHome.yaml` | All settings, including the admin password hash |
| `/opt/AdGuardHome/data/` | Filters, query log, statistics and sessions |

## First-Run Setup

Open `http://10.0.0.20:3000` and work through the setup wizard:

| Step | Setting |
|---|---|
| Admin web interface | Listen on the VM's IP (`10.0.0.20`), port `80` |
| DNS server | Listen on the VM's IP (`10.0.0.20`), port `53` |
| Admin account | Create the admin user. Store the password outside the repository |

Binding to the VM's own IP instead of all interfaces keeps AdGuard off any other interface. After the wizard, the web interface is at `http://10.0.0.20`.

## Configure

### DNS Settings

Under **Settings → DNS settings**:

| Setting | Value |
|---|---|
| Upstream DNS servers | `https://cloudflare-dns.com/dns-query` and `https://dns.google/dns-query` |
| Upstream mode | Load-balancing |
| Fallback DNS servers | Leave empty |
| Bootstrap DNS servers | `1.1.1.1` and `8.8.8.8` |
| Private reverse DNS servers | `10.0.0.10:53` and `10.0.0.11:53` |
| Use private reverse DNS resolvers | On |
| Enable reverse resolving of clients' IP addresses | On |
| Rate limit | `0`. All queries come from the two DCs, so any per-subnet limit applies to the whole network |
| DNSSEC | On |

Click **Test upstreams** before **Apply**.

### Blocklists

Under **Filters → DNS blocklists → Add blocklist → Choose from the list**, add:

- AdGuard DNS filter
- HaGeZi's Pro Blocklist
- Phishing URL Blocklist (PhishTank and OpenPhish)
- HaGeZi's Threat Intelligence Feeds
- Malicious URL Blocklist (URLhaus)

HaGeZi's Threat Intelligence Feeds has about 1.1 million rules and accounts for most of the memory use, so 3 GB of RAM is a sensible minimum. Stay at the Pro level on a shared household network: Pro++ and Ultimate block more but cause more false positives.

Under **Settings → General settings**, turn on **Use AdGuard browsing security web service**.

### Second Instance

Repeat every step on `adguard-lab-02` with its own IP. The two instances don't sync, so each setting change has to be made on both.

To compare their settings, ignoring the lines that are supposed to differ:

```bash
sudo grep -v -E 'password|address:|bind_hosts|- 10\.' /opt/AdGuardHome/AdGuardHome.yaml | sha256sum
```

Run it on both VMs. If the hashes match, the settings match.

## Point the DCs at AdGuard

On each domain controller, in an elevated PowerShell:

```powershell
Set-DnsServerForwarder -IPAddress 10.0.0.20, 10.0.0.21
Get-DnsServerForwarder
```

Windows DNS tries forwarders in order, so list them in the opposite order on the second DC if you want to split the load.

Create reverse lookup zones for every private subnet whose clients can reach AD DNS. Without them, PTR lookups for those subnets loop between the DCs and AdGuard until they time out:

```powershell
Add-DnsServerPrimaryZone -NetworkId "10.0.0.0/24" -ReplicationScope Domain
Add-DnsServerPrimaryZone -Name "8.e.f.ip6.arpa" -ReplicationScope Domain
```

Add one `-NetworkId` zone per subnet, including VPN and guest networks.

## Verify

From any machine on the LAN:

```bash
dig @10.0.0.20 example.com +short      # returns an address
dig @10.0.0.20 doubleclick.net +short  # returns 0.0.0.0 (blocked)
dig @10.0.0.10 example.com +short      # through a DC, returns an address
```

Repeat against `10.0.0.21`. Then take each instance offline in turn and confirm `dig @10.0.0.10 example.com` still answers.

## Operate

| Task | Command |
|---|---|
| Service status | `systemctl status AdGuardHome` |
| Restart | `sudo systemctl restart AdGuardHome` |
| Recent log | `journalctl -u AdGuardHome -n 50 --no-pager -o cat` |
| Version | `/opt/AdGuardHome/AdGuardHome --version` |

### Troubleshooting Failed Lookups

```bash
# Failed lookups by question
journalctl -u AdGuardHome --since "7 days ago" -o cat | grep 'exchange failed' \
  | grep -o 'question="[^"]*' | sort | uniq -c | sort -rn | head -20

# Failed upstream lookups per day and per upstream
journalctl -u AdGuardHome --since "7 days ago" -o cat | grep 'exchange failed' \
  | grep -v 'arpa' | cut -c1-10 | uniq -c
journalctl -u AdGuardHome --since "7 days ago" -o cat | grep 'exchange failed' \
  | grep -v 'arpa' | grep -o 'upstream=[^ ]*' | sort | uniq -c
```

| What you see | Likely cause |
|---|---|
| `in-addr.arpa` or `ip6.arpa` PTR timeouts against the DCs | A subnet with no reverse zone on the DCs |
| Both upstreams failing on both instances at the same time | The internet connection, not AdGuard |
| Only one upstream failing | That provider |

## Back Up

`AdGuardHome.yaml` holds every setting. Back it up after any change:

```bash
sudo cp /opt/AdGuardHome/AdGuardHome.yaml ~/AdGuardHome.yaml.$(date +%F)
```

It contains the admin password hash, so keep copies out of the repository. The `data/` folder holds the query log and statistics, which don't need backing up.

## Update

See [AdGuard Home Upgrade](./adguard-home-upgrade.md) for the backup, upgrade, verification and rollback steps.

## Uninstall

```bash
curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -u
```

## Related Documentation

- [AdGuard Home Upgrade](./adguard-home-upgrade.md)
- [DNS Filtering with AdGuard Home](../../../projects/network-infrastructure/04-dns-filtering-adguard-home.md)
- [Debian Baseline](../debian/debian-baseline.md)
- [Windows Server DNS Validation](../windows/windows-server-DNS-validation.md)
