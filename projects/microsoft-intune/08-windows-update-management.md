# Windows Update Management

**Status:** 🟡 Feature Update Validation Pending

This lab implements centralized Windows Update management through Microsoft Intune. An update ring defines servicing behavior for a managed Windows endpoint, while a separate feature update policy targets Windows 11, version 26H2.

A dedicated pilot device group is used to test the policies before broader deployment.

## Objectives

- Configure Windows Update servicing through Microsoft Intune
- Define update installation, restart, and deadline behavior
- Use a dedicated pilot group for controlled deployment
- Separate update-ring configuration from feature-version targeting
- Deploy Windows 11 26H2 as a required feature update
- Monitor deployment status through Intune
- Validate the resulting Windows version on the endpoint

## Deployment Architecture

```text
Microsoft Intune
       │
       ├── Windows Corporate Update Ring
       │       │
       │       ├── Quality update behavior
       │       ├── Feature update behavior
       │       ├── Active hours
       │       ├── Update deadlines
       │       └── Restart behavior
       │
       └── Windows 11 26H2 Pilot
               │
               └── Required feature release
                       │
                       ▼
          Intune-update-ring-test-group
                       │
                       ▼
               WIN11-CLIENT-03
                       │
                       ▼
                Windows Update
                       │
                       ▼
             Windows 11 26H2
             [Validation Pending]
```

## Pilot Deployment Strategy

Rather than initially assigning the update policies to all corporate-managed endpoints, a dedicated security group was created for update testing.

| Setting | Configuration |
|---|---|
| Pilot Group | `Intune-update-ring-test-group` |
| Membership Type | Assigned |
| Device Members | 1 |
| Pilot Endpoint | `WIN11-CLIENT-03` |

This provides a controlled deployment path where update behavior can be validated on a pilot endpoint before expanding the policy to additional managed devices.

## Windows Update Ring

The `Windows Corporate Update Ring` controls how Windows Update operates on managed endpoints.

### Update Settings

| Setting | Configuration |
|---|---|
| Microsoft product updates | Allow |
| Windows drivers | Allow |
| Quality update deferral | 0 days |
| Feature update deferral | 0 days |
| Upgrade Windows 10 devices to latest Windows 11 release | No |
| Feature update uninstall period | 10 days |
| Servicing channel | General Availability channel |
| Pre-release builds | Not configured |

### User Experience

| Setting | Configuration |
|---|---|
| Automatic update behavior | Auto install and restart at maintenance time |
| Active hours | 8:00 AM – 6:00 PM |
| User option to pause updates | Disabled |
| User option to check for updates | Enabled |
| Update notifications | Default Windows Update notifications |
| Deadline settings | Enabled |
| Feature update deadline | 14 days |
| Quality update deadline | 7 days |
| Grace period | 2 days |
| Auto reboot before deadline | No |

The update ring controls servicing behavior but does not by itself define the specific Windows feature release used for the pilot deployment.

![Windows Update ring configuration](./diagrams/intune-update-ring-summary.png)

## Pilot Assignment

The update ring was assigned only to the dedicated pilot device group.

```text
Windows Corporate Update Ring
             │
             ▼
Intune-update-ring-test-group
             │
             ▼
      WIN11-CLIENT-03
```

This separates initial update testing from the broader `Intune-corporate-devices` population.

After creation, Intune reported both the quality and feature portions of the update ring as **Running**.

![Windows Update ring running](./diagrams/intune-update-ring-dashboard.png)

## Windows 11 26H2 Feature Update

A separate feature update deployment was created to control the Windows release delivered to the pilot endpoint.

| Setting | Configuration |
|---|---|
| Policy | `Windows 11 26H2 Pilot` |
| Target Release | Windows 11, version 26H2 |
| Deployment Type | Required |
| Rollout | Make update available as soon as possible |
| Assignment | `Intune-update-ring-test-group` |
| Target Devices | 1 |

Using a separate feature update policy provides a distinction between two update-management responsibilities:

```text
Update Ring
    │
    └── Controls HOW updates are serviced

Feature Update Policy
    │
    └── Controls WHICH Windows feature release is deployed
```

![Windows 11 26H2 feature update configuration](./diagrams/intune-update-ring-feature-update-summary.png)

## Deployment Monitoring

After the feature update policy was created, Intune reported the `Windows 11 26H2 Pilot` deployment as **In progress**.

This confirms that the deployment moved beyond policy configuration and entered the active deployment lifecycle.

![Windows 11 26H2 deployment in progress](./diagrams/intune-update-ring-feature-update-dashboard.png)

## Validation

### Update Ring

- [x] Windows Update ring created
- [x] Update behavior configured
- [x] Active hours configured
- [x] Quality and feature update deadlines configured
- [x] User update controls configured
- [x] Dedicated pilot security group created
- [x] Update ring assigned to pilot group
- [x] Update ring reports Running

### Feature Update

- [x] Windows 11 26H2 feature update deployment created
- [x] Feature update configured as Required
- [x] Rollout configured to begin as soon as possible
- [x] Feature update assigned to pilot group
- [x] Intune reports deployment In progress
- [ ] Windows 11 26H2 downloaded to pilot endpoint
- [ ] Windows 11 26H2 installed successfully
- [ ] Post-update Windows version verified
- [ ] Final deployment state verified in Intune

## Final Endpoint Verification

Final validation is pending completion of the Windows 11 26H2 deployment on `WIN11-CLIENT-03`.

After installation and restart, the endpoint will be checked to confirm the installed Windows release and build.

```powershell
Get-ComputerInfo |
    Select-Object WindowsProductName, WindowsEditionId, WindowsVersion, OsBuildNumber
```

The final validation will document:

1. The resulting Windows version and build
2. Successful endpoint restart and operation
3. Intune feature-update deployment status
4. Confirmation that the pilot endpoint received the update through the managed Windows Update workflow

**Current state:** Feature update deployment is in progress.

## Key Takeaways

- Intune update rings and feature update policies serve different purposes.
- Update rings control servicing behavior, deadlines, restarts, and user experience.
- Feature update policies can target a specific Windows feature release independently of the servicing configuration.
- A dedicated pilot group limits deployment scope while a new update policy is being validated.
- Windows Update management is asynchronous; policy creation, endpoint processing, installation, restart, and Intune reporting do not necessarily occur simultaneously.
- Production-style update management benefits from validating updates against a limited pilot population before broader deployment.

## Next Steps

1. Allow `WIN11-CLIENT-03` to receive and install Windows 11 26H2.
2. Verify the resulting Windows version and build.
3. Capture endpoint evidence after the upgrade.
4. Confirm the final deployment state in Intune.
5. Mark this lab **🟢 Operational** after successful validation.