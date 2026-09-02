# Change Debian Hostname

## Goal

Change the hostname of a Debian system and update local hostname resolution so the new hostname is used consistently.

## Change the Hostname

Set the new hostname using `hostnamectl`.

```bash
sudo hostnamectl set-hostname <new-hostname>
```

Example:

```bash
sudo hostnamectl set-hostname debian-lab-vm
```

This updates the persistent hostname stored in:

```text
/etc/hostname
```

Verify the change:

```bash
hostname
cat /etc/hostname
```

## Update Local Host Resolution

Review `/etc/hosts`.

```bash
cat /etc/hosts
```

A Debian system may contain an entry similar to:

```text
127.0.1.1    old-hostname.lab.example.com    old-hostname
```

Edit the file:

```bash
sudo vi /etc/hosts
```

Replace the old hostname and FQDN with the new values.

Example:

```text
127.0.0.1    localhost
127.0.1.1    debian-lab-vm.lab.example.com    debian-lab-vm

# The following lines are desirable for IPv6 capable hosts
::1          localhost ip6-localhost ip6-loopback
ff02::1      ip6-allnodes
ff02::2      ip6-allrouters
```

> [!NOTE]
> Update `/etc/hosts` immediately after changing the hostname. If the new
> hostname cannot be resolved locally, commands using `sudo` may display:
>
> ```text
> sudo: unable to resolve host <new-hostname>: Name or service not known
> ```

## Reboot

Reboot the system to ensure all services and login sessions use the new hostname.

```bash
sudo reboot
```

## Validation

After the system restarts, verify the hostname and local resolution.

```bash
hostname
hostnamectl
cat /etc/hostname
cat /etc/hosts
getent hosts <new-hostname>
```

Confirm that:

- `hostname` returns the new hostname.
- `hostnamectl` reports the new static hostname.
- `/etc/hostname` contains the new hostname.
- `/etc/hosts` contains the corresponding hostname entry.
- `getent hosts` resolves the new hostname.
- New shell sessions display the new hostname in the prompt.

## Template Consideration

Changing the hostname does not change the system machine ID or SSH host keys.

When preparing a Debian virtual machine for use as a template, machine ID and SSH host key cleanup should be performed separately during final template preparation.
