#!/usr/bin/env bash
# Resonance read-only audit for the Navidrome host.
# Changes nothing: it reads container metadata, disk and memory stats, counts files,
# and queries a temporary COPY of Navidrome's database. It never prints environment
# variable values, passwords or song titles.
#
# Usage on the server:  bash audit-readonly.sh [container-name]   (default: navidrome)
# The output can contain host paths and your tailnet address: share it privately,
# never commit it to this public repository.
set -u
C="${1:-navidrome}"
section() { printf '\n===== %s =====\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

section "host"
uname -srm; lsb_release -ds 2>/dev/null; uptime
section "resources"
nproc; free -h; swapon --show 2>/dev/null
section "disks"
df -hT -x tmpfs -x devtmpfs -x squashfs -x overlay
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL 2>/dev/null

section "containers (name, image, status)"
if have docker; then
  docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || echo "docker needs sudo: re-run with sudo"
  section "container memory and CPU right now"
  docker stats --no-stream --format '{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}' 2>/dev/null
else
  echo "docker not found"
fi

section "navidrome"
if have docker && docker inspect "$C" >/dev/null 2>&1; then
  docker inspect "$C" --format 'image={{.Config.Image}} restart={{.HostConfig.RestartPolicy.Name}} user={{.Config.User}} network={{.HostConfig.NetworkMode}}'
  echo "-- mounts (host -> container, rw?)"
  docker inspect "$C" --format '{{range .Mounts}}{{.Source}} -> {{.Destination}} rw={{.RW}}{{"\n"}}{{end}}'
  echo "-- published ports"
  docker port "$C" 2>/dev/null
  echo "-- environment variable NAMES only (values hidden)"
  docker inspect "$C" --format '{{range .Config.Env}}{{println .}}{{end}}' | cut -d= -f1 | grep -E '^ND_|^PUID|^PGID|^TZ' | sort
  echo "-- compose project (where the compose file lives)"
  docker inspect "$C" --format '{{index .Config.Labels "com.docker.compose.project.working_dir"}} {{index .Config.Labels "com.docker.compose.project.config_files"}}'
  docker exec "$C" /app/navidrome --version 2>/dev/null || docker exec "$C" navidrome --version 2>/dev/null
  MUSIC=$(docker inspect "$C" --format '{{range .Mounts}}{{if eq .Destination "/music"}}{{.Source}}{{end}}{{end}}')
  DATA=$(docker inspect "$C" --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Source}}{{end}}{{end}}')
else
  echo "container '$C' not found; pass its name as the first argument"
  MUSIC=""; DATA=""
fi

if [ -n "$MUSIC" ] && [ -d "$MUSIC" ]; then
  section "library: size and files by extension"
  du -sh "$MUSIC" 2>/dev/null
  find "$MUSIC" -type f 2>/dev/null | sed -n 's/.*\.\([A-Za-z0-9]\{1,5\}\)$/\1/p' | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | head -20
  echo "-- top-level folders (count only): $(find "$MUSIC" -mindepth 1 -maxdepth 1 -type d | wc -l)"
  echo "-- owner of the library root:"; stat -c '%U:%G %a' "$MUSIC"
fi

if [ -n "$DATA" ] && [ -f "$DATA/navidrome.db" ]; then
  section "navidrome database (read from a temporary copy)"
  ls -lh "$DATA"/navidrome.db*
  if have sqlite3; then
    T=$(mktemp -d); cp "$DATA"/navidrome.db* "$T"/ 2>/dev/null
    sqlite3 -readonly "$T/navidrome.db" <<'SQL'
.mode list
SELECT 'songs', count(*) FROM media_file;
SELECT 'albums', count(*) FROM album;
SELECT 'artists', count(*) FROM artist;
SELECT 'playlists (regular/smart)', sum(rules IS NULL OR rules=''), sum(rules IS NOT NULL AND rules<>'') FROM playlist;
SELECT 'songs missing genre', count(*) FROM media_file WHERE genre IS NULL OR genre='';
SELECT 'songs missing year', count(*) FROM media_file WHERE year IS NULL OR year=0;
SELECT 'songs with MusicBrainz id', count(*) FROM media_file WHERE mbz_recording_id<>'';
SELECT 'songs with lyrics', count(*) FROM media_file WHERE lyrics IS NOT NULL AND lyrics NOT IN ('','[]');
SELECT 'formats', suffix, count(*) FROM media_file GROUP BY suffix ORDER BY 3 DESC;
SELECT 'players seen (client names)', client, count(*) FROM player GROUP BY client;
SQL
    rm -rf "$T"
  else
    echo "sqlite3 not installed; skipped (do not install it just for this)"
  fi
  echo "-- built-in backups present?"; ls -d "$DATA"/backup* 2>/dev/null || echo "none in DataFolder"
fi

section "tailscale"
if have tailscale; then
  tailscale version | head -1
  tailscale status --self --peers=false 2>/dev/null
  echo "-- HTTPS services published with tailscale serve:"; tailscale serve status 2>/dev/null
else
  echo "tailscale not found"
fi

section "listening ports (process names only)"
ss -tlnp 2>/dev/null | awk 'NR>1{print $4}' | sed 's/.*://' | sort -n | uniq | tr '\n' ' '; echo

section "backup tooling present"
for t in restic borg rsnapshot rclone duplicati kopia; do have "$t" && echo "found: $t"; done
crontab -l 2>/dev/null | grep -v '^#' | grep -iE 'backup|rsync|restic|borg|rclone' || echo "no backup lines in this user's crontab"
systemctl list-timers --all --no-pager 2>/dev/null | grep -iE 'backup|restic|borg' || true
echo; echo "Done. Nothing was changed."
