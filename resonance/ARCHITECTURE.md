# Architecture

Labels: **VERIFIED** (source named in AUDIT.md), **UNVERIFIED** (needs the live server), **PROPOSED**.

## Current

| Component | Role | Status |
|---|---|---|
| Beelink Mini S, N95, 8 GB RAM, Ubuntu 24.04.4 | Docker host for all services | VERIFIED |
| 5.5 TB media disk (ext4) | Application and media data, also holds backups | VERIFIED: 1,122 GB free; health UNVERIFIED (no smartctl) |
| Navidrome 0.64.2 | Music server, OpenSubsonic API; library mounted read-only; DB in its config folder | VERIFIED (live 2026-10-29). Library is EMPTY |
| Lidarr | Music library management | VERIFIED: stopped; mounts the whole data disk rw |
| Nextcloud | Private file storage | VERIFIED (installed) |
| Jellyfin | Video; mounts the whole media folder rw, so it sees music | VERIFIED |
| Tailscale | Only remote access path | VERIFIED |
| `tailscale serve` | HTTPS on the tailnet; already publishes Navidrome and about 20 other services | VERIFIED |
| Backups | Daily cron script incl. Navidrome config and DB | VERIFIED; same disk as media, no offsite copy |
| iPhone client | Amperfy installed | VERIFIED: has never connected (no player record) |

## Proposed (nothing here is deployed)

| Component | Kind | Where | RAM budget |
|---|---|---|---|
| Amperfy on iPhone (AmpSonic fallback) | Existing app | Phone | 0 on server |
| Navidrome built-in DB backup (`Backup.*`) | Config | Navidrome | 0 |
| `.nsp` smart playlists | Files in `Playlists/Smart` | Library | 0 |
| `_inbox` staging folder | Folder outside the library, fed by Nextcloud, scp or rsync | Media disk | 0 |
| Playlist matcher | Run-on-demand script, writes `.m3u` | Desktop or one-shot container | <100 MB while running |
| Nightly mix job | Cron one-shot, reads a DB copy, writes `.m3u` | Host | <150 MB for <2 min |
| Lyrics fill | Desktop tool (e.g. LRCGET, LRCLIB) writing `.lrc` sidecars | Desktop | 0 |
| Desktop client | Feishin (evaluate) | Desktop | 0 |

## Boundaries

- Homelab owns the host, Docker, Tailscale, backups and security.
- Resonance owns playlists, mixes, import and client choice.
- Resonance reads Navidrome's database only from a copy; it writes only playlist files.
- Resonance code, when it exists, lives in its own private repo (DECISIONS D-008).
