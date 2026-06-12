# HyDE App Bundles — config + backend gom theo từng app

Mỗi thư mục con là một **bundle độc lập** gồm: config (`home/.config/...`),
backend liên quan (`home/.local/...`: wallbash template, script, plugin), một
`apply.sh` để cài vào `$HOME`, `preserve.txt` (file của bạn — không ghi đè) và
`README.md` riêng.

Sinh lại bất cứ lúc nào bằng: `bash ../make-bundles.sh` (chạy từ gốc repo).

## Cách dùng chung

```bash
cd bundles/<app>
sudo pacman -S --needed <package>   # xem README mỗi bundle
bash apply.sh                       # copy vào ~/ (tự backup, giữ file của bạn)
```

## Bảng tổng hợp

| Bundle | Package | Mức độ | Ghi chú |
|--------|---------|--------|---------|
| **starship** | `starship` | 🟢 A | Prompt thuần, copy là chạy |
| **lsd** | `lsd` | 🟢 A | ls thay thế (màu + icon) |
| **vim** | `vim` | 🟢 A | vimrc + colorscheme tĩnh |
| **mangohud** | `mangohud` | 🟢 A | Overlay hiệu năng game |
| **wlogout** | `wlogout` | 🟢 A | Menu đăng xuất, tự chứa |
| **swaylock** | `swaylock-effects` | 🟢 A | Màn khóa đơn |
| **kitty** | `kitty` | 🟢 A | Terminal (Catppuccin tĩnh) + backend wallbash kèm theo |
| **dunst** | `dunst` | 🟡 B | Daemon chạy được; màu cần wallbash |
| **swaync** | `swaync` | 🟡 B | Notification center; CSS tích hợp wallbash |
| **fastfetch** | `fastfetch` | 🔴 C | config gọi `hyde-shell fastfetch logo` |
| **rofi** | `rofi` | 🔴 C | theme.rasi chỉ là màu; launcher cần hyde-shell |
| **waybar** | `waybar` | 🔴 C | Module gọi hyde-shell; cần `waybar.py` + HyDE core |
| **qt-gtk-theme** | `nwg-look qt5ct qt6ct kvantum` | 🔴 C | Theming Qt/GTK; cần engine wallbash |
| **pypr** | `pyprland` | 🔴 C | Cần Hyprland đang chạy |

## Giải thích 3 mức độ

- 🟢 **Tier A — Độc lập:** copy config là dùng được ngay, không cần HyDE.
- 🟡 **Tier B — Cần wallbash:** app chạy với màu tĩnh; muốn **đổi màu theo
  wallpaper** thì cần engine `hyde-shell wallbash` (bundle đã kèm template/script,
  nhưng template chỉ chạy khi có engine).
- 🔴 **Tier C — Cần HyDE core:** phụ thuộc `~/.local/bin/hyde-shell` +
  `~/.local/lib/hyde` (+ `~/.local/share/hypr` với Hyprland). **Không chạy độc lập.**
  Với nhóm này, nên cài cả HyDE core (xem `../Tai-lieu-Config/01-...md` mục 4.1
  về "bộ backend tối thiểu") hoặc dùng `Scripts/restore_cfg.sh`.

## Lưu ý chung

- File tự sinh (vd `dunstrc`, `qt6ct/colors/wallbash.conf`, `themes/*`) có thể
  chứa đường dẫn `/home/khing/...` của tác giả — wallbash sẽ sinh lại theo máy bạn.
- `apply.sh` luôn **backup** file cũ vào `~/.hyde-bundle-backup-<thời gian>` trước
  khi ghi đè, và **giữ nguyên** các file liệt kê trong `preserve.txt`.
- Không có bundle riêng cho **Hyprland / Zsh** ở đây vì chúng là lõi HyDE (cần
  gần như toàn bộ `.local`); xem tài liệu refactor để gom bộ core.
