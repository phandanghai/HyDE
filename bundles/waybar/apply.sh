#!/usr/bin/env bash
# Cài bundle vào $HOME. File trong preserve.txt chỉ copy nếu chưa có; còn lại ghi đè (có backup).
set -euo pipefail
SRC="$(cd "$(dirname "$0")/home" && pwd)"
BK="$HOME/.hyde-bundle-backup-$(date +%Y%m%d_%H%M%S)"
PRESERVE_FILE="$(dirname "$0")/preserve.txt"
is_preserve(){ [ -f "$PRESERVE_FILE" ] && grep -Fxq "$1" "$PRESERVE_FILE"; }
cd "$SRC"
find . -type f | sed 's|^\./||' | while read -r rel; do
  dest="$HOME/$rel"
  if is_preserve "$rel" && [ -e "$dest" ]; then echo "  giữ nguyên : $rel"; continue; fi
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ]; then mkdir -p "$BK/$(dirname "$rel")"; cp -r "$dest" "$BK/$rel"; fi
  cp "$SRC/$rel" "$dest"; echo "  cài        : $rel"
done
# chmod cho script backend nếu có
find "$HOME/.local/share/wallbash/scripts" "$HOME/.local/lib/hyde" -maxdepth 3 -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true
echo "Backup (nếu có) ở: $BK"
