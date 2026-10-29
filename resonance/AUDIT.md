# Resonance: read-only infrastructure audit (2026-10-29)

Scope: the ten first tasks from the project brief. Nothing on the server was changed.

Every finding carries one of three labels:

- **VERIFIED**: confirmed from a source named next to it (this repo, the private Rosetta repo, or vendor docs read on 2026-10-29).
- **UNVERIFIED**: needs the live server. Run `scripts/audit-readonly.sh` (read-only) or approve a live read-only session to confirm.
- **PROPOSED**: a recommendation. Nothing proposed has been done.

This repository is public (see the top-level README), so this folder never records addresses,
ports bound to the LAN, tailnet names, usernames, tokens or library contents.

---

## 1. Navidrome deployment

| Item | Status | Finding |
|---|---|---|
| Navidrome is installed | VERIFIED | Listed under Media Services in the top-level README. |
| Host | VERIFIED | Beelink Mini S, Intel N95 (4 cores), 8 GB RAM, 256 GB internal disk, 6 TB external disk, Ubuntu 24.04.4 LTS (README). |
| Runs in Docker | ASSUMED | The README says the Beelink is the Docker host and lists Navidrome with the other containers. No compose file is in any repo. |
| Compose file, image tag, version | UNVERIFIED | No deployment files are committed anywhere. |
| Volumes: `/music` (library) and `/data` (database, cache) | UNVERIFIED | Navidrome's defaults are `MusicFolder=./music`, `DataFolder=./data`; the database is `navidrome.db` inside DataFolder (Navidrome docs). The host paths are unknown. |
| Library is mounted read-only | UNVERIFIED | Navidrome supports a read-only music mount (docs). Recommended. |
| Lidarr shares the music folder | ASSUMED | Lidarr is installed; it normally writes into the same library Navidrome reads. |
| Free storage | UNVERIFIED | README records a past "high storage utilization" problem on this host, so free space should be checked before any import. |

## 2. Performance, backups, permissions, network

| Item | Status | Finding |
|---|---|---|
| RAM is the tightest resource | VERIFIED (by inventory) | 8 GB is shared by Jellyfin, Immich (+ PostgreSQL, Redis, ML), Nextcloud, Vaultwarden, the *arr stack, qBittorrent, NZBGet, Portainer, Uptime Kuma, plus Minecraft, Rosetta (capped at 300 MB) and Rosetta's browser worker (capped at 700 MB) per the Rosetta repo. |
| Server is on Wi-Fi | VERIFIED | Rosetta's PROJECT_HANDOFF.md. Matters for remote streaming of lossless files. |
| Actual CPU, RAM, swap, load | UNVERIFIED | Script section "resources". |
| Backups of Navidrome's database | UNVERIFIED | README says "backups for important application data" but names no tool or schedule, and lists "improve automated backup verification" and "document restoration procedures" as planned. Navidrome has a built-in backup (`Backup.Path`, `Backup.Schedule`, `Backup.Count`), off by default (docs). |
| Backups of the music files | UNVERIFIED, HIGH RISK | One 6 TB external disk is the only storage named. If it has no second copy, a single disk failure loses the library. |
| File ownership (PUID/PGID, read-only mounts) | UNVERIFIED | Script section "navidrome". |
| Remote access is Tailscale only | VERIFIED | README: services are not intentionally exposed publicly. |
| HTTPS | VERIFIED gap | README: HTTPS for browser services is planned, not done. Rosetta already uses `tailscale serve` for HTTPS on this host, so the pattern exists. |
| Navidrome's tailnet URL and port | UNVERIFIED | Not recorded (correctly, for a public repo). |
| Pi-hole on the phone's path | VERIFIED (exists) | Pi-hole on a Raspberry Pi 5; not relevant to playback unless it blocks lyrics or cover-art lookups. |

## 3. Library, formats, metadata, playlists, clients

All UNVERIFIED: no library information exists in any repo. The script counts files by
extension, size, embedded versus sidecar lyrics (`.lrc`), and `.m3u`/`.nsp` playlists, and
reports Navidrome's own counts from a copy of its database, without printing titles.

Navidrome facts (VERIFIED, docs): it plays anything ffmpeg decodes and transcodes on the fly;
lyrics come from `.ttml/.yaml/.elrc/.lrc/.srt/.txt` sidecars or embedded tags in that priority
(`LyricsPriority`); `.m3u` and `.nsp` files in the library are auto-imported
(`AutoImportPlaylists=true`, `PlaylistsPath` optional).

## 4. iPhone client comparison

Sources: navidrome.org/apps (read 2026-10-29), github.com/BLeeEZ/amperfy, Amperfy release notes.
"Not listed" means the listing does not claim it, not that it is missing.

| Client | Cost | Open source | Offline | CarPlay | Lyrics | Notes |
|---|---|---|---|---|---|---|
| **Amperfy** | Free | Yes, GPL-3.0 | Yes | Yes | Synced and unsynced, Subsonic servers (since v1.2.2) | Mature (1.8k stars, 1,100+ commits), scrobbling, gapless, replay gain, EQ, Siri, podcasts, also macOS |
| **AmpSonic** | Free | No | Yes | Yes | Synced | OpenSubsonic, AirPlay, EQ, Spotlight search, iPhone/iPad/Mac; newer, smaller track record |
| Substreamer | Free | Yes | Yes | Not listed | Not listed | iOS and Android |
| flo | Free | Yes | Yes | Not listed | Not listed | Navidrome-specific SwiftUI client, ListenBrainz/Last.fm |
| Arpeggi | Free (TestFlight) | No | Yes | Not listed | Not listed | iOS 17+, gapless, replay gain |
| Primuse, JellyBox | Free | Yes | Yes | Yes | Synced | Newer; worth a later look |
| play:Sub | Paid | No | Caching | Yes | Not listed | Long-standing |
| Narjo, Nautiline | Paid | No | Yes | Yes | Synced | Polished, paid; excluded by the free-first rule |

**PROPOSED: Amperfy as the primary client, AmpSonic as the fallback.** Amperfy is the only
option that is free, open source, mature, and claims all four must-haves (offline, CarPlay,
lyrics, Bluetooth via standard iOS playback). AmpSonic covers the same list but is closed source
and younger. Neither claim is accepted until the acceptance tests in TESTING.md pass on the
owner's iPhone and car. Bluetooth works through iOS's standard audio session in every listed
client; the test is lock-screen controls and resume after a call.

Lyrics need data: Navidrome serves lyrics but does not fetch them. Synced lyrics require `.lrc`
sidecars or embedded tags (see ROADMAP Phase 2).

## 5. Importing your own files

**PROPOSED** (reuses Nextcloud, which already runs; no new service):

1. Create a Nextcloud folder "Music Inbox" whose storage is on the 6 TB disk, **outside** the Navidrome library.
2. Windows and Mac: drop files into the Nextcloud desktop sync folder. iPhone: Files app → Nextcloud → Music Inbox.
3. Tag before it enters the library: MusicBrainz Picard (free, Windows/Mac) on the desktop, or later beets on the server in a run-once container.
4. Move tagged files into the library (Lidarr's manual import, if Lidarr owns the library, keeps one naming scheme). Navidrome picks them up on its next scan.

Why not upload straight into the library: untagged files create duplicate artists and albums,
and Navidrome's library mount should stay read-only. Alternative if Nextcloud is unsuitable:
Syncthing (free) into the same inbox; that is a new service, so it needs approval.

## 6. Playlist imports (song matching, no audio copying)

Principle: export the **list** of tracks from each service with the owner's own account, match
each row to a file already in the library, and write a Navidrome playlist. Unmatched rows go to
a report. No audio is downloaded from any subscription service.

| Service | Export route | Notes |
|---|---|---|
| Spotify | Exportify (free, uses your own Spotify login) → CSV with title, artist, album, ISRC | Best data quality; ISRC allows exact matches when files carry it |
| Apple Music | Mac Music app: File → Library → Export Playlist (text/XML); Windows: Apple Music app or iTunes | No ISRC; match on title, artist, duration |
| YouTube Music | Google Takeout → YouTube → playlists CSV | Gives video IDs, not clean metadata; titles must be looked up; lowest match rate |
| SoundCloud | No official playlist export; the public API is restricted | Manual or best-effort; many SoundCloud tracks are not in any local library |

Matching tools: SpotSonic (MIT, Go, Exportify CSV → Navidrome via Subsonic API, fuzzy match,
incremental) exists; importify was archived on 2026-07-23. **PROPOSED:** one small Resonance
script that reads all four export formats, matches ISRC → MusicBrainz ID → normalized
title+artist+duration, writes `.m3u` into a `Playlists/Imported` folder, and prints an unmatched
report. Writing files is simpler, reviewable and reversible (delete the file), and needs no
Navidrome credentials. SpotSonic stays the fallback if the script is not justified.

## 7. Built-in smart playlists and scrobbling first

VERIFIED (docs): Navidrome `.nsp` smart playlists are JSON rule files with about 90 fields
(play count, last played, loved, rating, date added, genre, year, lyrics, file path, custom
tags) and operators such as `inTheLast`, `notInTheLast`, `inPlaylist`. Scans re-import changes.
Scrobbling to ListenBrainz and Last.fm is built in and enabled per user.

This covers most of what a "discovery engine" means for one listener: Recently Added, On Repeat,
Forgotten Favorites, Never Played, Decades, Genre mixes, Rediscover. **PROPOSED:** ship these as
`.nsp` files in Phase 1 and build no custom engine until they have been used for a few weeks.

Scrobbling decision for the owner: ListenBrainz profiles are public and it produces free weekly
recommendation playlists; Last.fm is public too; a self-hosted scrobbler (Maloja) stays private
but adds a service. See DECISIONS.md D-006.

## 8. Recommendations, mixes, analytics, interface

**PROPOSED**, lightest first:

- **Mixes:** `.nsp` rules (Phase 1), then a nightly job that writes "Daily Mix 1–3" `.m3u` files from your own play history, ratings and artist similarity cached from ListenBrainz/Last.fm/MusicBrainz. Plain scoring, no machine learning; budget under 150 MB RAM for under 2 minutes a night.
- **Analytics:** read-only queries on a copy of Navidrome's database (top artists, hours per week, new versus repeat listening), rendered as a static page. ListenBrainz gives this for free if its public profile is acceptable.
- **Interface:** do not build an iPhone app (Apple developer fees and the CarPlay entitlement make it a poor trade). The phone interface is Amperfy. For desktop, evaluate Feishin (open source, modern Navidrome client) before any custom UI. A custom Resonance web view is justified only for what no client does: discovery dashboard, import review, unmatched tracks.

## 9. Separate GitHub repository?

**PROPOSED: not yet.** Phase 0 and 1 are documentation, `.nsp` files and configuration, which
belong next to the infrastructure they describe. Create a separate private repo when the first
Resonance code exists (the playlist matcher or the mix job in Phase 2), because the project rules
keep music application logic apart from shared Homelab services and this repo is public.

## 10. Roadmap

See ROADMAP.md (phases, budgets, acceptance tests, risks, rollback) and TESTING.md.
