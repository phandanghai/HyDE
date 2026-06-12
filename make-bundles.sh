#!/usr/bin/env bash
# Generator: gom config + backend của TỪNG app HyDE vào bundles/<app>/
# Chạy từ thư mục gốc repo:  bash make-bundles.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRCROOT="$ROOT/Configs"
OUT="$ROOT/bundles"
rm -rf "$OUT"; mkdir -p "$OUT"

# ---- apply.sh dùng chung cho mọi bundle ----
read -r -d '' APPLY_TEMPLATE <<'APPLY' || true
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
APPLY

# ---- Hàm dựng 1 bundle ----
# build_bundle <app> <pkg> <tier> "<note>" "<preserve(\n)>" "<paths(\n, glob theo Configs/)>"
build_bundle() {
  local app="$1" pkg="$2" tier="$3" note="$4" preserve="$5" paths="$6"
  local home="$OUT/$app/home"
  mkdir -p "$home"
  local copied=()
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    local matched=0
    for f in $SRCROOT/$pat; do
      [ -e "$f" ] || continue
      matched=1
      local rel="${f#$SRCROOT/}"
      if [ -d "$f" ]; then
        mkdir -p "$home/$(dirname "$rel")"; cp -r "$f" "$home/$rel"
      else
        mkdir -p "$home/$(dirname "$rel")"; cp "$f" "$home/$rel"
      fi
      copied+=("$rel")
    done
    [ $matched -eq 0 ] && echo "  ! cảnh báo [$app]: không khớp $pat"
  done <<< "$paths"

  # preserve.txt
  printf '%s\n' "$preserve" | sed '/^$/d' > "$OUT/$app/preserve.txt"
  # apply.sh
  printf '%s\n' "$APPLY_TEMPLATE" > "$OUT/$app/apply.sh"; chmod +x "$OUT/$app/apply.sh"

  # README
  local tierdesc
  case "$tier" in
    A) tierdesc="🟢 **Tier A — Độc lập**: copy là chạy, không cần HyDE." ;;
    B) tierdesc="🟡 **Tier B — Cần engine wallbash** cho theming động (config vẫn chạy với màu tĩnh). Màu đổi theo wallpaper chỉ hoạt động khi có \`hyde-shell wallbash\`." ;;
    C) tierdesc="🔴 **Tier C — Cần HyDE core** (\`~/.local/bin/hyde-shell\` + \`~/.local/lib/hyde\` + \`~/.local/share/hypr\`). Không chạy độc lập." ;;
  esac
  {
    echo "# Bundle: $app"
    echo ""
    echo "- **Package:** \`$pkg\`"
    echo "- **Mức độ:** $tierdesc"
    echo ""
    echo "> $note"
    echo ""
    echo "## Cài đặt"
    echo '```bash'
    echo "sudo pacman -S --needed $pkg"
    echo "bash apply.sh"
    echo '```'
    echo ""
    echo "## File trong bundle"
    echo '```'
    ( cd "$OUT/$app" && find home -type f | sort )
    echo '```'
    echo ""
    echo "## Giữ nguyên (không ghi đè nếu đã có)"
    echo '```'
    cat "$OUT/$app/preserve.txt"
    echo '```'
  } > "$OUT/$app/README.md"

  echo "✓ $app  (tier $tier, ${#copied[@]} file)"
}

# =======================  SPECS  =======================

build_bundle starship starship A \
"Prompt thuần. Bật bằng: thêm 'eval \"\$(starship init zsh)\"' vào shell." \
".config/starship/starship.toml
.config/starship/powerline.toml" \
".config/starship/starship.toml
.config/starship/powerline.toml"

build_bundle lsd lsd A \
"Cấu hình ls thay thế: bố cục, màu, icon Nerd Font. Thuần lsd." \
".config/lsd/config.yaml
.config/lsd/colors.yaml
.config/lsd/icons.yaml" \
".config/lsd/config.yaml
.config/lsd/colors.yaml
.config/lsd/icons.yaml"

build_bundle vim vim A \
"vimrc của bạn + hyde.vim + colorscheme wallbash.vim (tĩnh)." \
".config/vim/vimrc" \
".config/vim/vimrc
.config/vim/hyde.vim
.config/vim/colors/wallbash.vim"

build_bundle mangohud mangohud A \
"Overlay hiệu năng game. File config thuần." \
"" \
".config/MangoHud/MangoHud.conf"

build_bundle wlogout wlogout A \
"Menu đăng xuất: 2 layout + 2 style CSS + icon. Tự chứa." \
"" \
".config/wlogout/layout_1
.config/wlogout/layout_2
.config/wlogout/style_1.css
.config/wlogout/style_2.css
.config/wlogout/icons"

build_bundle swaylock swaylock-effects A \
"Màn khóa swaylock. File config đơn (màu có thể do wallbash chèn)." \
"" \
".config/swaylock/config"

build_bundle dunst dunst B \
"Notification daemon. Sửa dunst.conf rồi chạy 'hyde-shell wallbash dunst'. dunstrc là bản tự sinh." \
".config/dunst/dunst.conf" \
".config/dunst/dunst.conf
.config/dunst/dunstrc
.local/share/wallbash/always/dunst.dcol
.local/share/wallbash/scripts/dunst.sh"

build_bundle swaync swaync B \
"Notification center (thay dunst). JSON chạy được; CSS/màu tích hợp wallbash." \
".config/swaync/user-style.css" \
".config/swaync/config.json
.config/swaync/style.css
.config/swaync/user-style.css
.local/share/wallbash/theme/swaync.dcol
.local/share/wallbash/scripts/swaync.sh"

build_bundle fastfetch fastfetch C \
"config.jsonc gọi 'hyde-shell fastfetch logo' + 'hyprctl splash'. Kèm preset + script. Bỏ 2 dòng đó nếu dùng không cần HyDE." \
".config/fastfetch/config.jsonc" \
".config/fastfetch/config.jsonc
.config/fastfetch/logo
.local/share/fastfetch/presets/hyde
.local/lib/hyde/fastfetch.sh"

build_bundle rofi rofi C \
"theme.rasi chỉ là MÀU. Launcher/menu cần script hyde-shell (rofilaunch, rofiselect). Kèm template wallbash." \
".config/rofi/theme.rasi" \
".config/rofi/theme.rasi
.local/share/wallbash/theme/rofi.dcol
.local/share/wallbash/always/rasi.dcol
.local/lib/hyde/rofilaunch.sh
.local/lib/hyde/rofiselect.sh
.local/lib/hyde/rofi.bookmarks.sh
.local/lib/hyde/rofi.websearch.sh"

build_bundle waybar waybar C \
"Thanh trạng thái. Module gọi script hyde-shell; nạp module từ ~/.local/share/waybar. Cần waybar.py + HyDE core." \
".config/waybar/config.jsonc
.config/waybar/style.css
.config/waybar/theme.css
.config/waybar/user-style.css" \
".config/waybar/config.jsonc
.config/waybar/style.css
.config/waybar/theme.css
.config/waybar/user-style.css
.config/waybar/includes
.config/waybar/modules
.config/waybar/styles
.config/waybar/layouts
.config/waybar/menus
.local/share/waybar
.local/share/wallbash/theme/waybar.dcol
.local/share/wallbash/always/scss.dcol
.local/lib/hyde/waybar.py"

build_bundle qt-gtk-theme "nwg-look qt5ct qt6ct kvantum kvantum-qt5" C \
"Theming Qt/GTK đồng bộ. colors/wallbash.conf do wallbash sinh. Cần engine wallbash để đổi màu theo theme." \
".config/gtk-3.0/settings.ini
.config/nwg-look/config" \
".config/gtk-3.0/settings.ini
.config/xsettingsd/xsettingsd.conf
.config/nwg-look/config
.config/qt5ct/qt5ct.conf
.config/qt5ct/colors/wallbash.conf
.config/qt6ct/qt6ct.conf
.config/qt6ct/colors/wallbash.conf
.config/Kvantum/kvantum.kvconfig
.config/Kvantum/wallbash
.local/share/wallbash/always/gtk-css.dcol
.local/share/wallbash/always/qtct.dcol
.local/share/wallbash/scripts/qtct.sh
.local/share/wallbash/theme/gtk
.local/share/wallbash/theme/kvantum"

build_bundle pypr pyprland C \
"Pyprland (dropdown terminal/scratchpad). Cần Hyprland đang chạy. Config nhỏ, riêng pypr." \
".config/pypr/config.toml" \
".config/pypr/config.toml"

echo ""
echo "Hoàn tất. Xem: bundles/<app>/{home,apply.sh,preserve.txt,README.md}"
