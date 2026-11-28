# AdGuard Home Upgrade

## Overview

How to upgrade AdGuard Home on `adguard-lab-01` and `adguard-lab-02`. Upgrade one instance at a time so the other keeps answering DNS. Installation is covered in [AdGuard Home Native Installation](./adguard-home-native-install.md).

Examples use `adguard-lab-01` at `10.0.0.20`.

## 1. Check the Version and Back Up

```bash
/opt/AdGuardHome/AdGuardHome --version
sudo cp /opt/AdGuardHome/AdGuardHome.yaml ~/AdGuardHome.yaml.$(date +%F)
```

The backup holds every setting, including the admin password hash, so keep it out of the repository.

## 2. Upgrade

Use either method.

**Web interface:** when a newer version is available, the dashboard shows a banner with **Update now**. AdGuard downloads the release, replaces itself and restarts.

**Shell:**

```bash
/opt/AdGuardHome/AdGuardHome --help | grep -i update   # confirm the flag exists
sudo /opt/AdGuardHome/AdGuardHome --update
```

Don't upgrade with the install script's `-r` option. It uninstalls before reinstalling.

## 3. Verify

```bash
/opt/AdGuardHome/AdGuardHome --version
systemctl status AdGuardHome
dig @10.0.0.20 example.com +short
```

Expect the new version, `active (running)`, and an address from `dig`. Open the web interface and check that the blocklists and DNS settings are unchanged.

## 4. Upgrade the Second Instance

Repeat steps 1 to 3 on `adguard-lab-02` once `adguard-lab-01` checks out.

## Roll Back

If the new version won't start or settings are wrong:

```bash
sudo systemctl stop AdGuardHome
sudo cp ~/AdGuardHome.yaml.<date> /opt/AdGuardHome/AdGuardHome.yaml
sudo systemctl start AdGuardHome
```

To return to the previous version itself, download that release from the [AdGuard Home releases](https://github.com/AdguardTeam/AdGuardHome/releases) page and replace `/opt/AdGuardHome/AdGuardHome` with its binary while the service is stopped.

## Related Documentation

- [AdGuard Home Native Installation](./adguard-home-native-install.md)
- [DNS Filtering with AdGuard Home](../../../projects/network-infrastructure/04-dns-filtering-adguard-home.md)
