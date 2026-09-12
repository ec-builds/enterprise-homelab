# Jellyfin Client Testing

This document records client validation testing performed across both the original and current deployments of the Media Services Platform.

## Overview

Client testing was conducted to verify accessibility, functionality, and usability across multiple devices and platforms used within the household.

Testing was performed during the original native Jellyfin 10.11.10 deployment and repeated following the migration to the current virtualized and containerized Jellyfin 12 platform. This provided an opportunity to verify that core client functionality remained operational following the architectural migration and major application version upgrade.

The objective was to confirm that media content could be reliably accessed from common client devices while maintaining separation between administrative and standard user access.

## Testing Evidence

The following screenshot shows the Jellyfin media library after configuration and validation testing.

![Jellyfin Library](./diagrams/jellyfin-library.png)

*Figure 1. Jellyfin media library successfully loaded during client validation testing.*

## Network Access

The Media Services Platform is hosted on the local network and currently operates over HTTP.

HTTP access is acceptable for the current environment because the service is intended for internal network use only and is not directly exposed to the public internet.

A DHCP reservation is configured on the router to ensure the media server consistently receives the same IP address. This simplifies administration, client configuration, and troubleshooting.

Users can access the platform using:

```text
http://media-server-lab.local:8096
```

This provides a consistent hostname for accessing the service without requiring users to manually enter the server's IP address.

## Browser Testing

The Jellyfin web interface was validated across multiple browsers.

| Test | Safari | Google Chrome | Microsoft Edge |
|---|:---:|:---:|:---:|
| Web interface loads | Pass | Pass | Pass |
| User authentication | Pass | Pass | Pass |
| Media library visibility | Pass | Pass | Pass |
| Media playback | Pass | Pass | Pass |
| Navigation and search | Pass | Pass | Pass |

No browser-specific issues were identified during testing.

## Roku Testing

Jellyfin-compatible applications were tested on the primary Roku television used for media consumption.

### Moonfin

Moonfin is currently the preferred Roku client for day-to-day media consumption. It provides a more polished client experience while continuing to use the existing Jellyfin server and media libraries.

Validation included:

- Successful connection to the Jellyfin server
- Standard user authentication
- Media library synchronization
- Media playback
- Navigation and browsing
- Stable operation during normal use

### Jellyfin

The official Jellyfin Roku application was also validated successfully and remains installed as a secondary client and fallback option.

Maintaining both clients provides an alternative access method if compatibility or application-specific issues affect the preferred client.

## macOS Testing

Moonfin was also installed and tested on a MacBook Pro.

Validation included:

- Successful connection and authentication
- Media library browsing
- Local media playback
- Offline media downloads
- Playback of previously downloaded content without an active network connection

Offline downloads were validated during air travel, confirming that downloaded media remained accessible without connectivity during a recent flight.

## User Access Model

Separate administrative and standard user accounts are maintained within Jellyfin.

### Standard User

Used for:

- Media browsing
- Media playback
- Offline downloads
- General household access

### Administrative User

Used only for:

- Server configuration
- Library management
- User administration
- System maintenance

Administrative access is separated from day-to-day media consumption, reducing unnecessary privileged access and applying the principle of least privilege at the application layer.

## Deployment Validation

Client testing has been performed against both major implementations of the Media Services Platform:

| Deployment | Server Model | Jellyfin Version | Client Validation |
|---|---|---|---|
| Original | Native Jellyfin service on standalone Debian | Jellyfin 10.11.10 | Browser and streaming-device playback validated |
| Current | Jellyfin container on Debian VM | Jellyfin 12 | Browser, Roku, Moonfin, and offline playback validated |

Repeating client testing after the migration confirmed that moving from the original native Jellyfin 10.11.10 deployment to the virtualized and containerized Jellyfin 12 platform did not disrupt normal media consumption.

## Outcome

Client validation confirmed that the Media Services Platform remains accessible across supported browsers and household streaming devices following its architectural migration.

Both Moonfin and the official Jellyfin application successfully interact with the current Jellyfin 12 deployment, with Moonfin serving as the preferred client and the official Jellyfin application retained as a fallback.

Offline download and playback testing also confirmed that supported clients can provide access to downloaded media when the server is temporarily unreachable, including during travel without network connectivity.

The testing establishes a functional baseline for validating client compatibility after future application, container, network, or infrastructure changes.
