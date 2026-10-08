# Lessons Learned


| Date | Summary | Context | Takeaway |
|---|---|---|---|
| 2026-07-24 | **Validate Generated VPN Configurations Before Customizing Them** | While configuring WireGuard on an ASUS router, the client configuration page presented both an Address field and a Server field. The Server field was initially assumed to require the VPN server's address, which prevented clients from connecting. Comparing the configuration against the default ASUS-generated values showed that both fields were expected to use the router-generated values. Restoring the default configuration established a known-good baseline before the VPN subnet was changed to align with the internal network design. | Validate a known-good, vendor-generated configuration before modifying network parameters based on assumptions about field names or expected behavior. Establishing a working baseline makes it easier to isolate configuration errors before introducing customization. Network addressing can then be changed deliberately to support cleaner routing, firewall rules, VLANs, and future segmentation. |
