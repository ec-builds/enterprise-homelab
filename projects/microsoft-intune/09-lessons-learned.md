## 2026-08-13 — Intune RBAC Uses Group-Based Scoped Assignments

**Context**

While assigning the Intune Application Manager role, I found that Intune permissions are not assigned directly to individual administrators. Instead, a role assignment connects the role to an administrative group and defines the users and devices that group is allowed to manage.

**Lesson**

An Intune role defines what an administrator can do, while the role assignment defines who receives those permissions and where they apply. Admin Groups identify the administrators, Scope Groups define the users and devices they can manage, and Scope Tags can further restrict which Intune resources they can access.

**Result**

- Created an `Intune-App-Admins` security group for delegated application administration.
- Assigned Application Manager through an Intune role assignment.
- Scoped administration to dedicated `Intune-Lab-Users` and `Intune-Lab-Devices` groups.
- Learned that each Intune role requires its own assignment while administrative and scope groups can be reused.
- Recognized that permissions from multiple assignments are cumulative and should be scoped carefully.


## 2026-08-13 — Entra and Intune Use Separate RBAC Systems

**Context**

Microsoft documentation listed Entra administrative roles and Intune-specific roles together during the initial tenant setup. When searching Entra ID for Application Manager, I found Application Administrator instead, which initially made the role structure unclear.

**Lesson**

Microsoft Entra and Microsoft Intune maintain separate RBAC systems. Entra roles provide directory and tenant-level administrative permissions, while Intune roles provide granular permissions over endpoint-management functions.

**Result**

- Identified Intune Administrator, User Administrator, and Domain Name Administrator as Microsoft Entra roles.
- Identified Application Manager, Intune Role Administrator, and Policy and Profile Manager as Intune RBAC roles.
- Learned that similarly named roles across the two systems are not interchangeable.
- Established where each type of administrative role must be configured.
- Improved my understanding of how Microsoft separates tenant-wide administration from delegated Intune administration.
