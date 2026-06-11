# Troubleshooting

This document records issues encountered during the deployment and operation of the Media Services Platform, along with the troubleshooting process and final resolution.

---

## Media Quality Degradation During Playback

### Issue

Some media files appeared noticeably lower quality when streamed through Jellyfin compared to the original files stored on the NAS.

### Symptoms

- Reduced image clarity during playback
- Visible quality loss compared to the source files
- Issue affected specific media files but not all content

### Investigation

The original files were compared against the streamed versions using VLC Media Player.

The following validation steps were performed:

- Reviewed codec information for the original media files
- Compared source file properties with the playback stream
- Verified that the source files on the NAS were not degraded
- Confirmed that the quality loss occurred during playback rather than storage

### Root Cause

The affected files were stored in MKV containers using codecs that were not optimally supported by the client devices.

As a result, Jellyfin was required to transcode the media during playback.

The transcoding process introduced quality degradation and increased resource utilization.

### Resolution

The affected media files were re-encoded using HandBrake.

Changes included:

| Component | Original | Updated |
|------------|------------|------------|
| Video | Unsupported client codec | H.264 |
| Audio | Original audio format | AC3 passthrough |
| Container | MKV | MKV |

The updated files were imported back into the library and retested.

### Validation

Following conversion:

- Playback quality matched the original source files
- Visual clarity improved significantly
- Client devices were able to play content without problematic transcoding
- Streaming performance improved

### Lessons Learned

- Container format and codec are separate concepts
- Client compatibility has a significant impact on playback quality
- VLC is useful for validating codec and media properties
- Direct Play generally provides better quality and performance than unnecessary transcoding
