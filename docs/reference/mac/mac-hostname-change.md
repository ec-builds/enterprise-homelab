# macOS Hostname Rename Reference

Quick reference for viewing and renaming a Mac from Terminal.

## View Current Hostnames

```bash
scutil --get ComputerName
scutil --get LocalHostName
scutil --get HostName
```

### Hostname Types

| Setting | Purpose |
|---|---|
| `ComputerName` | Friendly name displayed by macOS |
| `LocalHostName` | Bonjour/local network name (`hostname.local`) |
| `HostName` | System hostname used by Terminal, SSH, and other network services |

## Rename the Mac

Replace `newhostname` with the desired hostname.

```bash
sudo scutil --set ComputerName "newhostname"
sudo scutil --set LocalHostName "newhostname"
sudo scutil --set HostName "newhostname"
```

Example:

```bash
sudo scutil --set ComputerName "media-lab"
sudo scutil --set LocalHostName "media-lab"
sudo scutil --set HostName "media-lab"
```

## Verify

```bash
echo "ComputerName: $(scutil --get ComputerName)"
echo "LocalHostName: $(scutil --get LocalHostName)"
echo "HostName: $(scutil --get HostName)"
```

Expected:

```text
ComputerName: media-lab
LocalHostName: media-lab
HostName: media-lab
```

Open a new Terminal session or reboot if the old hostname still appears in the shell prompt.
