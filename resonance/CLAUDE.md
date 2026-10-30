# Resonance: notes for AI sessions

- Read README.md, then HANDOFF.md, DECISIONS.md and ROADMAP.md. AUDIT.md has the evidence.
- This repo is public. Never write addresses, ports bound to the LAN, tailnet names, usernames, tokens, `.env` values or library contents here.
- Label claims VERIFIED (with source), UNVERIFIED or PROPOSED. Never claim a test passed without a recorded run in TESTING.md.
- Read-only audits, docs and dev-branch changes are fine. Production changes (compose, Tailscale, Navidrome settings), deleting or moving music, credentials, new services, public exposure and paid services need the owner's approval in the thread.
- Reuse Navidrome and existing Homelab services; do not rebuild them. Keep Resonance additions under 300 MB RAM.
- Back up the compose file and `navidrome.db` before any approved change; every change ships with its rollback.
- Rosetta integration is optional; playback must never depend on it.
- Give PowerShell for Windows, zsh/bash for Mac, bash for the server.
