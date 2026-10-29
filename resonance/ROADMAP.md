# Roadmap

Every phase after 0 changes production and starts only after the owner approves it.
Resource budgets are for Resonance additions only, on top of what the host already runs.

## Phase 0: Verify (read-only, now)

| # | Task | Done when |
|---|---|---|
| 0.1 | Run `scripts/audit-readonly.sh` on the server (or approve a live read-only session) | Output shared privately; AUDIT.md UNVERIFIED rows updated |
| 0.2 | Confirm where the compose file lives, Navidrome version, mounts, free space | Recorded (sanitized) in ARCHITECTURE.md |
| 0.3 | Confirm whether the music library has any second copy | Yes/no recorded; if no, D-004 becomes the first Phase 1 task |
| 0.4 | Owner approves this plan, client choice and scrobbling choice (D-006) | Approval in the project thread |

Budget: none. Risk: none (no writes). Rollback: not applicable.

## Phase 1: Foundation (approval required)

| # | Task | Change |
|---|---|---|
| 1.1 | Back up the compose file and `navidrome.db` before touching anything | Copy to the 6 TB disk with a date stamp |
| 1.2 | Enable Navidrome's built-in DB backup: `ND_BACKUP_PATH`, `ND_BACKUP_SCHEDULE` (daily), `ND_BACKUP_COUNT=7` | Compose env, restart |
| 1.3 | Mount the library read-only in Navidrome (`:ro`) if it is not | Compose volume |
| 1.4 | Publish Navidrome over tailnet HTTPS with `tailscale serve` on an HTTPS port not already used by other services on this host | Host Tailscale config |
| 1.5 | Install Amperfy on iPhone, connect over the tailnet HTTPS URL; run TESTING.md T1–T8 | Phone only |
| 1.6 | Add starter `.nsp` smart playlists in `Playlists/Smart` | New files in library (needs a writable path or a desktop copy) |
| 1.7 | Turn on the chosen scrobbler per D-006 | Navidrome user setting |
| 1.8 | Music library second copy if 0.3 found none (separate disk or offsite; tool per Homelab) | Homelab task, owner's decision |

Budget: 0 MB extra RAM, under 1 GB disk for DB backups.
Acceptance: TESTING.md T1–T10 pass; Navidrome web UI and existing clients still play.
Risks: wrong volume edit hides the library (mitigated by 1.1 and `docker compose config` before `up`); port clash on `tailscale serve`.
Rollback: restore the saved compose file and `docker compose up -d navidrome`; `tailscale serve --https=<port> off`; delete `.nsp` files.

## Phase 2: Import and lyrics

| # | Task |
|---|---|
| 2.1 | Create the Nextcloud "Music Inbox" outside the library; document the Windows, Mac and iPhone steps |
| 2.2 | Tagging workflow: Picard on desktop; decide whether Lidarr manual import moves files into the library |
| 2.3 | Create the private Resonance code repo (D-008) |
| 2.4 | Playlist matcher: Exportify CSV, Apple Music export, Takeout CSV → `.m3u` + unmatched report; dry run by default; unit tests |
| 2.5 | Lyrics fill with LRCGET/LRCLIB writing `.lrc` sidecars, tested on one album first |

Budget: matcher under 100 MB RAM while running, 0 at rest.
Acceptance: TESTING.md T11–T14; at least 85% of a Spotify playlist matches when its songs exist locally; zero audio files changed by the matcher.
Risks: duplicate albums from untagged files; false matches (mitigated by duration check and review report).
Rollback: delete generated `.m3u` files; lyrics sidecars are separate files and can be deleted by extension.

## Phase 3: Discovery and analytics

| # | Task |
|---|---|
| 3.1 | Use Phase 1 smart playlists for 2–4 weeks; record what is missing |
| 3.2 | Nightly mix job: Daily Mix 1–3, Discover Deep Cuts, Rediscover, from a DB copy plus cached artist similarity |
| 3.3 | Listening analytics as a static page on the tailnet |

Budget: under 150 MB RAM for under 2 minutes nightly; under 50 MB cache.
Acceptance: mixes regenerate nightly, contain no tracks played in the last 7 days unless rated 5, no artist more than 3 times per mix; job failure leaves yesterday's mixes in place.
Risks: external API rate limits (cache, run nightly only); stale mixes (job logs to Uptime Kuma push monitor).
Rollback: disable the cron line and delete the mix files.

## Phase 4: Interface polish

| # | Task |
|---|---|
| 4.1 | Evaluate Feishin for desktop and web |
| 4.2 | Only if gaps remain: a small Resonance web view for discovery, import review and unmatched tracks |

Budget: a web view under 100 MB RAM, behind `tailscale serve`, read-only to Navidrome.
Rollback: stop and remove the one container.
