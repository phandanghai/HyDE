# Bundle: swaync

- **Package:** `swaync`
- **Mức độ:** 🟡 **Tier B — Cần engine wallbash** cho theming động (config vẫn chạy với màu tĩnh). Màu đổi theo wallpaper chỉ hoạt động khi có `hyde-shell wallbash`.

> Notification center (thay dunst). JSON chạy được; CSS/màu tích hợp wallbash.

## Cài đặt
```bash
sudo pacman -S --needed swaync
bash apply.sh
```

## File trong bundle
```
home/.config/swaync/config.json
home/.config/swaync/style.css
home/.config/swaync/user-style.css
home/.local/share/wallbash/scripts/swaync.sh
home/.local/share/wallbash/theme/swaync.dcol
```

## Giữ nguyên (không ghi đè nếu đã có)
```
.config/swaync/user-style.css
```
