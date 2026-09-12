# Jellyfin Client Testing

This document records client validation testing performed following the deployment and modernization of the Media Services Platform.

## Overview

Client testing was conducted to verify accessibility, functionality, and usability across multiple devices and platforms used within the household.

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

The Jellyfin application was tested on the primary Roku television used for media consumption.

### Validation Performed

- Successfully connected to the Jellyfin server
- Authenticated using a standard user account
- Verified media library synchronization
- Confirmed media playback functionality
- Confirmed stable operation during normal use

The Roku client is currently the primary method used to access the Media Services Platform.

## User Access Model

Separate administrative and standard user accounts are maintained within Jellyfin.

### Standard User

Used for:

- Media browsing
- Media playback
- General household access

### Administrative User

Used only for:

- Server configuration
- Library management
- User administration
- System maintenance

Administrative access is separated from day-to-day media consumption, reducing unnecessary privileged access and applying the principle of least privilege at the application layer.

## Outcome

Client validation confirmed that the Media Services Platform is accessible across supported browsers and household streaming devices, media playback functions as expected, and standard users can consume media without administrative privileges.

The testing established a functional baseline for validating client compatibility after future application, container, network, or infrastructure changes.
