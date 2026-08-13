## 2026-08-13 — Entra Roles and Intune Roles Are Separate RBAC Systems

**Context**

While configuring the Intune lab admin team, Microsoft documentation listed several required built-in roles together, including Intune Administrator, User Administrator, Application Manager, Intune Role Administrator, and Policy and Profile Manager. Some of these roles were not available in Microsoft Entra ID because the list combines roles from two separate RBAC systems.

**Lesson**

Microsoft Entra roles and Microsoft Intune roles are separate role-based access control systems. Entra roles provide tenant-level administrative permissions, while Intune RBAC roles provide granular permissions specifically within Intune. A role must be assigned from the administrative system where that role is defined.

**Result**

- Identified Intune Administrator, User Administrator, and Domain Name Administrator as Microsoft Entra roles.
- Identified Application Manager, Intune Role Administrator, and Policy and Profile Manager as Intune RBAC roles.
- Learned not to substitute similarly named Entra roles, such as Application Administrator, for Intune-specific roles such as Application Manager.
- Established a clearer understanding of least-privilege delegation across Entra ID and Intune.
- Reinforced the distinction between tenant-wide identity administration and granular endpoint-management permissions.
