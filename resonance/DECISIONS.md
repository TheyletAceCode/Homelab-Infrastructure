# Decisions

Status: Proposed (awaiting owner approval), Accepted, or Rejected.

| ID | Decision | Reason | Status |
|---|---|---|---|
| D-001 | Reuse the existing Navidrome; no new server or replacement | Project rule; Navidrome already provides streaming, smart playlists, scrobbling, lyrics serving | Accepted (owner brief) |
| D-002 | Amperfy as primary iPhone client, AmpSonic as fallback | Only free, open-source (GPL-3.0), mature client claiming offline, CarPlay and synced lyrics | Proposed |
| D-003 | Remote access only through Tailscale with `tailscale serve` HTTPS | Already in place for Navidrome (verified 2026-10-29); no public exposure | Accepted (existing) |
| D-004 | Keep originals on their source device until backups leave the media disk | Backups and media share one disk (verified) | Proposed |
| D-005 | Use Navidrome `.nsp` smart playlists before any custom engine | Covers most mix types at zero cost | Proposed |
| D-006 | Scrobbling: choose ListenBrainz (public, free recommendations), Last.fm (public), Maloja (private, new service) or none | Privacy versus free recommendations; owner's call | Open |
| D-007 | Import through an `_inbox` staging folder, report duplicates, tag, then copy into the library | Keeps the library clean and Navidrome's mount read-only | Proposed |
| D-008 | No separate repo now; create a private Resonance code repo when the first code is written (Phase 2) | Docs fit here; this repo is public and app logic stays separate from Homelab | Proposed |
| D-009 | Playlist import by matching exported track lists to owned files; never download subscription audio | Legal and technical constraint | Accepted (owner brief) |
| D-010 | Matcher writes `.m3u` files instead of calling the Subsonic API | Reviewable, reversible, needs no credentials | Proposed |
| D-011 | No custom iPhone app | Developer fees and CarPlay entitlement; existing clients meet the needs | Proposed |
| D-012 | Mix job and recommendations wait until the library has music and a few weeks of history | Library is empty (verified 2026-10-29) | Proposed |
| D-013 | beets in copy mode as the organizer; originals kept in `_originals`; medium/low confidence to review | Accurate tagging without risking source files | Proposed |
| D-014 | No SoundCloud API (needs paid Artist Pro); use oEmbed metadata and artist-enabled downloads only | No new costs | Proposed |
| D-015 | Spotify via own Development Mode app only if the owner has Premium; otherwise Spotify's data export | API rules since 2026-03-09 | Open |
| D-016 | Tubly files accepted only as files the owner is entitled to, always reviewed unless strongly matched | YouTube terms; weak metadata | Proposed |
| D-017 | Defer AudioMuse-AI and mood playlists | Needs 8 GB RAM + PostgreSQL + Redis; 2.7 GB free | Proposed |
