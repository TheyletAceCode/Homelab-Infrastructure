# Testing

Results are recorded only from real runs, with date and device. Nothing below has run yet.

## Phase 0 checks

| ID | Check | Result |
|---|---|---|
| A1 | `bash -n scripts/audit-readonly.sh` (syntax) | PASS 2026-10-29 (cloud session; script not run against the server) |
| A2 | Script run on the server changes nothing (compare `ls -l` of DataFolder before and after) | Not run |

## Client acceptance (Phase 1, on the owner's iPhone)

| ID | Test | Pass when | Amperfy | AmpSonic |
|---|---|---|---|---|
| T1 | Connect at home and away over the tailnet HTTPS URL | Library loads in under 5 s | — | — |
| T2 | Download an album, enable airplane mode, play it | Plays fully with no network | — | — |
| T3 | CarPlay: browse playlists, play, skip, seek | All work from the car screen | — | — |
| T4 | Bluetooth: lock-screen and headset controls; resume after a phone call | Resumes at the same position | — | — |
| T5 | Synced lyrics on a track with an `.lrc` sidecar | Lines highlight in time | — | — |
| T6 | Switch Wi-Fi to cellular mid-song | Under 3 s gap or none | — | — |
| T7 | Scrobble or play count updates in Navidrome | Count increments | — | — |
| T8 | Smart playlist appears and updates after a scan | Contents match rules | — | — |

## Server acceptance (Phase 1)

| ID | Test | Pass when |
|---|---|---|
| T9 | Navidrome backup file appears after the scheduled time; a restore into a scratch container starts and shows the library | Both true |
| T10 | Existing web UI and any existing clients still play | No regression |

## Import (Phase 2)

| ID | Test | Pass when |
|---|---|---|
| T11 | File uploaded from Windows, Mac and iPhone reaches the inbox | All three arrive intact (checksum) |
| T12 | Tagged file appears in Navidrome under the correct album artist, no duplicate album | True |
| T13 | Matcher on a known playlist | ≥85% matched where songs exist; no false matches in a manual check of 20 rows |
| T14 | Matcher dry run | Writes nothing |
