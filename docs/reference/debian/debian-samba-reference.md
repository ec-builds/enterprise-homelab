# Samba Reference — Debian

Sanitized reference for deploying and managing a lightweight, authenticated Samba SMB file server on Debian.

## Overview

Samba provides SMB file sharing from Linux to:

- Windows
- macOS
- Linux
- Network scanners
- Other SMB-compatible devices

This configuration assumes:

- Debian Server
- Standalone Samba server
- Authenticated access
- No guest access

## Install Samba

Update packages:

```bash
sudo apt update
```

Install Samba and SMB client utilities:

```bash
sudo apt install samba smbclient
```

Check the installed version:

```bash
smbd --version
```

Check the service:

```bash
systemctl status smbd --no-pager
```

## Create a Share Directory

Create the directory:

```bash
sudo mkdir -p /srv/samba/shared
```

Assign ownership:

```bash
sudo chown <linux-user>:<linux-user> /srv/samba/shared
```

Set permissions:

```bash
sudo chmod 2770 /srv/samba/shared
```

The `2` in `2770` enables the setgid bit so newly created files and directories inherit the directory's group.

## Create a Samba User

The corresponding Linux user must already exist.

Add the account to Samba:

```bash
sudo smbpasswd -a <linux-user>
```

List Samba users:

```bash
sudo pdbedit -L
```

The Samba password is used by SMB clients when authenticating to the server.

## Configure Samba

The main configuration file is:

```text
/etc/samba/smb.conf
```

Back up the configuration:

```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
```

Edit it:

```bash
sudo nano /etc/samba/smb.conf
```

Add the following at the bottom:

```ini
[Shared]
    path = /srv/samba/shared
    browseable = yes
    read only = no
    guest ok = no
    valid users = <linux-user>
    create mask = 0660
    directory mask = 0770
```

### Share Settings

| Setting | Purpose |
|---|---|
| `[Shared]` | Name presented to SMB clients |
| `path` | Local directory being shared |
| `browseable = yes` | Makes the share browsable |
| `read only = no` | Allows clients to write |
| `guest ok = no` | Requires authentication |
| `valid users` | Restricts access to specified users |
| `create mask` | Permissions for newly created files |
| `directory mask` | Permissions for newly created directories |

## Validate Configuration

Always validate the configuration before restarting Samba:

```bash
testparm
```

A valid configuration should report:

```text
Loaded services file OK.
```

Correct any errors before restarting the service.

## Start and Enable Samba

Restart Samba:

```bash
sudo systemctl restart smbd
```

Enable it at boot:

```bash
sudo systemctl enable smbd
```

Verify:

```bash
systemctl status smbd --no-pager
```

## Test Locally

Connect to the share from the Samba server:

```bash
smbclient //localhost/Shared -U <linux-user>
```

Enter the Samba password.

A successful connection produces:

```text
smb: \>
```

List files:

```text
ls
```

Exit:

```text
exit
```

List available shares:

```bash
smbclient -L localhost -U <linux-user>
```

## Connect from macOS

In Finder:

**Go → Connect to Server**

Or press:

```text
Command + K
```

Enter:

```text
smb://<server-address>/Shared
```

Example:

```text
smb://10.0.0.50/Shared
```

Authenticate using the Samba username and password.

## Connect from Windows

Open File Explorer and enter:

```text
\\<server-address>\Shared
```

Example:

```text
\\10.0.0.50\Shared
```

Authenticate using the Samba username and password.

## Useful Administration Commands

### Check Samba Status

```bash
systemctl status smbd --no-pager
```

### Restart Samba

```bash
sudo systemctl restart smbd
```

### Validate Configuration

```bash
testparm
```

### List Samba Users

```bash
sudo pdbedit -L
```

### Add a Samba User

```bash
sudo smbpasswd -a <linux-user>
```

### Change a Samba Password

```bash
sudo smbpasswd <linux-user>
```

### Disable a Samba User

```bash
sudo smbpasswd -d <linux-user>
```

### Enable a Samba User

```bash
sudo smbpasswd -e <linux-user>
```

### Show Active SMB Connections

```bash
sudo smbstatus
```

### List Local Shares

```bash
smbclient -L localhost -U <linux-user>
```

### Follow Samba Logs

```bash
journalctl -u smbd -f
```

### Show Recent Samba Logs

```bash
journalctl -u smbd -n 100 --no-pager
```

### Check SMB Listening Ports

```bash
sudo ss -lntp | grep -E ':445|:139'
```

## Security Recommendations

Use authenticated shares:

```ini
guest ok = no
```

Restrict access to known users:

```ini
valid users = <linux-user>
```

Do not expose SMB directly to the public Internet.

TCP port `445` should normally only be reachable from trusted internal networks or explicitly authorized VLANs.

Keep Debian and Samba updated:

```bash
sudo apt update
sudo apt upgrade samba
```

Validate the Samba configuration after changes:

```bash
testparm
```

## Reliability Recommendations

A Samba share is not a backup by itself.

Important files stored on the server should also exist somewhere else, such as:

- NAS
- Backup server
- External backup drive
- Cloud backup
- Another independent storage system

Before restarting Samba after configuration changes:

```bash
testparm
```

Then:

```bash
sudo systemctl restart smbd
```

## Troubleshooting

### Samba Service Not Running

Check:

```bash
systemctl status smbd --no-pager
```

View recent logs:

```bash
journalctl -u smbd -n 100 --no-pager
```

### Configuration Error

Run:

```bash
testparm
```

Correct all reported errors before restarting Samba.

### Authentication Failure

Verify the Samba account exists:

```bash
sudo pdbedit -L
```

Reset the password if necessary:

```bash
sudo smbpasswd <linux-user>
```

Verify the Linux account exists:

```bash
id <linux-user>
```

### Permission Denied

Check the entire directory path:

```bash
namei -l /srv/samba/shared
```

Check ownership:

```bash
ls -ld /srv/samba/shared
```

Correct ownership if necessary:

```bash
sudo chown <linux-user>:<linux-user> /srv/samba/shared
```

### Verify Port 445

Check whether Samba is listening:

```bash
sudo ss -lntp | grep ':445'
```

SMB primarily uses:

```text
TCP 445
```

Legacy NetBIOS-based SMB may additionally use ports `137-139`.

### Test the Server Locally

List shares:

```bash
smbclient -L localhost -U <linux-user>
```

Connect directly:

```bash
smbclient //localhost/Shared -U <linux-user>
```

If local access works but another computer cannot connect, investigate:

- Host firewall
- VLAN firewall rules
- Client isolation
- Network routing
- DNS/name resolution
- TCP 445 connectivity

## Quick Deployment Checklist

- [ ] Install `samba` and `smbclient`
- [ ] Create the share directory
- [ ] Set directory ownership and permissions
- [ ] Add the Samba user with `smbpasswd`
- [ ] Back up `/etc/samba/smb.conf`
- [ ] Configure the share
- [ ] Run `testparm`
- [ ] Restart `smbd`
- [ ] Enable `smbd` at boot
- [ ] Test with `smbclient`
- [ ] Connect from macOS or Windows
- [ ] Keep important data backed up

## Common Paths

| Purpose | Path |
|---|---|
| Samba configuration | `/etc/samba/smb.conf` |
| Samba share data | `/srv/samba/` |
| Samba service | `smbd.service` |
| SMB port | `TCP 445` |

## Quick Reference

```bash
# Install
sudo apt install samba smbclient

# Add Samba user
sudo smbpasswd -a <linux-user>

# Validate configuration
testparm

# Restart
sudo systemctl restart smbd

# Status
systemctl status smbd --no-pager

# List Samba users
sudo pdbedit -L

# Active sessions
sudo smbstatus

# List shares
smbclient -L localhost -U <linux-user>

# Logs
journalctl -u smbd -n 100 --no-pager

# Check SMB port
sudo ss -lntp | grep ':445'
```
