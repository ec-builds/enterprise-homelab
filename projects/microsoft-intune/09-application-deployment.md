# Application Deployment

**Status: 🟢 Operational**

This document covers Windows application deployment through Microsoft Intune.

The lab uses **7-Zip 26.04 (x64)** to validate the Win32 application deployment lifecycle from application packaging through assignment, endpoint installation, detection, and Intune reporting.

## Deployment Workflow

```text
Download Application Installer
        ↓
Package Installer as .intunewin
        ↓
Add Windows Win32 App to Intune
        ↓
Configure Application
├── Install / Uninstall Commands
├── System Installation Context
├── Windows Requirements
└── Detection Rule
        ↓
Assign as Required
        ↓
Intune-corporate-devices
        ↓
Managed Endpoint Checks In
        ↓
Intune Management Extension
        ↓
Silent Application Installation
        ↓
Detection Rule Evaluation
        ↓
Intune Deployment Reporting
```

## 1. Application Packaging

**Application:** 7-Zip 26.04 (x64)  
**Deployment Type:** Windows Win32 app  
**Installer:** `7z2604-x64.exe`  
**Package Format:** `.intunewin`

The 7-Zip executable installer was packaged using the **Microsoft Win32 Content Prep Tool** before being uploaded to Intune.

Packaging the application as a Win32 app allowed Intune to manage the complete deployment lifecycle, including installation commands, requirements, detection, assignment, and reporting.

## 2. Intune Application Configuration

The Win32 application was configured for silent, machine-wide installation.

| Setting | Configuration |
|---|---|
| Version | 26.04 |
| Architecture | x64 |
| Minimum OS | Windows 11 21H2 |
| Install behavior | System |
| Install command | `7z2604-x64.exe /S` |
| Uninstall command | `"C:\Program Files\7-Zip\Uninstall.exe" /S` |
| Restart behavior | No specific action |

Using the **System** installation context allows Intune to install the application without depending on the signed-in user's local administrative privileges.

![Win32 application configuration](./diagrams/intune-app-summary(1).png)

## 3. Detection Rule

A file-based detection rule was configured so Intune could determine whether the application was present after deployment.

The rule checks the expected 7-Zip installation location under:

```text
C:\Program Files\7-Zip
```

Detection is an important part of Win32 application management because a successful installer exit alone does not establish the application's managed state. Intune evaluates the configured detection rule to determine whether the application is installed.

## 4. Assignment

The application was assigned as **Required** to:

```text
Intune-corporate-devices
```

A Required assignment was selected to test centrally enforced application deployment rather than optional user installation through Company Portal.

Both corporate Windows test endpoints were therefore expected to receive 7-Zip automatically when they checked in with Intune.

![Required application assignment](./diagrams/intune-app-assignments.png)

## 5. Endpoint Deployment

`WIN11-CLIENT-02` was online during deployment testing.

After the Intune assignment was processed, 7-Zip installed silently on the managed endpoint without requiring the user to manually download or launch the installer.

The installed application was then verified directly from Windows.

![7-Zip installed on managed Windows endpoint](./diagrams/intune-app-deploy-success-client.png)

## 6. Offline Device Test

`WIN11-CLIENT-03` was powered off when the Required application assignment was created.

This provided an additional deployment scenario:

```text
Required Application Assigned
        ↓
WIN11-CLIENT-03 Offline
        ↓
No Installation While Offline
        ↓
Device Powered On
        ↓
Device Reconnects to Intune
        ↓
Policy / Application Assignment Processed
        ↓
7-Zip Installed
        ↓
Intune Reports Installed
```

After `WIN11-CLIENT-03` was powered on and reconnected, it synchronized with Intune and subsequently installed the assigned application.

This validated that a Required application assignment did not depend on the endpoint being online when the assignment was originally created. The device processed the outstanding deployment after returning online and checking in with Intune.

## 7. Deployment Reporting

Intune subsequently reported the application as **Installed** on both managed endpoints:

| Device | Application Version | Result |
|---|---:|---|
| `WIN11-CLIENT-02` | 26.04 | Installed |
| `WIN11-CLIENT-03` | 26.04 | Installed |

This provided management-plane confirmation in addition to the endpoint-side verification.

![Successful Intune application deployment](./diagrams/intune-app-deploy-success.png)

## Validation

**Status: 🟢 Passed**

The following deployment behaviors were successfully validated:

- Win32 application packaged as `.intunewin`
- Silent installation configured
- Application installed in System context
- Windows architecture and OS requirements applied
- File-based detection configured
- Application assigned as Required to the corporate device group
- Online managed endpoint received and installed the application
- Application presence verified directly on Windows
- Intune reported successful installation
- Both targeted corporate endpoints reported version 26.04 as Installed
- Endpoint that was offline during assignment received the application after being powered on and reconnecting to Intune

The combined endpoint and Intune reporting evidence confirms the complete deployment path:

```text
Package
   ↓
Configure
   ↓
Assign
   ↓
Device Check-In
   ↓
Install
   ↓
Detect
   ↓
Report
```

## Lessons Learned

### Required assignments persist for offline devices

A managed endpoint does not need to be online when a Required application is initially assigned.

`WIN11-CLIENT-03` was powered off during the original deployment. After the endpoint was powered on and reconnected, it checked in with Intune and received the outstanding application assignment.

This demonstrated the asynchronous nature of cloud endpoint management: configuration can be assigned centrally while devices are unavailable and applied when those devices subsequently reconnect.

### Detection is separate from installation

Running an installer successfully is only part of the Win32 application lifecycle.

Intune uses the configured detection rule to determine whether the expected application state exists on the endpoint. Detection therefore needs to accurately represent the installed application.

### System context supports centralized software deployment

Installing the application in **System** context allowed the deployment to occur independently of the privileges of the interactive user.

This better represents centrally managed enterprise software deployment than requiring users to install applications manually.

### Reporting may lag behind endpoint state

The application was visible on the Windows endpoint before the Intune portal reflected the final installation status.

Endpoint state and cloud reporting should therefore both be considered during deployment troubleshooting rather than assuming an application failed because the administrative portal has not yet updated.