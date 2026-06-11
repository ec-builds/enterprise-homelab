# 📚 Lessons Learned

This document captures key lessons, observations, and takeaways from building and deploying the Media Services Platform.

The goal of this project was not only to deploy a functional media server, but also to gain hands-on experience with Linux administration, storage integration, service management, documentation, and troubleshooting.

---

## Linux Administration Is Learned Through Repetition

Many Linux concepts that initially seemed unfamiliar became significantly easier through repeated use.

Examples include:

- Navigating the Linux filesystem
- Managing services with systemd
- Editing configuration files
- Installing software through package repositories
- Verifying system status through command-line tools

The most valuable learning occurred while performing actual tasks rather than reading documentation alone.

---

## Documentation Is Part of the Project

Initially, documentation felt like a separate task from building the server.

Over time it became clear that documentation is part of the build process itself.

Benefits included:

- Creating repeatable deployment procedures
- Simplifying troubleshooting
- Improving understanding of system architecture
- Providing a recovery reference if the system needed to be rebuilt

Maintaining documentation throughout the project was significantly easier than attempting to recreate steps later.

---

## Service Accounts Improve Security

The project introduced the concept of dedicated service accounts.

Rather than granting Jellyfin access using an administrative NAS account, a dedicated read-only service account was created specifically for media access.

Benefits included:

- Reduced permissions
- Improved security
- Easier auditing
- Better separation of responsibilities

This reinforced the principle of least privilege.

---

## Storage and Applications Should Be Separated

One of the most important architectural lessons was separating media storage from application services.

The NAS stores media content while Jellyfin provides access to that content.

Benefits included:

- Centralized storage management
- Simplified application deployment
- Easier recovery and migration
- Reduced risk of accidental modification

The read-only mount configuration further strengthened this separation.

---

## Container Formats and Codecs Are Different

A valuable troubleshooting exercise involved investigating media quality issues.

Initially, some media appeared lower quality when streamed through Jellyfin.

Investigation revealed that:

- Container formats (MKV, MP4) do not determine playback quality
- Video and audio codecs determine compatibility
- Unsupported codecs may trigger transcoding
- Transcoding can affect quality and increase resource usage

Using VLC to inspect media properties and compare playback behavior helped identify the root cause.

Re-encoding affected files to H.264 with compatible audio formats improved playback quality and reduced transcoding requirements.

---

## Validation Is Just As Important As Deployment

Successfully installing software does not necessarily mean the solution is operational.

Additional testing was required to verify:

- Browser compatibility
- Roku compatibility
- Network accessibility
- Service startup after reboot
- Power-loss recovery behavior

Validation testing provided confidence that the platform would function reliably during normal use.

---

## Existing Hardware Is Often Good Enough

The project demonstrated that practical Linux administration and self-hosted services can be learned using modest hardware.

The platform was deployed on a repurposed Late 2014 Mac Mini with:

- Intel Core i5 processor
- 4 GB RAM
- 256 GB SSD

Despite the system's age, it successfully supported Debian, Jellyfin, SMB storage integration, and multiple client devices.

This reinforced the idea that learning infrastructure concepts does not require enterprise-grade hardware.

---

## Understanding the Commands Matters

Following documentation successfully installs software, but understanding the commands provides significantly greater value.

The Jellyfin repository configuration process introduced concepts such as:

- Environment variables
- Command substitution
- File redirection
- Repository management
- Package signing and trust

While not every command was fully understood immediately, researching and experimenting with them improved overall confidence in Linux administration.

---

## Small Projects Build Foundational Skills

Although the Media Services Platform is a relatively simple deployment, it exposed concepts used throughout enterprise environments:

- Operating system deployment
- Package management
- Service management
- Storage integration
- Security principles
- Documentation practices
- Troubleshooting methodology

The project provided a foundation for future work involving virtualization, monitoring, automation, backup systems, and cloud technologies.

---

## Future Improvements

Areas identified for future exploration include:

- Proxmox virtualization
- Automated backups
- Infrastructure monitoring
- Configuration management
- Containerization
- Hardware transcoding
- Disaster recovery testing

These topics build naturally upon the foundation established during this project.

---

## Final Reflection

The most important lesson from this project was that building and documenting a working system provides a deeper understanding than studying concepts in isolation.

Deploying the Media Services Platform transformed several previously theoretical topics into practical skills and established a foundation for future infrastructure and automation projects.
