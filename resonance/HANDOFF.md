# Handoff

## 2026-10-29: Initialization and live read-only audit

Done:
- Docs in this folder (PR #1 on Homelab-Infrastructure, not merged).
- Live read-only audit on the server (results in AUDIT.md sections 1–2). Nothing changed.

Key facts:
- Navidrome 0.64.2 runs fine, served privately over `tailscale serve`; library mount is read-only.
- **The library is empty** (0 songs). No audio found on the server's data disk or home folder.
- Amperfy is installed on the iPhone but has never connected.
- RAM is tight (2.7 GB available, swap in use). Backups exist but sit on the media disk.

Waiting on the owner:
1. Where the music files are today.
2. Approval of the audit and architecture (checkpoint A in AUDIT.md section 10).

Next session: fix the Amperfy connection, then checkpoint B (staging folder and first test album).

## 2026-10-30: Upgrade 2.0 plan

- Wrote UPGRADE_2_PLAN.md (audit delta, architecture, sequence, first safe tasks). Nothing deployed.
- Live re-check pending: the server session disconnected; owner asked to reconnect.
- Waiting on owner: plan approval, private `resonance` repo, Spotify Premium yes/no, AcoustID account, off-disk backup target.
