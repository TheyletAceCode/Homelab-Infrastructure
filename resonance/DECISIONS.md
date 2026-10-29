# Decisions

Status: Proposed (awaiting owner approval), Accepted, or Rejected.

| ID | Decision | Reason | Status |
|---|---|---|---|
| D-001 | Reuse the existing Navidrome; no new server or replacement | Project rule; Navidrome already provides streaming, smart playlists, scrobbling, lyrics serving | Accepted (owner brief) |
| D-002 | Amperfy as primary iPhone client, AmpSonic as fallback | Only free, open-source (GPL-3.0), mature client claiming offline, CarPlay and synced lyrics | Proposed |
| D-003 | Remote access only through Tailscale with `tailscale serve` HTTPS | Matches Homelab model; HTTPS without public exposure; already used on this host | Proposed |
| D-004 | Second copy of the music library before any bulk import | One 6 TB disk is the only storage named | Proposed |
| D-005 | Use Navidrome `.nsp` smart playlists before any custom engine | Covers most mix types at zero cost | Proposed |
| D-006 | Scrobbling: choose ListenBrainz (public, free recommendations), Last.fm (public), Maloja (private, new service) or none | Privacy versus free recommendations; owner's call | Open |
| D-007 | Import own files through a Nextcloud inbox and tag before they enter the library | Reuses Nextcloud; keeps the library clean and Navidrome read-only | Proposed |
| D-008 | No separate repo now; create a private Resonance code repo when the first code is written (Phase 2) | Docs fit here; this repo is public and app logic stays separate from Homelab | Proposed |
| D-009 | Playlist import by matching exported track lists to owned files; never download subscription audio | Legal and technical constraint | Accepted (owner brief) |
| D-010 | Matcher writes `.m3u` files instead of calling the Subsonic API | Reviewable, reversible, needs no credentials | Proposed |
| D-011 | No custom iPhone app | Developer fees and CarPlay entitlement; existing clients meet the needs | Proposed |
