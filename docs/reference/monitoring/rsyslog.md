# Centralized Syslog / rsyslog

## Overview

`rsyslog` provides centralized syslog collection for network infrastructure in the homelab.

The current deployment runs rsyslog as a Docker container on the monitoring server. Network devices send syslog messages to the collector, which stores them as persistent local log files.

The host uses `logrotate` to rotate and retain the raw logs. See the separate `logrotate` reference for configuration, retention, rotation testing, and troubleshooting.

Future integration will use Grafana Alloy to forward collected logs to Loki for searching, visualization, and alerting in Grafana.


## Quick Reference

| Task | Command |
|---|---|
| Validate configuration | `docker exec rsyslog rsyslogd -N1` |
| Validate specific config | `docker exec rsyslog rsyslogd -N1 -f /etc/rsyslog.conf` |
| Show rsyslog version | `docker exec rsyslog rsyslogd -v` |
| Show rsyslog help | `docker exec rsyslog rsyslogd -h` |
| View container logs | `docker logs rsyslog` |
| Follow container logs | `docker logs -f rsyslog` |
| Restart rsyslog | `docker compose restart rsyslog` |
| Check syslog listeners | `sudo ss -lntup \| grep ':514'` |
| Follow collected logs | `tail -f /opt/docker/rsyslog/logs/router.log` |
| Send Linux test message | `logger --server <SYSLOG-SERVER-IP> --port 514 --udp "SYSLOG TEST"` |



## Architecture

Current:

    Network Devices
          │
          │ Syslog UDP/TCP 514
          ▼
       rsyslog
          │
          ▼
      Local Logs
          │
          ▼
      logrotate

Planned:

    Network Devices
          │
          ▼
       rsyslog
          │
          ├──────────────► logrotate
          │                  │
          │                  └── Local Archive
          │
          ▼
    Grafana Alloy
          │
          ▼
         Loki
          │
          ▼
       Grafana


## Directory Structure

rsyslog is deployed under:

    /opt/docker/rsyslog/

Directory structure:

    /opt/docker/rsyslog/
    ├── docker-compose.yaml
    ├── config/
    │   └── rsyslog.conf
    └── logs/
        └── router.log

The configuration and log directories are bind-mounted into the container.


## Docker Compose

> [!note]
> This is a static example. For the most updated config used in the homelab, reference `/configs/docker/rsyslog`.

File:

    /opt/docker/rsyslog/docker-compose.yaml

Configuration:

    services:
      rsyslog:
        image: rsyslog/rsyslog:2026-04
        container_name: rsyslog
        restart: unless-stopped

        ports:
          - "514:514/udp"
          - "514:514/tcp"

        volumes:
          - ./config/rsyslog.conf:/etc/rsyslog.conf:ro
          - ./logs:/var/log/remote

        networks:
          - monitoring

    networks:
      monitoring:
        external: true

The container joins the existing external Docker network:

    monitoring

Both UDP and TCP port `514` are exposed.

Most network appliances use UDP/514 for standard remote syslog.


## rsyslog Configuration

File:

    /opt/docker/rsyslog/config/rsyslog.conf

Example configuration:

    module(load="imudp")
    input(type="imudp" port="514")

    module(load="imtcp")
    input(type="imtcp" port="514")

    template(name="RemoteFormat" type="string"
             string="%timegenerated% %fromhost-ip% %syslogtag%%msg%\n")

    if ($fromhost-ip == "<ROUTER-IP>") then {
        action(
            type="omfile"
            file="/var/log/remote/router.log"
            template="RemoteFormat"
        )
        stop
    }

Replace:

    <ROUTER-IP>

with the internal management IP of the device sending syslog.

The `stop` statement prevents matching messages from continuing through additional rsyslog rules.


## Log Format

The custom format is:

    %timegenerated% %fromhost-ip% %syslogtag%%msg%

Example:

    Sep 25 16:51:54 <ROUTER-IP> kernel: DROP IN=<WAN-INTERFACE> ...

This records:

- Timestamp
- Source IP
- Syslog tag/process
- Original message

Including the source IP is useful when multiple devices send logs to the same collector.


## Network Device Configuration

Configure the network device to send remote syslog to:

    Destination: <SYSLOG-SERVER-IP>
    Protocol:    UDP
    Port:        514

TCP/514 is also available if supported and desired.

Remote syslog is particularly useful for routers, switches, firewalls, and other appliances because locally buffered logs can disappear after a reboot or failure.


## Container Permissions

The rsyslog container runs under its own internal UID/GID.

Check it with:

    docker exec rsyslog id

Example:

    uid=101(syslog) gid=4(adm) groups=4(adm)

The host log directory must therefore be writable by the account used inside the container.

Check:

    ls -ld /opt/docker/rsyslog/logs

If the container uses UID `101` and GID `4`:

    sudo chown 101:4 /opt/docker/rsyslog/logs

Verify:

    ls -ld /opt/docker/rsyslog/logs

A permission problem may appear in the container logs as:

    file '/var/log/remote/router.log': open error: Permission denied

Test write access:

    docker exec rsyslog sh -c 'touch /var/log/remote/test.log'

Remove the test file afterward:

    sudo rm /opt/docker/rsyslog/logs/test.log


## Starting the Service

Change to the deployment directory:

    cd /opt/docker/rsyslog

Start:

    docker compose up -d

Check status:

    docker compose ps

View startup logs:

    docker logs rsyslog

Restart:

    docker compose restart rsyslog


## Validate rsyslog Configuration

Validate the configuration before or after making changes:

    docker exec rsyslog rsyslogd -N1

Successful validation should end with:

    End of config validation run. Bye.

After modifying `rsyslog.conf`:

    cd /opt/docker/rsyslog
    docker compose restart rsyslog


## Verify Port 514

On the Docker host:

    sudo ss -lntup | grep ':514'

Expected listeners include:

    0.0.0.0:514 UDP
    0.0.0.0:514 TCP

IPv6 listeners may also appear.


## Testing Syslog

### Linux Client

From another Linux system:

    logger --server <SYSLOG-SERVER-IP> \
           --port 514 \
           --udp \
           "remote syslog test"

If source-IP filtering is enabled, messages from the test machine will not appear in a device-specific log unless a rule exists for that source.

### Container Test

A basic local test can also be sent from inside the container:

    docker exec rsyslog logger \
        -n 127.0.0.1 \
        -P 514 \
        -d \
        "RSYSLOG INTERNAL TEST"

Source-IP filtering still determines whether the test message is written to a particular output file.

### macOS Note

The macOS `logger` utility differs from GNU/Linux `logger` and does not support all of the same network options.

Using another Linux host is generally easier for remote syslog testing.


## Log Rotation

Remote syslog files are rotated by the host using `logrotate`.

The current policy provides:

- Daily rotation
- Date-based filenames
- Compression of historical logs
- 90 rotations of local retention
- `copytruncate` compatibility with the containerized rsyslog deployment

> [!note]
> See the separate `logrotate` reference for the complete configuration, rotation policy, testing procedures, automatic scheduling, and troubleshooting.


## Reading Logs

Follow the active log:

    tail -f /opt/docker/rsyslog/logs/router.log

Read the active log:

    cat /opt/docker/rsyslog/logs/router.log

Search the active log:

    grep -i "wan" /opt/docker/rsyslog/logs/router.log

Search for common infrastructure events:

    grep -Ei "wan|link|reboot|boot|watchdog|error|fail" \
        /opt/docker/rsyslog/logs/router.log

> [!note]
> See the separate `logrotate` reference for reading and searching rotated or compressed historical logs.


## Firewall DROP Messages

Routers and firewalls commonly generate messages similar to:

    kernel: DROP IN=<WAN-INTERFACE> ... SRC=<EXTERNAL-IP> ... PROTO=TCP ...

These generally represent unsolicited traffic arriving on the WAN interface and being blocked by the firewall.

Internet-facing addresses routinely receive automated scanning and connection attempts.

A firewall `DROP` entry alone does not indicate a router failure or targeted attack.

Centralized logging makes these messages useful when correlating them with:

- WAN outages
- Router restarts
- Interface changes
- DHCP events
- Authentication events
- Wireless problems
- Firewall events
- Service failures


## Adding Additional Devices

Multiple network devices can send syslog to the same collector:

    Router ───────────┐
                      │
    Switch ───────────┼──► Syslog Collector :514
                      │
    Firewall ─────────┤
                      │
    Other Devices ────┘

Each device can have a separate output rule.

Example:

    if ($fromhost-ip == "<ROUTER-IP>") then {
        action(
            type="omfile"
            file="/var/log/remote/router.log"
            template="RemoteFormat"
        )
        stop
    }

    if ($fromhost-ip == "<SWITCH-IP>") then {
        action(
            type="omfile"
            file="/var/log/remote/switch.log"
            template="RemoteFormat"
        )
        stop
    }


### Dynamic Per-Host Logs

For a larger number of devices, rsyslog can dynamically generate files based on source IP.

Example:

    template(
        name="RemoteHostFile"
        type="string"
        string="/var/log/remote/%fromhost-ip%.log"
    )

    *.* action(
        type="omfile"
        dynaFile="RemoteHostFile"
        template="RemoteFormat"
    )

This produces files similar to:

    <DEVICE-IP-1>.log
    <DEVICE-IP-2>.log
    <DEVICE-IP-3>.log

Explicit rules are easier to read for a small number of infrastructure devices, while dynamic files scale better when many devices are sending syslog.


## Planned Alloy / Loki Integration

Local rsyslog files provide a simple raw-log archive.

The planned centralized logging path is:

    Network Devices
          │
          ▼
       rsyslog
          │
          ▼
      Active Logs
          │
          ├────────────► logrotate
          │                 │
          │                 └── Local Raw Archive
          │
          ▼
    Grafana Alloy
          │
          ▼
         Loki
          │
          ▼
       Grafana

Alloy will collect active rsyslog output and forward it to Loki.

The local files remain available as a raw-log archive, while Loki provides centralized storage and querying.

Potential Loki labels include:

    job=syslog
    host=router
    device_type=router

Additional devices could use labels such as:

    job=syslog host=core-switch device_type=switch
    job=syslog host=firewall device_type=firewall

This allows logs from multiple infrastructure devices to be queried through one centralized logging platform.

> [!note]
> Alloy and Loki deployment and configuration should be maintained in their respective reference documents.


## Operational Commands

Check the container:

    docker ps --filter name=rsyslog

Follow container output:

    docker logs -f rsyslog

Validate configuration:

    docker exec rsyslog rsyslogd -N1

Check listeners:

    sudo ss -lntup | grep ':514'

Follow collected logs:

    tail -f /opt/docker/rsyslog/logs/router.log

Check ownership and file sizes:

    ls -lash /opt/docker/rsyslog/logs/

Restart the collector:

    cd /opt/docker/rsyslog
    docker compose restart rsyslog


## Troubleshooting

### No Log File Created

Check container logs:

    docker logs rsyslog

Check directory ownership:

    ls -ld /opt/docker/rsyslog/logs

Check container identity:

    docker exec rsyslog id

Test write access:

    docker exec rsyslog sh -c 'touch /var/log/remote/write-test'


### No Remote Messages Arriving

Verify listeners:

    sudo ss -lntup | grep ':514'

Verify the network device is configured with:

    Destination: <SYSLOG-SERVER-IP>
    Port:        514
    Protocol:    UDP or TCP

Check the active log:

    tail -f /opt/docker/rsyslog/logs/router.log

If source-IP filtering is configured, verify the source IP in `rsyslog.conf` matches the device.


### Configuration Changes Not Working

Validate:

    docker exec rsyslog rsyslogd -N1

Then restart:

    cd /opt/docker/rsyslog
    docker compose restart rsyslog

Check:

    docker logs rsyslog

For issues involving log rotation, retention, compression, or rotated files, see the separate `logrotate` reference.


## Current Deployment Status

The rsyslog deployment has been validated for:

    ✓ rsyslog Docker deployment
    ✓ Configuration validation
    ✓ UDP/514 listener
    ✓ TCP/514 listener
    ✓ Remote syslog reception
    ✓ Source-IP filtering
    ✓ Persistent bind-mounted storage
    ✓ Container UID/GID permissions
    ✓ Continued logging during host-managed rotation

The centralized syslog collector is operational.
