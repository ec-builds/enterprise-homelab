# Reference — Gathering Hardware Info from Windows Machines

How to collect the specs needed for the inventory chart and equipment pages. Run all commands in PowerShell (Admin not required unless noted).

## Full System Overview

```powershell
systeminfo
```

Returns: hostname, OS name/version/build, install date, manufacturer, system model, CPU (family/model), BIOS version, total RAM, NICs with IPs, virtualization/security status.

## CPU (friendly name, cores)

```powershell
Get-CimInstance Win32_Processor | Select Name, NumberOfCores, NumberOfLogicalProcessors
```

## GPU

```powershell
Get-CimInstance Win32_VideoController | Select Name, AdapterRAM, DriverVersion
```

Note: `AdapterRAM` caps at 4 GB on some systems (32-bit WMI value). For exact VRAM on discrete cards, check Task Manager > Performance > GPU, or `dxdiag`.

## Storage (physical drives)

```powershell
Get-PhysicalDisk | Select FriendlyName, MediaType, BusType, @{n='SizeGB';e={[math]::Round($_.Size/1GB)}}
```

Returns drive model, SSD/HDD, NVMe/SATA, and size. For volumes/partitions instead:

```powershell
Get-Volume | Select DriveLetter, FileSystemLabel, @{n='SizeGB';e={[math]::Round($_.Size/1GB)}}
```

## RAM (sticks, speed, part numbers)

```powershell
Get-CimInstance Win32_PhysicalMemory | Select Manufacturer, PartNumber, Speed, @{n='GB';e={$_.Capacity/1GB}}
```

## Motherboard

```powershell
Get-CimInstance Win32_BaseBoard | Select Manufacturer, Product
```

Note: `systeminfo` shows the OEM board ID (e.g., "MS-7C95"); this command gives the retail model name.

## Serial / Service Tag (Dell, etc.)

```powershell
Get-CimInstance Win32_BIOS | Select SerialNumber
```

## Network Adapters

```powershell
Get-NetAdapter | Select Name, InterfaceDescription, Status, MacAddress, LinkSpeed
ipconfig /all
```

## GUI Alternatives

| Tool | Run | Use for |
|---|---|---|
| System Information | `msinfo32` | Everything in one tree; File > Export to save as .txt |
| DirectX Diagnostic | `dxdiag` | GPU details, VRAM, driver; "Save All Information" button |
| Task Manager | Ctrl+Shift+Esc > Performance | Live view: RAM slots used, GPU VRAM, disk type |

## Workflow

1. Run `systeminfo` for the baseline (OS, RAM total, model, BIOS).
2. Run the CPU, GPU, storage, RAM, and serial commands above.
3. Paste output into the device's equipment page or hand it to Claude to update the page and inventory summary.
