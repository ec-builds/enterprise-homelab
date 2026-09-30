# Architecture

How Microsoft Entra ID, Microsoft Intune, and Windows endpoints connect in this lab.

<!-- TODO: Architecture diagram. -->

## Components

| Component | Role |
|---|---|
| Microsoft Entra ID | Identities, groups, device objects, and access decisions |
| Microsoft Intune | Enrollment, configuration, security, applications, and compliance |
| Windows 11 endpoints | Managed devices (Hyper-V VMs and a physical workstation) |
| Microsoft Graph | Programmatic access for automation and reporting |

## Design Decisions

| Decision | Rationale |
|---|---|
| Cloud-only identity | Keeps the lab focused on cloud-native management |
| Microsoft Entra join | Microsoft's recommended approach for new Windows deployments; avoids hybrid join infrastructure |
| <!-- TODO --> | |

## Management Flow

<!-- TODO: How a device moves from enrollment through policy, compliance, and access. -->
