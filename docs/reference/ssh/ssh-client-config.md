# SSH Client Configuration

## Overview

OpenSSH client settings can be stored in `~/.ssh/config` to simplify connections and apply settings to specific hosts.

This is useful when a device requires:

- A specific username
- A hostname or IP alias
- Non-default SSH options
- Legacy compatibility settings

## Create the SSH Config File

Create or edit the configuration file:

```bash
vi ~/.ssh/config
```

Add a host entry:

```text
Host switch-lab-01
    HostName 10.0.0.2
    User admin
    KexAlgorithms +diffie-hellman-group14-sha1
    HostKeyAlgorithms +ssh-rsa
```

Save and exit:

```text
Ctrl+O
Enter
Ctrl+X
```

Optionally restrict permissions on the file:

```bash
chmod 600 ~/.ssh/config
```

## Connect Using the Alias

Instead of entering the full connection command:

```bash
ssh \
  -oKexAlgorithms=+diffie-hellman-group14-sha1 \
  -oHostKeyAlgorithms=+ssh-rsa \
  admin@10.0.0.2
```

connect using:

```bash
ssh switch-lab-01
```

OpenSSH automatically applies the settings associated with that host.

> [!CAUTION]
> Legacy algorithms should be enabled only for hosts that require them. Avoid enabling deprecated algorithms globally.

## Add Additional Hosts

Multiple systems can be defined in the same file:

```text
Host server-lab-01
    HostName 10.0.0.10
    User admin

Host switch-lab-01
    HostName 10.0.0.2
    User admin
    KexAlgorithms +diffie-hellman-group14-sha1
    HostKeyAlgorithms +ssh-rsa
```

Each system can then be accessed using its alias:

```bash
ssh server-lab-01
ssh switch-lab-01
```

## Key Takeaway

`~/.ssh/config` provides a centralized way to define SSH connection settings and create convenient aliases while keeping host-specific requirements isolated.
