# Ventoy Multiboot & Recovery USB

Reusable bootable USB for the home lab. Ventoy allows multiple ISO images to reside on a single external USB device and presents them in a boot menu without requiring the USB to be reformatted for each operating system or recovery environment.

## Purpose

- Maintain one reusable installation and recovery USB
- Boot multiple operating-system installers
- Store Proxmox, Windows, and Linux installation media
- Store Synology Active Backup recovery media
- Simplify rebuilding physical lab hosts
- Provide portable troubleshooting and recovery tools

## Ventoy

Ventoy is installed directly to the USB device using `Ventoy2Disk.exe`.

After the initial installation, ISO files can simply be copied to or removed from the Ventoy data partition. They **do not need to be extracted or individually flashed to the USB**.

Ventoy automatically discovers supported boot images, including images stored inside folders.

## Recommended USB Structure

```
Ventoy/
│
├── ISO/
│   ├── proxmox-ve.iso
│   ├── Windows-11.iso
│   ├── Windows-Server-2025.iso
│   ├── ubuntu-server.iso
│   └── debian.iso
│
├── Recovery/
│   ├── Synology-Windows-Recovery.iso
│   └── Synology-Linux-Recovery.iso
│
└── Tools/
    └── ...
```

File and folder names can be changed for organization without needing to reinstall Ventoy.

## Adding an ISO

1. Download the ISO from the vendor's official source.
2. Verify the downloaded file's checksum when the vendor provides one.
3. Open the Ventoy USB in File Explorer.
4. Copy the complete `.iso` file to the appropriate folder.
5. Safely eject the USB.

No additional Ventoy configuration is normally required.

## SHA-256 Verification

Calculate a downloaded file's SHA-256 hash with PowerShell:

```powershell
Get-FileHash ".\filename.iso" -Algorithm SHA256
```

Compare it directly against the vendor's published SHA-256 value:

```powershell
(Get-FileHash ".\filename.iso" -Algorithm SHA256).Hash -eq "EXPECTED_SHA256_HASH"
```

Expected result:

```text
True
```

Uppercase and lowercase hexadecimal characters do not affect the comparison.

For more descriptive output:

```powershell
$expected = "EXPECTED_SHA256_HASH"
$actual = (Get-FileHash ".\filename.iso" -Algorithm SHA256).Hash

if ($actual -eq $expected) {
    Write-Host "MATCH - File verified"
} else {
    Write-Host "MISMATCH - Do not use file"
}
```

## Booting Ventoy

1. Insert the Ventoy USB.
2. Power on or restart the target computer.
3. Open the system's one-time boot menu.
4. Select the UEFI USB device.
5. Ventoy loads and displays the available boot images.
6. Select the required ISO.
7. Boot the selected installer or recovery environment.

### Dell OptiPlex

On Dell OptiPlex systems:

```text
F2  → BIOS Setup
F12 → One-Time Boot Menu
```

For the Proxmox hosts, use **UEFI boot mode**.

## Secure Boot

Some systems may display:

```text
0x1A
Security Policy Violation
```

when attempting to boot Ventoy.

This generally indicates that UEFI Secure Boot rejected the Ventoy boot chain.

For dedicated Proxmox lab hosts, the straightforward configuration is:

```text
Boot Mode:        UEFI
Secure Boot:      Disabled
Legacy/CSM:       Disabled
```

Disabling Secure Boot **does not require disabling UEFI**.

UEFI should remain enabled.
