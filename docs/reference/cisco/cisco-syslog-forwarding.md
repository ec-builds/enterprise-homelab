# Cisco IOS Remote Syslog Forwarding

Reference guide for forwarding Cisco IOS system logs to a centralized rsyslog collector.

## Overview

Cisco IOS includes native syslog functionality and does not require an additional logging agent.

The switch generates system events locally and forwards configured severity levels to a remote syslog collector.

```text
Cisco IOS Switch
      │
      │ Syslog UDP/514
      ▼
Central rsyslog Collector
      │
      ▼
Central Log Storage
```

This guide uses **UDP/514** for compatibility with older Cisco IOS platforms.

## Prerequisites

Before configuring the switch:

- Central rsyslog collector is operational
- Collector is listening on UDP/514
- Network connectivity exists between the switch and collector
- A destination rule exists on the collector for the switch
- Administrative access to the Cisco switch is available

Example collector destination:

```text
<collector-ip>
```

## Review Existing Logging Configuration

Connect to the switch and inspect the current logging configuration:

```text
show running-config | include logging
show logging
```

`show logging` displays:

- Whether syslog is enabled
- Console logging level
- Monitor logging level
- Buffer logging level
- Trap logging level
- Configured remote logging destinations
- Local log buffer

A typical switch may already have local logging enabled even when no remote syslog server has been configured.

## Configure Remote Syslog

Enter global configuration mode:

```text
enable
configure terminal
```

Configure the central collector:

```text
logging host <collector-ip>
logging trap informational
logging on
```

Exit configuration mode:

```text
end
```

### Logging Severity

`informational` sends severity 6 and all more-severe messages.

| Severity | Name |
|---:|---|
| 0 | Emergency |
| 1 | Alert |
| 2 | Critical |
| 3 | Error |
| 4 | Warning |
| 5 | Notification |
| 6 | Informational |
| 7 | Debugging |

For general infrastructure monitoring, `informational` provides useful operational events without enabling full debugging output.

## Verify Remote Logging

Run:

```text
show logging
```

The remote collector should appear under trap logging.

Example:

```text
Trap logging: level informational
    Logging to <collector-ip> (udp port 514, link up)
```

The message counters provide additional confirmation that messages are being sent.

## Configure Local Timestamps

The switch system clock and the timestamps embedded in syslog messages can be formatted differently.

Check the switch clock:

```text
show clock detail
```

Verify that the correct timezone and NTP source are shown.

Example:

```text
18:16:47 PDT Fri Sep 25 2026
Time source is NTP
```

Check the timestamp configuration:

```text
show running-config | include service timestamps
```

Without `localtime`, IOS may place UTC timestamps inside syslog messages even though `show clock` displays local time.

Configure log and debug timestamps to use local time:

```text
configure terminal
service timestamps debug datetime msec localtime
service timestamps log datetime msec localtime
end
```

Verify:

```text
show running-config | include service timestamps
```

Expected configuration:

```text
service timestamps debug datetime msec localtime
service timestamps log datetime msec localtime
```

## Generate a Test Event

A normal configuration change can be used to generate a syslog event.

For example:

```text
configure terminal
interface GigabitEthernet0/8
description SYSLOG-TEST
end
```

Remove the temporary change afterward:

```text
configure terminal
interface GigabitEthernet0/8
no description
end
```

IOS should generate a configuration event similar to:

```text
%SYS-5-CONFIG_I
```

Other normal events such as interface state changes and administrative activity can also generate syslog messages.

## Validate Network Delivery

On the syslog collector, capture incoming Cisco syslog traffic:

```bash
sudo tcpdump -nn -i <interface> src host <switch-ip> and udp port 514
```

For example, using the collector's primary Ethernet interface prevents Docker bridge interfaces from showing the same packet multiple times.

To inspect the syslog payload:

```bash
sudo tcpdump -nn -A -i <interface> src host <switch-ip> and udp port 514
```

A successful packet should resemble:

```text
<switch-ip>.<source-port> > <collector-ip>.514: SYSLOG local7.notice
```

This confirms:

```text
Cisco Switch
     │
     │ UDP/514
     ▼
Collector Network Interface
```

## Docker-Based Collector Validation

When rsyslog runs inside Docker, a packet may traverse several interfaces:

```text
Cisco Switch
      │
      ▼
Physical Interface
      │
      ▼
Docker Port Publishing
      │
      ▼
Docker Bridge
      │
      ▼
Container veth
      │
      ▼
rsyslog Container
```

Running:

```bash
sudo tcpdump -nn -i any udp port 514
```

may therefore display the **same syslog datagram multiple times**.

For example:

```text
Physical NIC In
Docker bridge Out
Container veth Out
```

These are not necessarily separate syslog messages.

For cleaner validation, capture only the physical interface and Cisco source:

```bash
sudo tcpdump -nn -i <interface> src host <switch-ip> and udp port 514
```

## Validate Central Log Storage

On the collector, monitor the Cisco destination file:

```bash
tail -f /path/to/remote/cisco.log
```

A successfully received Cisco message may resemble:

```text
Sep 25 18:19:55 <switch-ip> 492: Sep 25 18:19:54.703: %SYS-5-CONFIG_I: ...
```

Two timestamps are expected when the collector template records receipt time while the Cisco payload also contains its own event timestamp.

```text
Collector Timestamp                     Cisco Event Timestamp
       │                                         │
       ▼                                         ▼
Sep 25 18:19:55 <switch-ip> 492: Sep 25 18:19:54.703: %SYS-5-CONFIG_I
```

The timestamps represent different stages:

- **Collector timestamp** — when rsyslog received the message
- **Cisco timestamp** — when the switch generated the event

Keeping both in raw logs can help identify forwarding delays or interruptions.

## Collector Troubleshooting

If Cisco reports that messages are being sent but nothing appears in the destination log, validate the pipeline in order:

```text
Cisco IOS
    │
    │ UDP/514
    ▼
Collector NIC
    │
    ▼
Docker Port Mapping
    │
    ▼
rsyslog
    │
    ▼
Cisco Log File
```

### No Packets in tcpdump

Check:

- Collector address
- Switch network connectivity
- UDP/514 filtering
- Cisco `logging host` configuration
- Trap logging configuration

Review:

```text
show logging
show running-config | include logging
```

### Packets Arrive but No Log File Entries

Check the central rsyslog configuration.

Validate the container configuration:

```bash
docker exec rsyslog rsyslogd -N1
```

Confirm that the collector rule matches the switch source address and appears before any catch-all rule that stops further processing.

Example:

```conf
# Cisco Switch
if ($fromhost-ip == "<switch-ip>") then {
    action(
        type="omfile"
        file="/var/log/remote/cisco.log"
        template="RemoteFormat"
    )
    stop
}
```

Restart rsyslog after configuration changes:

```bash
docker compose restart rsyslog
```

Then monitor:

```bash
tail -f /path/to/remote/cisco.log
```

## Save the Cisco Configuration

After validating remote logging:

```text
copy running-config startup-config
```

At:

```text
Destination filename [startup-config]?
```

press **Enter** to accept the default.

Successful completion should return:

```text
Building configuration...
[OK]
```

## Security Considerations

The configuration in this guide uses traditional syslog over **UDP/514**.

UDP syslog:

- Is not encrypted
- Does not authenticate the collector
- Does not authenticate the sender
- Does not provide delivery acknowledgement
- Does not retransmit lost datagrams

It is appropriate for a trusted internal management network when these limitations are acceptable.

For environments requiring encrypted and authenticated transport, evaluate syslog over TLS where supported by the network platform and collector.

## Validation Checklist

- [ ] Switch clock is synchronized
- [ ] NTP is operational
- [ ] Local timezone is configured correctly
- [ ] `service timestamps log datetime msec localtime` configured
- [ ] Remote syslog collector configured
- [ ] Trap level set to `informational`
- [ ] `show logging` reports collector
- [ ] UDP/514 reaches collector
- [ ] rsyslog receives Cisco messages
- [ ] Cisco messages are written to the expected destination
- [ ] Event and collector timestamps are correct
- [ ] Running configuration saved to startup configuration

## Reference Configuration

A minimal configuration for centralized logging is:

```text
service timestamps debug datetime msec localtime
service timestamps log datetime msec localtime

logging host <collector-ip>
logging trap informational
logging on
```

After validation:

```text
copy running-config startup-config
```
