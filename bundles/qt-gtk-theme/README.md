# Bundle: qt-gtk-theme

- **Package:** `nwg-look qt5ct qt6ct kvantum kvantum-qt5`
- **Mức độ:** 🔴 **Tier C — Cần HyDE core** (`~/.local/bin/hyde-shell` + `~/.local/lib/hyde` + `~/.local/share/hypr`). Không chạy độc lập.

> Theming Qt/GTK đồng bộ. colors/wallbash.conf do wallbash sinh. Cần engine wallbash để đổi màu theo theme.

## Cài đặt
```bash
sudo pacman -S --needed nwg-look qt5ct qt6ct kvantum kvantum-qt5
bash apply.sh
```

## File trong bundle
```
home/.config/Kvantum/kvantum.kvconfig
home/.config/Kvantum/wallbash/wallbash.kvconfig
home/.config/Kvantum/wallbash/wallbash.svg
home/.config/gtk-3.0/settings.ini
home/.config/nwg-look/config
home/.config/qt5ct/colors/wallbash.conf
home/.config/qt5ct/qt5ct.conf
home/.config/qt6ct/colors/wallbash.conf
home/.config/qt6ct/qt6ct.conf
home/.config/xsettingsd/xsettingsd.conf
home/.local/share/wallbash/always/gtk-css.dcol
home/.local/share/wallbash/always/qtct.dcol
home/.local/share/wallbash/scripts/qtct.sh
home/.local/share/wallbash/theme/gtk/gtk2.dcol
home/.local/share/wallbash/theme/gtk/gtk2.hidpi.dcol
home/.local/share/wallbash/theme/gtk/gtk3.dcol
home/.local/share/wallbash/theme/gtk/gtk4.dcol
home/.local/share/wallbash/theme/kvantum/kvantum.dcol
home/.local/share/wallbash/theme/kvantum/kvconfig.dcol
```

## Giữ nguyên (không ghi đè nếu đã có)
```
.config/gtk-3.0/settings.ini
.config/nwg-look/config
```
