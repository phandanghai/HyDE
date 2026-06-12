# HyDE — Mô tả chi tiết cấu hình trong từng file

> Tài liệu này đi sâu vào **nội dung bên trong** mỗi file config (giá trị thực tế,
> ý nghĩa từng tùy chọn), bổ sung cho:
> - `HYPRLAND_CONFIG_GUIDE.md` — kiến trúc nạp config & chi tiết Hyprland
> - `PACKAGES_AND_CONFIGS.md` — package + map file theo thành phần
>
> Quy ước HyDE: file thường tách làm 2 — file `*.conf`/`hyde.*` (HyDE quản lý,
> bị ghi đè khi update) và file của bạn (`kitty.conf`, `.zshrc`, `user.zsh`…)
> để override an toàn.

---

## 1. HYPRLAND

### 1.1 `~/.config/hypr/hyprland.conf` — điểm vào
- Dòng 1: `$HYDE_HYPRLAND=set` → **marker bắt buộc**, báo cho HyDE biết không ghi đè file. Xóa dòng này = HyDE sẽ reset file của bạn.
- `source = $HOME/.local/share/hyde/hyprland.conf` → nạp **bộ loader backend** (chứa toàn bộ logic). Đây là lý do không thể chỉ copy `.config`.
- Sau đó source 4 file người dùng: `keybindings.conf`, `windowrules.conf`, `monitors.conf`, `userprefs.conf` (theo thứ tự).

### 1.2 `keybindings.conf` — phím tắt
- Dùng `bindd` (bind có mô tả) + biến nhóm `$d=[Nhóm|Nhóm phụ]` để rofi/GUI hiển thị đẹp.
- Biến chính: `$mainMod = SUPER` (phím Windows).
- Nhóm chính:
  - **Window Management:** `SUPER+Q` đóng cửa sổ, `SUPER+W` floating, `SUPER+G` group, `SUPER+J` togglesplit, `SUPER+mũi tên` đổi focus, `SUPER+Shift+mũi tên` resize, `ALT+Tab` cycle.
  - **Launcher:** `SUPER+T` terminal, `SUPER+E` file manager, `SUPER+C` editor, `SUPER+B` browser, `SUPER+A` app finder (rofi), `SUPER+V` clipboard.
  - **Hardware:** phím F10/F11/F12 + phím XF86 cho âm lượng/mic/độ sáng/media — đều gọi `hyde-shell volumecontrol/brightnesscontrol`.
  - **Screen Capture:** `SUPER+P` chụp vùng, `SUPER+Ctrl+P` chụp đóng băng, `SUPER+Shift+P` color picker.
  - **Theming:** `SUPER+Shift+W` chọn wallpaper, `SUPER+Shift+T` chọn theme, `SUPER+Shift+Y` chọn animation.
  - **Workspaces:** `SUPER+1..0` chuyển, `SUPER+Shift+1..0` chuyển cửa sổ, `SUPER+S` scratchpad.
- ⚠️ Gần như mọi bind đều gọi `hyde-shell <lệnh>` → cần `~/.local/bin/hyde-shell`.

### 1.3 `windowrules.conf` — quy tắc cửa sổ
- `idle_inhibit fullscreen` cho trình duyệt/mpv/spotify (không khóa màn hình khi xem fullscreen).
- Quy tắc **Picture-in-Picture**: tự float, ghim, đặt góc dưới-phải, giữ tỉ lệ.
- Hàng loạt `opacity` theo class: firefox/brave 0.90, code/kitty/dolphin 0.80, steam/spotify 0.70, blender 1.00.
- `float true` cho các app GTK/dialog (Signal, ProtonUp, Steam Friends, Blender render…).
- `layerrule = blur` cho rofi/notifications/swaync/logout.

### 1.4 `monitors.conf`
- **Trống mặc định.** Thêm `monitor = DP-1,2560x1440@144,0x0,1` của bạn vào đây. Nếu để trống → dùng `,preferred,auto,auto`.

### 1.5 `userprefs.conf` — file cá nhân (nạp cuối, thắng tất cả)
- Các block stub có sẵn (đang comment): `input` (kb_layout, sensitivity, accel_profile), `touchpad { natural_scroll }`, `gestures { workspace_swipe }`, `misc { enable_swallow }`, `ecosystem { no_update_news }`.
- **Đây là nơi đặt hầu hết tùy chỉnh cá nhân.**

### 1.6 `nvidia.conf`
- `env = LIBVA_DRIVER_NAME,nvidia`, `GBM_BACKEND,nvidia-drm`, `__GLX_VENDOR_LIBRARY_NAME,nvidia`.
- `cursor:no_hardware_cursors = true` (tránh giật con trỏ). Chỉ áp dụng nếu có GPU NVIDIA.

### 1.7 `hypridle.conf` — quản lý nghỉ
- `lock_cmd = hyde-shell lockscreen.sh`.
- Mốc thời gian: **60s** giảm sáng còn 1% → **120s** khóa → **300s** tắt màn hình (DPMS) → **500s** suspend.
- `ignore_dbus_inhibit = false` → tôn trọng yêu cầu chặn nghỉ (vd khi xem video).

### 1.8 `hyprsunset.conf` — lọc ánh sáng xanh
- 2 profile (đang comment): ban ngày `identity = true` (màu gốc), ban đêm `temperature = 5500, gamma = 0.8`.

### 1.9 File "selector" (sửa bằng script, không sửa tay)
- `animations.conf` → `$ANIMATION=theme` + `source ./animations/theme.conf`.
- `workflows.conf` → `$WORKFLOW=default` + source preset.
- `shaders.conf` → `$SCREEN_SHADER="disable"` + đường dẫn shader đã biên dịch.
- `hyprlock.conf` → `$LAYOUT_PATH` + source boilerplate ở `~/.local/share/hypr/hyprlock.conf`.

### 1.10 Thư mục preset
- `animations/` (19 preset): mỗi file 1 block `animations { bezier… animation… }`. VD `classic.conf` dùng bezier `myBezier`, `disable.conf` tắt hẳn.
- `workflows/`: `default/gaming/editing/powersaver/snappy`. `gaming.conf` → tắt blur/shadow/rounding/animation, ép opaque toàn bộ để tối đa hiệu năng.
- `shaders/`: file `.frag` (GLSL) — blue-light-filter, grayscale, invert, vibrance, oled-saver, paper…
- `hyprlock/`: layout màn khóa (HyDE, Anurati, SF Pro…). `theme.conf` chỉ `source ./HyDE.conf`.

### 1.11 Backend `~/.local/share/hypr/` (KHÔNG sửa)
- `variables.conf`: `$mainMod=SUPER`, các lệnh app (`$TERMINAL`, `$BROWSER`…), định nghĩa **service** `$start.*` (waybar, dunst, hypridle, applet) chạy qua systemd; biến theme/font/cursor mặc định.
- `defaults.conf`: `monitor=,preferred,auto,auto`; decoration (active 0.90/inactive 0.75); block animation gốc; `input { accel_profile=flat, numlock_by_default }`; gesture 3 ngón; dwindle/master; `misc { disable_hyprland_logo, vrr=0 }`.
- `env.conf`: biến môi trường Wayland/Qt (`QT_QPA_PLATFORM=wayland;xcb`, `MOZ_ENABLE_WAYLAND=1`, `ELECTRON_OZONE_PLATFORM_HINT=auto`); prepend `~/.local/bin` + `~/.local/lib/hyde` vào PATH.
- `startup.conf`: toàn bộ `exec-once` — dbus/systemd import, polkit, waybar, dunst, wallpaper, clipboard watcher, applet (network/bluetooth/udiskie), batterynotify, hypridle, hyprsunset, set cursor.
- `dynamic.conf`: keo dán theming — source `themes/colors.conf` + `theme.conf` + `wallbash.conf`, set màu groupbar từ biến wallbash, chạy lệnh tạo thư mục + sinh keybind-hint khi reload.
- `finale.conf`: export tất cả giá trị thành property `hyde { theme=… font=… }` để query nhanh.

---

## 2. WAYBAR (thanh trạng thái)

### 2.1 `config.jsonc` — bố cục thanh
- `layer: top`, `position: top`, `mode: dock`, `exclusive: true` → thanh trên cùng, chiếm chỗ.
- `include`: tự nạp mọi module từ `~/.config/waybar/modules/*json*` và `~/.local/share/waybar/modules/*`.
- Bố cục 3 vùng dùng **group** (kiểu "pill"/"leaf" bo tròn):
  - **left** (`leaf-inverse`): `hyprland/workspaces` + `wlr/taskbar`.
  - **center** (`pill`): `weather` ‖ `keyboard-state` `clock` `updates` `keybindhint` `gamemode` ‖ `hyprsunset` `idle_inhibitor`.
  - **right** (`leaf`): `privacy` `backlight` `tray` `network` (up/down) `bluetooth` `pulseaudio` (+mic) `battery` `power-profiles` `gpuinfo` `cpuinfo` `sensors` `swaync`/`dunst` `hyde-menu`.
- File của bạn: `user-style.css`. File HyDE: `style.css`, `theme.css`, thư mục `modules/ styles/ layouts/ menus/`.
- Bố cục được đổi qua `SUPER+Alt+↑/↓` (chọn layout trong `~/.local/share/waybar/layouts`).

---

## 3. KITTY (terminal)

### 3.1 `kitty.conf` — file của bạn
- `include hyde.conf` (nạp cấu hình HyDE trước).
- Tab bar: `tab_bar_edge bottom`, style `powerline` slanted, template hiển thị số cửa sổ.
- Các dòng comment gợi ý: mở tab ở thư mục hiện tại, giảm độ trễ (input_delay/repaint_delay).

### 3.2 `hyde.conf` — HyDE quản lý
- Font: `CaskaydiaCove Nerd Font Mono`, `font_size 9.0`.
- `enable_audio_bell no`, `window_padding_width 25`, `cursor_trail 1`.
- `include theme.conf` (màu). Comment sẵn: `background_opacity`, `hide_window_decorations`.

### 3.3 `theme.conf` — màu (Catppuccin Mocha, tự sinh theo wallbash)
- foreground `#CDD6F4`, background `#1E1E2E`, cursor `#F5E0DC`.
- Bảng 16 màu terminal (color0–15), màu tab bar, màu viền cửa sổ active/inactive.

---

## 4. ZSH (shell)

Thứ tự nạp: `.zshenv` → loop source `conf.d/*.zsh` → `00-hyde.zsh` (nạp `conf.d/hyde/env.zsh`, `terminal.zsh`) → cuối cùng `.zshrc` + `user.zsh`.

### 4.1 `.zshenv`
- Vòng lặp: source mọi file `conf.d/*.zsh`. Thư mục bị bỏ qua → cho phép gom script vào thư mục con + 1 file entry-point.

### 4.2 `conf.d/` (HyDE quản lý)
- `00-hyde.zsh`: entry-point, source `conf.d/hyde/env.zsh` (biến môi trường) và `terminal.zsh` (chỉ khi shell tương tác).
- `binds.zsh`: phím tắt dòng lệnh.
- `hyde/`: thư mục chứa script lõi của HyDE.

### 4.3 `.zshrc` — file của bạn
- Mặc định chỉ set `export EDITOR=code`.
- Chứa sẵn (comment) nhiều **alias gợi ý**: `l/ls/ll` dùng `eza`, `up/un/pl` cho aurhelper, `..`/`...` điều hướng nhanh, `mkdir -p`.
- Ghi chú: tùy chỉnh trước khi nạp zshrc → đặt ở `$ZDOTDIR/.user.zsh`.

### 4.4 `user.zsh` — tùy chỉnh chính
- Khi shell tương tác: hiển thị `pokego`/`pokemon-colorscripts`, hoặc `fastfetch --logo-type kitty`.
- Cờ override: `HYDE_ZSH_NO_PLUGINS`, `HYDE_ZSH_PROMPT`, `HYDE_ZSH_COMPINIT_CHECK` (giảm thời gian khởi động), `HYDE_ZSH_OMZ_DEFER`.
- Mảng `plugins=("sudo")` — thêm plugin oh-my-zsh ở đây.

### 4.5 `plugin.zsh` — hệ plugin thay thế (mặc định TẮT)
- Dòng đầu `return 1` → file bị bỏ qua. Bỏ dòng này để dùng **Zinit** thay oh-my-zsh.
- Ví dụ sẵn: autosuggestions, fast-syntax-highlighting, fzf-tab, zsh-completions, z (nhảy thư mục), autopair, alias-tips.

### 4.6 `prompt.zsh` — prompt tùy biến (mặc định TẮT)
- `return 1` → bỏ qua, để HyDE nạp prompt của nó. Bỏ `return 1` để tự dùng (vd `eval "$(starship init zsh)"`).

---

## 5. STARSHIP (prompt)

### 5.1 `starship.toml`
- `add_newline = false`.
- **format trái:** ` 󰣇 ` + `$directory` + `$git_branch/$git_status` + ký tự prompt.
- **right_format:** rất dài — hiển thị version của hàng chục ngôn ngữ (node, python, rust, go, lua…) + `$time` bên phải, nhưng chỉ hiện khi thư mục có dự án tương ứng (detect_files/folders).
- `[directory]` màu xanh `#8be9fd` đậm; `[time]` định dạng `%R` (giờ:phút); `[git_status]` ký hiệu ⇡ahead/⇣behind.
- `powerline.toml` là preset prompt thay thế (kiểu powerline).

---

## 6. ROFI (launcher)

### 6.1 `theme.rasi` — chỉ định nghĩa màu
- Là file của bạn để override màu: `main-bg #11111be6` (nền mờ), `main-fg #cdd6f4`, `main-br #cba6f7` (viền tím), `select-bg/fg` cho mục đang chọn. Layout/kích thước do HyDE quản lý ở nơi khác.

---

## 7. DUNST (thông báo)

### 7.1 `dunst.conf` — file của bạn (nguồn)
- Cấu hình gốc (theo `dunst(5)`): `monitor=0`, `follow=mouse`, độ rộng, vị trí…
- **Sửa file này** rồi chạy `hyde-shell wallbash dunst` để áp dụng.

### 7.2 `dunstrc` — TỰ SINH (không sửa)
- Header cảnh báo: auto-generated bởi wallbash, đừng sửa tay.
- `[global]`: `corner_radius=10`, `width=300`, `origin=top-right`, `offset=(20,20)`, `progress_bar=true`, `transparency=10`.
- `dmenu = rofi -config notification`, `icon_theme = "Tela-circle-dracula,…"`.
- `[urgency_critical]`: nền `#f5e0dc`, viền đỏ `#f38ba8`, `timeout=0` (không tự tắt).
- ⚠️ Chứa đường dẫn `/home/khing/…` của tác giả — sẽ được sinh lại theo máy bạn.

---

## 8. SWAYNC (notification center thay thế dunst)

### 8.1 `config.json`
- Vị trí: `positionX=right`, `positionY=top`. Control-center `400x300`px.
- `timeout=10` (low 5, critical 0=không tắt), `transition-time=200ms`.
- `widgets`: title, dnd, notifications, mpris (media), backlight, volume, buttons-grid.
- `ignore-gtk-theme=true`, `cssPriority=user` (ưu tiên CSS của bạn ở `user-style.css`).

---

## 9. FASTFETCH (thông tin hệ thống)

### 9.1 `config.jsonc`
- `logo`: lấy từ `hyde-shell fastfetch logo`, cao 18 dòng.
- `separator = " : "`.
- `modules`: splash (qua `hyprctl splash`), chassis, OS, kernel, packages… + các khung vẽ bằng ký tự `┌──┐`. Màu key theo nhóm (blue/red/green).
- HyDE cung cấp nhiều preset ở `~/.local/share/fastfetch/presets/hyde/*.jsonc`.

---

## 10. LSD (ls đẹp)

- `config.yaml`: bật icon, phân loại, sort thư mục trước…
- `colors.yaml`: bảng màu cho loại file/quyền.
- `icons.yaml`: ánh xạ phần mở rộng/tên file → icon Nerd Font.

---

## 11. WLOGOUT (menu đăng xuất)

- `layout_1`, `layout_2`: định nghĩa các nút (lock, logout, suspend, reboot, shutdown, hibernate) + lệnh tương ứng.
- `style_1.css`, `style_2.css`: giao diện 2 kiểu khác nhau.
- `icons/`: icon SVG cho từng nút.

---

## 12. SWAYLOCK (màn khóa thay thế hyprlock)

### 12.1 `config`
- Tham số khóa: hiệu ứng blur/clock/indicator, màu vòng tròn nhập mật khẩu (thường do wallbash sinh màu).

---

## 13. FISH (shell thay thế)

- `config.fish`: file chính của bạn.
- `conf.d/`, `functions/`, `completions/`: HyDE quản lý (giống cơ chế zsh).
- `user.fish`: nơi tùy chỉnh cá nhân.

---

## 14. THEMING QT/GTK

- `gtk-3.0/settings.ini`, `.gtkrc-2.0`: theme GTK (do nwg-look ghi).
- `qt5ct/`, `qt6ct/` + `colors.conf` (flag **T**, sinh theo theme): theme Qt, trỏ tới Kvantum.
- `Kvantum/`: theme SVG cho Qt.
- `xsettingsd/`: đồng bộ thiết lập XSettings cho app X11.
- `kdeglobals`, `dolphinrc`: thiết lập KDE/Dolphin (màu, font, hành vi).

---

## Tóm tắt: nguyên tắc sửa an toàn

| Thành phần | Sửa file của bạn | KHÔNG sửa (tự sinh/HyDE) |
|-----------|------------------|--------------------------|
| Hyprland | `userprefs.conf`, `keybindings.conf`, `monitors.conf` | `~/.local/share/hypr/*`, `themes/*` |
| Kitty | `kitty.conf` | `hyde.conf`, `theme.conf` |
| Zsh | `.zshrc`, `user.zsh` | `conf.d/hyde/*`, `00-hyde.zsh` |
| Dunst | `dunst.conf` (+ chạy `hyde-shell wallbash dunst`) | `dunstrc` |
| Waybar | `user-style.css` | `style.css`, `theme.css`, `modules/` |
| Rofi | `theme.rasi` (màu) | layout HyDE |
| Starship | `starship.toml` | — |
