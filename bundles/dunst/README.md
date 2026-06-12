# Bundle: dunst

- **Package:** `dunst`
- **Mức độ:** 🟡 **Tier B — Cần engine wallbash** cho theming động (config vẫn chạy với màu tĩnh). Màu đổi theo wallpaper chỉ hoạt động khi có `hyde-shell wallbash`.

> Notification daemon. Sửa dunst.conf rồi chạy 'hyde-shell wallbash dunst'. dunstrc là bản tự sinh.

## Cài đặt
```bash
sudo pacman -S --needed dunst
bash apply.sh
```

## File trong bundle
```
home/.config/dunst/dunst.conf
home/.config/dunst/dunstrc
home/.local/share/wallbash/always/dunst.dcol
home/.local/share/wallbash/scripts/dunst.sh
```

## Giữ nguyên (không ghi đè nếu đã có)
```
.config/dunst/dunst.conf
```
