# rsyslog Forwarding

Reference guide for configuring a Debian-based Linux system to forward system logs to a centralized rsyslog collector.

## Scope

This reference applies to Debian-based Linux systems using systemd and rsyslog.

The example hostname used throughout this document is:

```text
prox-lab-01
```

All addresses and destination values are represented with documentation-safe placeholders and should be replaced with values appropriate for the environment.

## Overview

rsyslog can act as a forwarding client that sends locally generated system and service events to a centralized syslog collector.

```text
Linux Host
    │
    ├── systemd / services
    │
    ▼
systemd-journald
    │
    ▼
local rsyslog
    │
    │ TCP/514
    ▼
Central rsyslog Collector
```

The local rsyslog service receives system logging events and forwards them to the remote collector according to rules defined under `/etc/rsyslog.d/`.

This configuration uses TCP for forwarding and a disk-assisted queue to help preserve events when the remote collector is temporarily unavailable.

## Prerequisites

Before configuring forwarding:

- A centralized rsyslog collector must be available.
- TCP port 514 must be reachable from the source system to the collector.
- The source system must have administrative access through `sudo` or root.
- System time should be synchronized using NTP or another reliable time source.

## Check Whether rsyslog Is Installed

Check the package:

```bash
dpkg -l rsyslog
```

The service can also be checked directly:

```bash
systemctl status rsyslog --no-pager
```

If rsyslog is not installed:

```bash
sudo apt update
sudo apt install rsyslog
```

## Enable and Start rsyslog

Enable the service at boot and start it:

```bash
sudo systemctl enable --now rsyslog
```

Verify:

```bash
sudo systemctl status rsyslog --no-pager
```

Expected state:

```text
Active: active (running)
```

On a system using systemd-journald, rsyslog may report that it acquired the system journal syslog socket:

```text
imuxsock: Acquired UNIX socket '/run/systemd/journal/syslog'
```

This indicates that rsyslog is receiving messages through the local system logging path.

## Configure Remote Forwarding

Create a forwarding configuration:

```bash
sudo vi /etc/rsyslog.d/90-forward.conf
```

`90-forward.conf` is a descriptive filename rather than a required name. Files ending in `.conf` under `/etc/rsyslog.d/` are loaded by rsyslog when that directory is included by the main configuration.

The numeric prefix provides a predictable configuration load order.

Add:

```text
*.* action(
    type="omfwd"
    target="<collector-ip>"
    port="514"
    protocol="tcp"

    queue.type="LinkedList"
    queue.filename="fwd_queue"
    queue.saveOnShutdown="on"
    action.resumeRetryCount="-1"
)
```

Replace:

```text
<collector-ip>
```

with the address of the centralized syslog collector.

Do not commit real internal addresses to public documentation or repositories.

## Configuration Explanation

The selector:

```text
*.*
```

matches all syslog facilities and severity levels received by rsyslog.

The forwarding action:

```text
type="omfwd"
```

uses rsyslog's forwarding output module.

The destination:

```text
target="<collector-ip>"
port="514"
protocol="tcp"
```

sends events to the centralized collector over TCP port 514.

The queue configuration:

```text
queue.type="LinkedList"
queue.filename="fwd_queue"
queue.saveOnShutdown="on"
action.resumeRetryCount="-1"
```

provides buffering for the forwarding action and allows rsyslog to retry when the collector becomes unavailable.

The resulting path is:

```text
Local Events
     │
     ▼
  rsyslog
     │
     │ *.*
     ▼
   omfwd
     │
     │ TCP/514
     ▼
Central Collector
```

## Validate the Configuration

Always validate the rsyslog configuration before restarting the service:

```bash
sudo rsyslogd -N1
```

A successful validation ends with output similar to:

```text
rsyslogd: End of config validation run. Bye.
```

Resolve any reported configuration errors before restarting rsyslog.

## Restart rsyslog

After validation succeeds:

```bash
sudo systemctl restart rsyslog
```

Confirm that the service returned to the running state:

```bash
sudo systemctl status rsyslog --no-pager
```

The expected state is:

```text
Active: active (running)
```

## Test Collector Connectivity

Test TCP connectivity to the centralized collector:

```bash
nc -vz <collector-ip> 514
```

A successful connection confirms that the source system can establish a TCP connection to the collector.

This test validates network connectivity only. It does not verify that rsyslog is correctly processing or storing the message.

## Test Local Forwarding

Use `logger` to generate a test event through the local logging system:

```bash
logger -p local0.notice "SYSLOG TEST from $(hostname)"
```

For the example host, the resulting message contains:

```text
SYSLOG TEST from prox-lab-01
```

Because no remote destination is specified in the `logger` command, the message enters the local logging path first:

```text
logger
   │
   ▼
Local logging system
   │
   ▼
rsyslog
   │
   ▼
90-forward.conf
   │
   │ TCP/514
   ▼
Central Collector
```

This is the preferred test for validating the complete forwarding configuration.

## Test the Collector Directly

`logger` can also send a message directly to a remote syslog collector:

```bash
logger -n <collector-ip> -P 514 -T "DIRECT SYSLOG TEST from $(hostname)"
```

The options are:

| Option | Purpose |
|--------|---------|
| `-n` | Specifies the remote syslog server |
| `-P` | Specifies the destination port |
| `-T` | Uses TCP |

This produces a different test path:

```text
logger ──TCP/514──> Central Collector
```

Because this bypasses the local rsyslog forwarding configuration, it is useful for testing the collector and network path but does not validate `90-forward.conf`.

## Verify Forwarded Events

Verification should be performed on the centralized collector using the collector's configured storage location.

A successfully forwarded event should identify the source system and contain the generated test message.

Example:

```text
<timestamp> <source-address> <user>: SYSLOG TEST from prox-lab-01
```

The exact format depends on the template configured on the collector.

After the test succeeds, normal system and application events handled by rsyslog should also begin reaching the collector.

Examples may include events generated by:

- systemd
- SSH
- sudo
- kernel services
- installed applications
- infrastructure services

## Source Identity

The network source address and the hostname contained inside a syslog message are separate values.

A collector may therefore receive:

```text
Network source: <source-ip>
Message hostname: prox-lab-01
```

These values may differ depending on the source configuration, message format, DNS resolution, or collector configuration.

When troubleshooting source identification, distinguish between:

- Network sender address
- Syslog hostname field
- Application or service name
- Message contents

## Troubleshooting

When forwarding fails, validate the path in order:

```text
Local event generation
        │
        ▼
Local rsyslog service
        │
        ▼
Forwarding configuration
        │
        ▼
Network connectivity
        │
        ▼
Collector TCP/514
        │
        ▼
Collector rsyslog service
        │
        ▼
Collector routing / storage rule
```

### Check the Local Service

```bash
systemctl status rsyslog --no-pager
```

### Validate the Configuration

```bash
sudo rsyslogd -N1
```

### Review Local rsyslog Events

```bash
journalctl -u rsyslog
```

For recent events:

```bash
journalctl -u rsyslog -n 50 --no-pager
```

### Test Network Connectivity

```bash
nc -vz <collector-ip> 514
```

### Generate Another Test Event

```bash
logger -p local0.notice "SYSLOG FORWARDING TEST from $(hostname)"
```

### Check for Forwarding Errors

Forwarding failures may produce messages indicating that the remote server closed the connection or that the forwarding action was suspended.

For example:

```text
remote server closed connection
no working target servers in pool available
action suspended
```

When connectivity returns, rsyslog may report:

```text
action resumed
```

A brief suspend/resume sequence is expected if the central collector is intentionally restarted. Repeated connection failures during normal operation should be investigated.

## Collector Restart Behavior

When the central collector is restarted, existing TCP connections from forwarding clients are closed.

A forwarding client may temporarily report:

```text
Connection closed
      │
      ▼
Forwarding action suspended
      │
      ▼
Connection retried
      │
      ▼
Forwarding action resumed
```

With queueing configured, rsyslog can retain pending events while the forwarding action is unavailable and attempt delivery again when the collector becomes reachable.

## Validation Checklist

- [ ] rsyslog package installed
- [ ] rsyslog service enabled
- [ ] rsyslog service running
- [ ] Forwarding configuration created under `/etc/rsyslog.d/`
- [ ] Collector address configured
- [ ] TCP/514 reachable
- [ ] `rsyslogd -N1` validation successful
- [ ] rsyslog restarted successfully
- [ ] Local `logger` test generated
- [ ] Test event received by central collector
- [ ] Normal system/service events observed at collector

## Security Considerations

> [!note]
> The configuration in this guide uses plain syslog over TCP/514. TCP provides reliable transport but does not encrypt or authenticate syslog messages. UDP/514 is also unencrypted and unauthenticated and may be used for devices that do not support TCP.

For trusted internal networks:

- Restrict the collector port to expected source systems.
- Do not expose the syslog listener directly to the public Internet.
- Use firewall rules to limit access to the collector.
- Avoid placing credentials, secrets, or authentication material in test messages.
- Consider TLS-secured syslog where confidentiality or source authentication is required.

## Notes

Installing rsyslog does not mean every log or event generated by a Linux application is automatically forwarded.

The forwarding rule applies to messages received and processed by rsyslog. Applications that maintain independent log files or use separate logging mechanisms may require additional collection methods.

On platforms such as Proxmox VE, system and service events can be forwarded through this method, while platform-specific task histories or application-managed logs may use separate storage and logging mechanisms.
