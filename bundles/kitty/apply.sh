#!/usr/bin/env bash
# Cài config Kitty (HyDE) + backend theming vào $HOME
# Dùng: bash apply.sh
set -euo pipefail

SRC="$(cd "$(dirname "$0")/home" && pwd)"
BACKUP="$HOME/.kitty-bundle-backup-$(date +%Y%m%d_%H%M%S)"

# (1) kitty.conf = file CỦA BẠN -> chỉ copy nếu chưa có (giữ nguyên chỉnh sửa)
preserve=( ".config/kitty/kitty.conf" )

# (2) Các file HyDE quản lý -> luôn ghi đè (có backup)
overwrite=(
  ".config/kitty/hyde.conf"
  ".config/kitty/theme.conf"
  ".local/share/wallbash/theme/kitty.dcol"
  ".local/share/wallbash/scripts/kitty.sh"
  ".local/lib/hyde/session/plugins/kitty.py"   # tùy chọn, gỡ dòng này nếu không cần
)

copy_preserve() {
  if [ -e "$HOME/$1" ]; then
    echo "  giữ nguyên : $1 (đã tồn tại)"
  else
    mkdir -p "$HOME/$(dirname "$1")"; cp "$SRC/$1" "$HOME/$1"
    echo "  tạo mới    : $1"
  fi
}
copy_overwrite() {
  mkdir -p "$HOME/$(dirname "$1")"
  if [ -e "$HOME/$1" ]; then
    mkdir -p "$BACKUP/$(dirname "$1")"; cp -r "$HOME/$1" "$BACKUP/$1"
  fi
  cp "$SRC/$1" "$HOME/$1"
  echo "  ghi đè     : $1"
}

echo "==> Cài config người dùng (giữ nguyên nếu đã có):"
for f in "${preserve[@]}";  do copy_preserve  "$f"; done
echo "==> Cài file HyDE quản lý (ghi đè):"
for f in "${overwrite[@]}"; do copy_overwrite "$f"; done

chmod +x "$HOME/.local/share/wallbash/scripts/kitty.sh" 2>/dev/null || true

echo ""
echo "Xong. Backup (nếu có) ở: $BACKUP"
echo "Mở lại kitty để áp dụng. Reload nóng: killall -SIGUSR1 kitty"
