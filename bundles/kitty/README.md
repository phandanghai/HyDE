# Kitty Bundle (HyDE) — config + backend trong 1 folder

Gom **toàn bộ dấu chân của Kitty** trong HyDE vào một chỗ: file cấu hình
(`.config/kitty`) **+** backend theming (`wallbash`) **+** plugin session.

## Cấu trúc (phản chiếu `$HOME`)

```
kitty-bundle/
├── apply.sh                  # script cài: copy home/* vào ~/ (có backup)
├── README.md
└── home/
    ├── .config/kitty/
    │   ├── kitty.conf         # [CỦA BẠN]  điểm vào; tab bar; `include hyde.conf`
    │   ├── hyde.conf          # [HyDE]     font CaskaydiaCove, padding; `include theme.conf`
    │   └── theme.conf         # [HyDE/tự sinh] 16 màu terminal (mặc định Catppuccin Mocha)
    └── .local/
        ├── share/wallbash/theme/kitty.dcol      # [backend] template sinh theme.conf theo wallpaper
        ├── share/wallbash/scripts/kitty.sh      # [backend] đảm bảo `include hyde.conf` + reload kitty
        └── lib/hyde/session/plugins/kitty.py    # [tùy chọn] lưu/khôi phục thư mục làm việc khi restore session
```

## Vai trò từng file

| File | Loại | Chức năng |
|------|------|-----------|
| `kitty.conf` | bạn sửa | File chính. `include hyde.conf` ở đầu. Tab bar powerline. |
| `hyde.conf` | HyDE | Font `CaskaydiaCove Nerd Font Mono` 9.0, `window_padding_width 25`, `cursor_trail 1`, tắt audio bell. `include theme.conf`. |
| `theme.conf` | tự sinh | Bảng màu. Mặc định Catppuccin Mocha (tĩnh) → **chạy được ngay**. |
| `kitty.dcol` | backend | Template wallbash: định nghĩa `theme.conf` được sinh từ biến màu `<wallbash_*>` của wallpaper, và gọi `kitty.sh`. |
| `kitty.sh` | backend | Chèn `include hyde.conf` vào đầu `kitty.conf` (dọn trùng) rồi `killall -SIGUSR1 kitty` để reload nóng. |
| `kitty.py` | tùy chọn | Plugin: lưu CWD của shell trong kitty, khi khôi phục session mở lại đúng thư mục. |

## Cài đặt

```bash
sudo pacman -S --needed kitty   # 1. cài package
bash apply.sh                   # 2. copy config + backend vào ~/
```

## ⚠️ Lưu ý quan trọng về 2 mức hoạt động

1. **Chạy độc lập (không cần HyDE):** chỉ với 3 file trong `.config/kitty`,
   kitty đã hoạt động đầy đủ với theme Catppuccin Mocha tĩnh. Hai file wallbash
   chỉ là phần thừa nếu bạn không dùng theming động.

2. **Theming động theo wallpaper:** để `kitty.dcol` + `kitty.sh` thực sự đổi màu
   theo wallpaper, cần **engine wallbash đầy đủ** của HyDE (`hyde-shell wallbash`,
   các biến `<wallbash_*>`, `$WALLBASH_SCRIPTS`, `$HYDE_DATA_HOME`). Bản thân 2
   file này **không tự chạy** nếu thiếu engine đó. Khi đó `theme.conf` sẽ bị
   wallbash ghi đè bằng màu của wallpaper hiện tại.

> Tóm lại: muốn **terminal đẹp, dùng ngay** → chỉ cần `.config/kitty`. Muốn
> **đổi màu theo wallpaper như HyDE** → cần cả engine wallbash (xem
> `Tai-lieu-Config/01-...md` mục 4 về bộ backend tối thiểu).
