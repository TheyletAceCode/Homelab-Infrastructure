# Handoff

## 2026-10-29: Initialization and read-only audit

Done:
- Read this repo (README only; no compose or config files are committed) and the private Rosetta repo for host facts.
- Researched iPhone clients, Navidrome smart playlists, scrobbling, backup options and playlist-import tools.
- Wrote this folder and `scripts/audit-readonly.sh` on branch `claude/project-thread-o5ksrz`. Nothing on the server was touched.

Waiting on the owner:
1. Run the audit script on the server, or approve a live read-only session.
2. Approve or change the plan, the client (D-002) and the scrobbling choice (D-006).

Next session: fold the script output into AUDIT.md and ARCHITECTURE.md (sanitized), then
prepare Phase 1 as a reviewed change list with the exact compose diff and rollback commands.

Known gaps: Navidrome version, volumes, free space, library size and formats, existing
playlists and clients, backup coverage. All UNVERIFIED.
