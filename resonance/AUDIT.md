# Resonance: read-only audit and architecture (2026-10-29)

Answers the ten items of the owner's first assignment. Nothing on the server was changed: the
live checks ran read-only on the server on 2026-10-29 and used a temporary copy of the
database, since deleted.

Labels: **VERIFIED** (seen on the live server or in vendor docs, source named),
**UNVERIFIED** (not yet checked), **PROPOSED** (recommendation, not done).

This repository is public: hostnames, tailnet names, tailnet ports and credentials are left out on purpose.

---

## 1. Infrastructure health and free space (VERIFIED, live)

| Item | Finding |
|---|---|
| Navidrome | 0.64.2, image `deluan/navidrome:latest`, restart `unless-stopped`, runs as 1000:1000, 38 MB RAM |
| Deployment | `~/media-server/docker-compose.yml`; env-only config (`ND_SCANSCHEDULE`, `ND_LOGLEVEL`, `ND_SESSIONTIMEOUT`, `ND_MUSICFOLDER`, `ND_DATAFOLDER`, `ND_CONFIGFILE`, `ND_PORT`); no `navidrome.toml` |
| Mounts | `~/media-server/config/navidrome` → `/data` (rw, holds `navidrome.db`); `/mnt/data/media/music` → `/music` (**read-only**, good) |
| **Library** | **Empty.** The music folder has no files; the database has 0 songs, 0 albums, 0 artists, 0 playlists, 1 user. Last scan 2026-10-27. No audio files anywhere under `/mnt/data` or the home folder. |
| Music disk | `/dev/sdb1`, ext4, 5.5 TB, **1,122 GB free (79% used)** |
| System disk | 98 GB, **22 GB free (78% used)** |
| Disk health | UNVERIFIED: `smartctl` is not installed |
| CPU / load | 4 cores, load average 0.7, uptime 2 days |
| **RAM** | 7.5 GB total, **2.7 GB available, swap 2.4 of 4 GB in use**. Largest users: Minecraft 834 MB, Jellyfin 651 MB, qBittorrent 430 MB, then Dispatcharr, Immich, Sonarr, Bazarr, Radarr, Seerr, Prowlarr |
| Network exposure | Navidrome listens on `127.0.0.1` only; reached through `tailscale serve` HTTPS on the tailnet (private, not public) |
| Tailscale | 1.104.1; `tailscale serve` already publishes 21 HTTPS ports, one of them for Navidrome |
| Backups | Daily cron `~/homelab/backup/backup.sh`, last run 2026-10-29, includes Navidrome config and DB. **Writes to `/mnt/data/backups` on the same disk as the media.** No restic, borg, rclone or kopia; no offsite or second-disk copy |
| Shared mounts | Jellyfin mounts all of `/mnt/data/media` rw (sees music). Lidarr mounts all of `/mnt/data` rw and is **stopped** |

Health verdict: the server is healthy enough for Navidrome (38 MB). The real constraints are
memory pressure (swap in use), backups on the same disk, and an empty library.

## 2. Existing functionality inventory

VERIFIED on the live server (Navidrome 0.64.2 advertises these OpenSubsonic extensions):
`songLyrics` (v1, v2), `transcoding`, `transcodeOffset`, `playbackReport`, `indexBasedQueue`,
`topSongsByArtistId`, `formPost`.

VERIFIED from Navidrome docs: smart playlists (`.nsp`), auto-import of `.m3u`/`.nsp`, lyrics from
sidecar files and embedded tags, built-in DB backup (`Backup.*`), scheduled scans, sharing,
ListenBrainz and Last.fm scrobbling, on-the-fly transcoding.

Currently set: scan schedule (env present), port, log level, session timeout. On defaults:
Last.fm/ListenBrainz (no keys or tokens), `Backup.*` (off), sharing, transcoding.

Clients seen in the DB: only the Navidrome web UI (2 player entries). **Amperfy is installed
on the iPhone but has never connected successfully** (no Amperfy player row).

### Compatibility matrix (Navidrome 0.64.2 + Amperfy on iPhone)

Key: **Available** = works today · **Config** = turn on/set up, no new service · **New** = small
Resonance feature needed · **Restricted** = limited by platform or API · **Not rec.** = not
recommended. "Verify" = claimed by the vendor, still to test on your iPhone or car.

| Feature | Status | Notes |
|---|---|---|
| Stream at home and away | Config | Tailscale on the iPhone + Amperfy pointed at the tailnet HTTPS URL |
| True offline playback | Available (verify) | Amperfy offline mode |
| Manual song/album/playlist downloads | Available (verify) | Amperfy |
| Auto-download favorites or selected mixes | Verify | Check Amperfy settings; if missing, pin the mix playlist and download it |
| Smart caching, storage quota, Wi-Fi-only | Verify | Check Amperfy settings; record what exists in TESTING.md |
| Resume interrupted downloads | Verify | Test T2b |
| Offline artwork, metadata, lyrics | Verify | Amperfy stores downloaded metadata; offline lyrics to test |
| Sync history and playlist changes after reconnect | Verify | Amperfy scrobble cache; test T7b |
| Deleted or changed server files handled | Verify | Test after a rescan |
| CarPlay | Available (verify) | Amperfy uses native CarPlay templates |
| Bluetooth, lock screen, background playback | Available (verify) | Standard iOS audio session |
| Synced lyrics | Config | Server supports `songLyrics`; Amperfy shows synced lyrics since v1.2.2; needs `.lrc` files or embedded lyrics |
| Artwork, tags, favorites, ratings, playlists | Available | Navidrome + Amperfy |
| Listening history, most/recently played | Available | Navidrome play counts; smart playlists |
| Skipped songs | New | Navidrome does not store skips; `playbackReport` may give data (to check); otherwise a Resonance job infers skips from scrobble gaps |
| Similar songs, related artists, artist radio | Config | Navidrome's Last.fm agent needs a free Last.fm API key; ListenBrainz optional |
| Smart shuffle, autoplay | Verify | Amperfy shuffle; autoplay beyond the queue depends on client |
| Daily Mixes, Discover Weekly style | New | Nightly job writing playlists (section 7) |
| Genre, decade, artist mixes | Config | `.nsp` smart playlists |
| Mood and activity mixes | Restricted | Needs mood tags; local audio analysis is heavy for this host. Use Last.fm/MusicBrainz tags where present |
| "Why recommended" explanations | New | Playlist comment lines from the mix job |
| Import own MP3/FLAC/M4A/AAC | Config | Staging folder + tagging (section 4) |
| Spotify/Apple/YouTube/SoundCloud playlist import | New / Restricted | Match exported lists to owned files (section 6) |
| Download audio from streaming services | Not rec. | Forbidden by their terms and the project rules |
| Custom iPhone app | Not rec. | CarPlay audio entitlement, signing and a paid developer account; Amperfy already covers it |
| Second music server, AI model, reverse proxy | Not rec. | No practical need shown |

## 3. Best free iPhone client and alternative

**Amperfy** (primary, already installed): free, GPL-3.0, mature, offline mode, CarPlay,
synced and unsynced lyrics for Subsonic servers (release notes v1.2.2), scrobbling, gapless,
replay gain, EQ. **AmpSonic** (alternative): free, closed source, offline, CarPlay, AirPlay,
synced lyrics, newer. Others reviewed (Substreamer, flo, Arpeggi, Primuse, JellyBox,
play:Sub, Narjo, Nautiline): see the previous version of this audit in git history; paid ones
are excluded. Nothing is claimed working on your phone until TESTING.md passes.

First fix: Amperfy has never reached the server. Likely causes, in order: Tailscale is off on
the phone, the URL is the LAN address or misses the HTTPS port, or the wrong API type is
picked (choose Subsonic). The tailnet URL is in the project thread, not in this repo.

## 4. Music-import workflow (PROPOSED)

```
Mac / gaming PC / iPhone ──copy──▶ /mnt/data/media/_inbox (staging, outside the library)
                                       │  report: duplicates (checksum + tags), missing tags
                                       ▼  owner reviews the report
                             tag with MusicBrainz Picard (desktop) or beets (one-shot, server)
                                       ▼  copy, never move or overwrite
                             /mnt/data/media/music/Artist/Album/  ──▶ Navidrome scan
```

- Transfer: Windows and Mac use the existing Nextcloud sync (or `scp`/`rsync` over Tailscale); iPhone uses the Files app to Nextcloud. Files land in `_inbox`, never directly in the library.
- Originals stay on the source device until an offsite or second-disk copy exists, because the server's backups share the media disk.
- Duplicates: SHA-256 of the audio file plus a normalized artist+album+title+duration key; matches go to a report, nothing is deleted.
- Rescans: Navidrome already has a scan schedule; confirm its value and trigger a manual scan after each import.
- Disk: 1,122 GB free fits roughly 30,000 FLAC tracks or 120,000 MP3s at typical sizes. Staging needs free space equal to one import batch.

## 5. Offline, lyrics, CarPlay, remote access: feasibility

| Area | Feasible? | What it takes |
|---|---|---|
| Remote access | Yes, today | Tailscale is already serving Navidrome over HTTPS on the tailnet; the iPhone needs Tailscale on (VPN On Demand keeps it up) |
| Offline | Yes | Amperfy downloads; iPhone storage per hour of music is about 400 MB for FLAC, 145 MB for 320 kbps MP3, 60 MB for 128 kbps; downloading transcoded files saves space (verify the Amperfy setting) |
| Lyrics | Yes, needs data | `.lrc` sidecars fetched from LRCLIB with LRCGET (free, open source, desktop) into the staging copy; Navidrome serves them |
| CarPlay | Yes (verify) | Amperfy native CarPlay; Tailscale must stay connected or music downloaded |
| Network | OK | Server is on Wi-Fi; one FLAC stream is about 1 Mbit/s; set Amperfy to transcode on cellular if needed |

## 6. Playlist integration limitations

| Service | Permitted export | Limitation |
|---|---|---|
| Spotify | Exportify with your own login → CSV with ISRC | Best match quality; read-only, nothing written back |
| Apple Music | Music app on Mac: File → Library → Export Playlist | No ISRC; match on title, artist, duration |
| YouTube Music | Google Takeout playlists CSV | Video IDs only, titles need lookup; weakest matches |
| SoundCloud | No official playlist export; API access restricted | Manual list; many tracks will not exist locally |

All imports are one-way and read-only toward the services. Matching: ISRC → MusicBrainz ID →
normalized title+artist with ±3 s duration. Output: a `.m3u` playlist plus an unmatched report.
Existing tool SpotSonic (MIT) covers Spotify only; the Resonance matcher would cover all four.

## 7. Recommendation-engine architecture (PROPOSED)

Stage 1 (no new code): `.nsp` smart playlists (Recently Added, On Repeat, Forgotten Favorites,
Never Played, decades, genres) and Navidrome's similar-artist data from a free Last.fm key.

Stage 2 (small companion job, only after a few weeks of listening data): a nightly one-shot
container that copies `navidrome.db`, scores tracks on favorites, replay count, recency,
inferred skips, genre and artist similarity (cached from Last.fm/ListenBrainz/MusicBrainz),
playlist co-occurrence, and writes Daily Mix 1–3 and a Discover playlist as `.m3u` with a
"why" note per track. Only locally playable songs go in mixes; external suggestions go to a
separate text report. No database server, no AI model. Budget: under 150 MB RAM for under
2 minutes a night (needs a writable playlists folder; the library mount stays read-only).

With an empty library this stage is not useful yet: recommendations need a library and
listening history first.

## 8. UI design proposal (PROPOSED)

Use Amperfy for iPhone and CarPlay; build no custom app. Map the requested screens to it:
Home (Amperfy home with pinned Daily Mixes), Discover (mix playlists), Search, Library,
Playlists, Downloads, Now Playing with lyrics, Settings. Listening Activity has no client
screen; it becomes a small read-only web page on the tailnet in a later phase, styled black
with orange/red accents, only if wanted. Desktop: evaluate Feishin (open source) first.

## 9. Prioritized development tasks

1. **Locate the music** (owner): where the files are today.
2. Connect Amperfy to the tailnet URL and play one test album.
3. Create `_inbox` staging folder; import a first test album; scan; run client tests.
4. Move backups off the media disk (second disk, another computer, or offsite), or at least keep originals on their source device.
5. Enable Navidrome's built-in DB backup, a free Last.fm key, and starter `.nsp` playlists.
6. Bulk import with duplicate report and tagging.
7. Lyrics fill with LRCGET.
8. Playlist matcher (new private repo at that point).
9. Nightly mix job after a few weeks of history.
10. Optional Listening Activity page.

## 10. Tests and approval checkpoints

Tests are in TESTING.md; iPhone and car tests stay **pending** until you run them.

| Checkpoint | Needs your approval for |
|---|---|
| A | This audit and architecture |
| B | Creating `_inbox` and copying the first album into the library (adds files, deletes nothing) |
| C | Compose changes: `Backup.*`, Last.fm key, writable playlists folder (backup of compose and DB first) |
| D | Any change to where backups go |
| E | Bulk import |
| F | New private repo and the companion mix job |
