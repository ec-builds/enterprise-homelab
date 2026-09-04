# Linux User Management

Reference for creating and managing local user accounts on Linux systems.

Examples use `adminuser` as a generic administrative account.



## Create a User

Create a new user with a home directory and password:

```bash
sudo adduser adminuser
```

The command creates the account, creates `/home/adminuser`, assigns the default shell, and prompts for a password and optional account information.



## Grant sudo Access

Add the user to the `sudo` group:

```bash
sudo usermod -aG sudo adminuser
```

Verify group membership:

```bash
groups adminuser
```

Expected output should include:

```text
adminuser : adminuser sudo
```

> [!NOTE]
> Membership in the `sudo` group normally takes effect at the user's next login.



## Test the Account

Switch to the new user:

```bash
su - adminuser
```

Verify the current account:

```bash
whoami
```

Test sudo access:

```bash
sudo whoami
```

Expected output:

```text
root
```



## Change a User Password

Change another user's password:

```bash
sudo passwd adminuser
```

A user can change their own password with:

```bash
passwd
```



## Add a User to a Group

Add an existing user to an additional group:

```bash
sudo usermod -aG <group> adminuser
```

For example:

```bash
sudo usermod -aG docker adminuser
```

Always use `-aG` when adding supplementary groups. Omitting `-a` can replace the user's existing supplementary group memberships.



## View User Information

Display the user's UID, primary group, and supplementary groups:

```bash
id adminuser
```

View group membership:

```bash
groups adminuser
```

View the account entry:

```bash
getent passwd adminuser
```



## Lock and Unlock an Account

Lock the user's password:

```bash
sudo passwd -l adminuser
```

Unlock it:

```bash
sudo passwd -u adminuser
```

> [!NOTE]
> Locking the password does not necessarily terminate existing sessions or disable every authentication method, such as SSH public-key authentication.



## Delete a User

Delete the account while preserving its home directory:

```bash
sudo deluser adminuser
```

Delete the account and its home directory:

```bash
sudo deluser --remove-home adminuser
```

Verify that the account no longer exists:

```bash
getent passwd adminuser
```



## Administrative User Baseline

For a standard administrative Linux account:

```bash
sudo adduser adminuser
sudo usermod -aG sudo adminuser
groups adminuser
```

Then log in as the new account and validate sudo:

```bash
sudo whoami
```

Expected output:

```text
root
```

For systems using SSH, configure the administrator's SSH key before disabling password or root SSH access.
