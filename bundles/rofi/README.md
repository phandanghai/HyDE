# Bundle: rofi

- **Package:** `rofi`
- **Mức độ:** 🔴 **Tier C — Cần HyDE core** (`~/.local/bin/hyde-shell` + `~/.local/lib/hyde` + `~/.local/share/hypr`). Không chạy độc lập.

> theme.rasi chỉ là MÀU. Launcher/menu cần script hyde-shell (rofilaunch, rofiselect). Kèm template wallbash.

## Cài đặt
```bash
sudo pacman -S --needed rofi
bash apply.sh
```

## File trong bundle
```
home/.config/rofi/theme.rasi
home/.local/lib/hyde/rofi.bookmarks.sh
home/.local/lib/hyde/rofi.websearch.sh
home/.local/lib/hyde/rofilaunch.sh
home/.local/lib/hyde/rofiselect.sh
home/.local/share/wallbash/always/rasi.dcol
home/.local/share/wallbash/theme/rofi.dcol
```

## Giữ nguyên (không ghi đè nếu đã có)
```
.config/rofi/theme.rasi
```
