#!/usr/bin/env bash
# watch.sh — sync dist/mass-coverwall-card.js to HA on every save
# Requires: fswatch (brew install fswatch)
# Requires: /Volumes/config mounted (Samba share from HA)

set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/dist/mass-coverwall-card.js"
DST="/Volumes/config/www/mass-coverwall-card.js"

if ! command -v fswatch &>/dev/null; then
  echo "ERROR: fswatch not found. Run: brew install fswatch"
  exit 1
fi

if [ ! -d "/Volumes/config/www" ]; then
  echo "ERROR: /Volumes/config/www not found. Mount the HA Samba share first."
  echo "  Finder → Go → Connect to Server → smb://homeassistant.local"
  exit 1
fi

echo "Watching $SRC"
echo "Destination: $DST"
echo "Press Ctrl+C to stop."
echo ""

# Initial sync
cp "$SRC" "$DST"
gzip -c "$SRC" > "${DST}.gz"
echo "[$(date +%T)] Initial sync done"

fswatch -o "$SRC" | while read -r _; do
  cp "$SRC" "$DST"
  gzip -c "$SRC" > "${DST}.gz"
  echo "[$(date +%T)] Synced → $DST"
done
