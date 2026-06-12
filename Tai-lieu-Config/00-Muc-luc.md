# Tài liệu cấu hình HyDE (Tiếng Việt)

Bộ tài liệu này mô tả, đánh giá và hướng dẫn refactor cấu hình HyDE trong repo,
tập trung vào Hyprland và các thành phần liên quan (Waybar, Kitty, Zsh, Rofi,
Dunst, Starship, …).

## Mục lục

| # | File | Nội dung |
|---|------|----------|
| 01 | [01-Kien-truc-va-Refactor-Hyprland.md](01-Kien-truc-va-Refactor-Hyprland.md) | **Kiến trúc nạp config Hyprland** (sơ đồ tầng & thứ tự source), mô tả từng file `~/.config/hypr` + backend `~/.local/share/hypr`, và **hướng dẫn refactor** thư mục `.config` để copy-paste lên Arch. |
| 02 | [02-Packages-va-Cau-hinh.md](02-Packages-va-Cau-hinh.md) | **Tổng hợp package**: các file `pkg_*.lst`, `restore_*.lst`, `restore_cfg.psv`; và **map theo từng thành phần** (package nào → file cấu hình nào). Kèm lệnh `pacman` cài nhanh. |
| 03 | [03-Chi-tiet-tung-file.md](03-Chi-tiet-tung-file.md) | **Mô tả chi tiết nội dung bên trong từng file** cấu hình (giá trị thực tế, ý nghĩa tùy chọn) cho 14 thành phần. |

## Đọc theo nhu cầu

- **Muốn hiểu HyDE hoạt động ra sao / vì sao không copy được .config trực tiếp** → đọc file **01**.
- **Muốn biết cần cài package gì + file nào đi đâu** → đọc file **02**.
- **Muốn biết một tùy chọn cụ thể trong file làm gì** → đọc file **03**.

## 3 nguyên tắc quan trọng nhất

1. **Cấu hình chia 2 tầng**: `~/.config` (bạn sửa) + `~/.local/share|lib|bin` (HyDE quản lý).
   Hyprland sẽ **không chạy** nếu thiếu tầng `~/.local`.
2. **Gần như mọi keybind gọi `hyde-shell`** (ở `~/.local/bin`) → bắt buộc phải có.
3. **Không cài bằng `cp -r`** — dùng `Scripts/restore_cfg.sh` (xử lý đúng logic
   Giữ nguyên/Đồng bộ/Ghi đè + tự backup) hoặc script `apply.sh` mô tả trong file 01.

---

*Tài liệu sinh ngày 2026-06-12. Áp dụng cho repo HyDE nhánh `master`.*
