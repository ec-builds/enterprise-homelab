# Debian Post-Clone Configuration

## Goal

Prepare a Debian virtual machine cloned from the standard Debian template for use as a new system.

The Debian template is prepared without a persistent machine identity or SSH host keys. After cloning, verify that the new VM has established a unique machine identity, generate SSH host keys if necessary, assign the intended hostname, and validate the system before beginning workload-specific configuration.

## Verify Machine Identity

After the cloned VM completes its first boot, verify that `/etc/machine-id` has been populated.

```bash
cat /etc/machine-id
```

The command should return a non-empty machine ID.

Verify that `hostnamectl` is functional:

```bash
hostnamectl
```

> [!NOTE]
> The machine ID is cleared during final template preparation. A new machine
> ID should be established when the cloned VM boots.

## Verify SSH Host Keys

Check for SSH host keys:

```bash
ls -l /etc/ssh/ssh_host_*
```

If host keys exist, verify that the expected private and public key pairs are present.

Typical files include:

```text
ssh_host_ecdsa_key
ssh_host_ecdsa_key.pub
ssh_host_ed25519_key
ssh_host_ed25519_key.pub
ssh_host_rsa_key
ssh_host_rsa_key.pub
```

If the command reports that no matching files exist, generate new SSH host keys:

```bash
sudo ssh-keygen -A
```

Verify the generated keys:

```bash
ls -l /etc/ssh/ssh_host_*
```

Restart the SSH service:

```bash
sudo systemctl restart ssh
```

Verify that SSH is running:

```bash
systemctl status ssh
```

> [!NOTE]
> SSH host keys are removed during final template preparation so cloned
> systems do not inherit the same server identity. Depending on the Debian
> installation and provisioning method, missing host keys may not be
> regenerated automatically during the first boot.

## Change the Hostname

The cloned VM initially inherits the hostname configured on the Debian template.

Assign the hostname intended for the new system before beginning workload-specific configuration.

Follow:

➡️ [Debian Hostname Change](./debian-hostname-change.md)

The hostname procedure includes:

- Setting the new hostname with `hostnamectl`
- Updating `/etc/hosts`
- Verifying local hostname resolution
- Rebooting the system
- Validating the new hostname

## Validate Networking

After the hostname change and reboot, verify that the network interface has an IPv4 address:

```bash
ip a
```

Verify the default route:

```bash
ip route
```

Verify DNS resolution:

```bash
getent hosts debian.org
```

Verify external connectivity:

```bash
ping -c 4 1.1.1.1
```

## Final Validation

Verify the new system identity:

```bash
hostname
hostnamectl
cat /etc/hostname
cat /etc/machine-id
```

Verify SSH host keys:

```bash
ls -l /etc/ssh/ssh_host_*
```

Verify SSH and the QEMU Guest Agent:

```bash
systemctl is-active ssh
systemctl is-active qemu-guest-agent
```

Confirm that:

- The new hostname is configured.
- `/etc/hosts` reflects the new hostname.
- `/etc/machine-id` contains a machine ID.
- SSH host keys exist.
- SSH is running.
- The QEMU Guest Agent is running.
- Networking and DNS resolution are functional.

Once validation is complete, the VM is ready for workload-specific configuration.
