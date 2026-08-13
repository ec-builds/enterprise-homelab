# 02 · Enrollment

## Enrollment Preparation

Before enrolling a Windows endpoint, I created a standard test user in **Microsoft Entra ID** and assigned the Intune trial license required for device enrollment.

Although users can also be created through the Intune admin center, the underlying identities are stored in Microsoft Entra ID. I performed user administration directly through Entra and used Intune for endpoint-management operations.

The test account is a standard user rather than an administrative account, keeping device enrollment separate from privileged administration.

```text
Microsoft Entra User
        ↓
Intune License
        ↓
Eligible for MDM Enrollment
        ↓
Windows 11 Entra Join
        ↓
Automatic Intune Enrollment
        ↓
Managed Endpoint
```

### Test User and Group

I created a standard test user in Microsoft Entra ID, assigned the Intune trial license, and added the account to the `Intune-Lab-Users` security group.

Although groups can be created through the Intune admin center, they are backed by Microsoft Entra ID. I created and managed the lab security groups directly in Entra and use them within Intune for enrollment, policy, application, and compliance targeting.

```text
Intune-Lab-Users
        │
        └── Licensed Test User
                ↓
        Eligible for MDM Enrollment
                ↓
        Target Intune Policies
```

This group-based approach allows Intune configurations to be assigned to a managed population rather than individual users and provides a structure that can scale as additional test users and devices are added.

## Automatic Enrollment

<!-- Configure MDM user scope and document automatic enrollment here. -->

## Windows Device Enrollment

<!-- Entra join and enroll the Windows 11 test endpoint here. -->

## Enrollment Validation

<!-- Verify the device, primary user, ownership, compliance state, and management status here. -->

## Results

<!-- Summarize the completed enrollment workflow here. -->

## References

- [Microsoft Learn — Create a user in Intune and assign the user a license](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/quickstart-create-user)
- [Microsoft Learn — Create a group to manage users](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/quickstart-create-group)
