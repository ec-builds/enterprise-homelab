# Desktop-01 — Workstation

Custom build on MSI B550M. **Role:** Pending Assignment | **Status:** Available

## Hardware

| Item | Spec |
|---|---|
| CPU | AMD Ryzen 7 5700X — 8 cores / 16 threads, ~3.4 GHz base |
| GPU | NVIDIA GeForce RTX 5070 (driver 32.0.15.9174) |
| RAM | 64 GB (4× 16 GB) Kingston HyperX KHX2400C15/16G DDR4-2400 |
| Storage 1 | Samsung 980 1TB NVMe SSD |
| Storage 2 | Crucial P3 Plus 1TB NVMe SSD (CT1000P3PSSD8) |
| Motherboard | MSI PRO B550M-VC WIFI (MS-7C95) |
| BIOS | AMI H.D1 (9/4/2024) |

## Network

| Adapter | Details |
|---|---|
| Wi-Fi | MediaTek RZ616 Wi-Fi 6E 160MHz — active, DHCP |
| Ethernet | Realtek PCIe GbE — disconnected |
| Other | Xbox Wireless Adapter; VirtualBox host-only adapter |

## OS / Software

| Item | Spec |
|---|---|
| OS | Windows 11 Pro, build 26200 |
| Installed | 11/25/2024 |
| Domain | WORKGROUP (standalone) |
| Security | VBS running (HVCI enforced), Secure Boot, DMA protection |
| Virtualization | Hypervisor detected (Hyper-V/VirtualBox present) |

## Notes

- RAM runs at DDR4-2400; this kit is older HyperX — B550 + 5700X supports 3200+, so XMP or faster RAM is a cheap upgrade if repurposed.
- `AdapterRAM` misreported 4 GB for the RTX 5070 (WMI 32-bit cap) — actual VRAM is 12 GB.
- Inventory summary GPU column can be updated: **NVIDIA GeForce RTX 5070**.

---
Source: `systeminfo` + PowerShell CIM queries run on host, 2026-07-07 
