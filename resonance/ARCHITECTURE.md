# Architecture

Labels: **VERIFIED** (source named in AUDIT.md), **UNVERIFIED** (needs the live server), **PROPOSED**.

## Current

| Component | Role | Status |
|---|---|---|
| Beelink Mini S, N95, 8 GB RAM, Ubuntu 24.04.4 | Docker host for all services | VERIFIED |
| 6 TB external disk | Application and media data | VERIFIED (exists); free space UNVERIFIED |
| Navidrome | Music server, Subsonic/OpenSubsonic API | VERIFIED (installed); version, volumes, config UNVERIFIED |
| Lidarr | Music library management | VERIFIED (installed); relationship to the Navidrome library UNVERIFIED |
| Nextcloud | Private file storage | VERIFIED (installed) |
| Jellyfin | Video, may also index music | VERIFIED (installed) |
| Tailscale | Only remote access path | VERIFIED |
| `tailscale serve` | HTTPS on the tailnet; already used by Rosetta on this host | VERIFIED |
| Backups | "important application data" | Tool, schedule and coverage UNVERIFIED |
| iPhone client in use | — | UNVERIFIED |

## Proposed (nothing here is deployed)

| Component | Kind | Where | RAM budget |
|---|---|---|---|
| Amperfy on iPhone (AmpSonic fallback) | Existing app | Phone | 0 on server |
| Navidrome over `tailscale serve` HTTPS | Config | Host | 0 |
| Navidrome built-in DB backup (`Backup.*`) | Config | Navidrome | 0 |
| `.nsp` smart playlists | Files in `Playlists/Smart` | Library | 0 |
| Music Inbox | Nextcloud folder outside the library | 6 TB disk | 0 |
| Playlist matcher | Run-on-demand script, writes `.m3u` | Desktop or one-shot container | <100 MB while running |
| Nightly mix job | Cron one-shot, reads a DB copy, writes `.m3u` | Host | <150 MB for <2 min |
| Lyrics fill | Desktop tool (e.g. LRCGET, LRCLIB) writing `.lrc` sidecars | Desktop | 0 |
| Desktop client | Feishin (evaluate) | Desktop | 0 |

## Boundaries

- Homelab owns the host, Docker, Tailscale, backups and security.
- Resonance owns playlists, mixes, import and client choice.
- Resonance reads Navidrome's database only from a copy; it writes only playlist files.
- Resonance code, when it exists, lives in its own private repo (DECISIONS D-008).
