# HyDE — Tổng hợp Packages & File cấu hình theo từng thành phần

> Mục đích: liệt kê **(A)** các file chứa danh sách package, và **(B)** map từng
> thành phần (Hyprland, Waybar, Kitty, Zsh, …) → package cần cài → file cấu hình
> cần copy. Dùng làm checklist khi dựng lại HyDE trên Arch.

---

## A. Các file chứa danh sách PACKAGE (đều nằm trong `Scripts/`)

| File | Nội dung | Định dạng |
|------|----------|-----------|
| `Scripts/pkg_core.lst` | **Package bắt buộc** (87 dòng): hệ thống, WM, theming, app cơ bản | `package # comment`, `package|aur_helper` nếu là AUR |
| `Scripts/pkg_extra.lst` | **Package tùy chọn**: gaming, music, OSD, editor thay thế… (đa số comment sẵn) | như trên |
| `Scripts/restore_fnt.lst` | **Font & con trỏ chuột** (tarball → thư mục đích) | `Tên_Font|đường_dẫn` |
| `Scripts/restore_svc.lst` | **Systemd service** cần bật (NetworkManager, bluetooth, sddm) | `service|root\|user|enable/start` |
| `Scripts/restore_zsh.lst` | **Plugin zsh** cần cài (git, autosuggestions, syntax-highlighting…) | tên plugin hoặc URL git |
| `Scripts/restore_cfg.psv` | ⭐ **File map quan trọng nhất**: config nào → thư mục nào → cần package gì | `flag|path|files|dependency` |
| `Scripts/restore_cfg.lst` | Danh sách bổ trợ cho `restore_cfg.sh` | |

> Ký hiệu cú pháp `package|something` nghĩa là: chỉ cài `package` nếu `something`
> (aur helper / shell) cũng được chọn. Ví dụ `bat|zsh` = cài `bat` khi dùng zsh.

### Package CỐT LÕI (trích `pkg_core.lst`)

```
# Hệ thống / âm thanh / mạng
uwsm pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse
gst-plugin-pipewire wireplumber pavucontrol pamixer
networkmanager network-manager-applet bluez bluez-utils blueman
brightnessctl playerctl udiskie

# Display manager
sddm qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects

# Window manager + môi trường Wayland
hyprland dunst rofi waybar swww hyprlock wlogout grim hyprpicker
slurp satty cliphist wl-clip-persist hyprsunset

# Phụ thuộc
hyprpolkitagent xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
xdg-user-dirs pacman-contrib parallel jq imagemagick
qt5-imageformats ffmpegthumbs kde-cli-tools libnotify noto-fonts-emoji

# Theming Qt/GTK
nwg-look qt5ct qt6ct kvantum kvantum-qt5 qt5-wayland qt6-wayland

# Ứng dụng
firefox kitty dolphin ark unzip vim code nwg-displays fzf

# Shell + HyDE core
starship fastfetch hyprquery hypridle
```

### Package TÙY CHỌN đáng chú ý (`pkg_extra.lst`)

```
wttrbar python-requests ddcui            # thời tiết / điều khiển màn hình ngoài
wf-recorder kimageformats                # quay màn hình / định dạng ảnh
steam gamemode mangohud                  # gaming
cava spotify spicetify-cli               # nhạc
bat eza duf                              # thay thế cat/ls/df cho zsh & fish
swayosd-git                              # OSD volume/capslock
```

### Font & Cursor (`restore_fnt.lst`)

```
CascadiaCove, MaterialDesign, JetBrainsMono, MapleNerd,
MononokiNerd, NotoSansCJK          → ~/.local/share/fonts
Bibata-Modern-Ice (cursor)         → ~/.local/share/icons
Wallbash (gtk theme + icon)        → ~/.local/share/themes, ~/.local/share/icons
```

### Service cần bật (`restore_svc.lst`)

```
NetworkManager | root | enable --now
bluetooth      | root | enable --now
sddm           | root | enable
```

---

## B. Map theo TỪNG THÀNH PHẦN: package + file cấu hình

> Cờ ở cột "Loại": **P** = giữ nguyên nếu đã có (file của bạn), **S/O** = HyDE
> ghi đè khi update (đừng sửa tay). Dữ liệu lấy từ `restore_cfg.psv`.

### 1. Hyprland (compositor) — `hyprland hyprlock hypridle hyprsunset`

| Loại | Đích | File |
|------|------|------|
| P | `~/.config/hypr` | `hyprland.conf` `keybindings.conf` `windowrules.conf` `monitors.conf` `userprefs.conf` `animations.conf` `workflows.conf` `shaders.conf` `nvidia.conf` `hyprlock.conf` `hypridle.conf` `hyprsunset.conf` |
| P | `~/.config/hypr/themes` | `theme.conf` `wallbash.conf` `colors.conf` *(tự sinh)* |
| S | `~/.config/hypr` | thư mục `animations/` `workflows/` `shaders/` `hyprlock/` |
| S | `~/.local/share` | toàn bộ `hypr/` *(backend: env, variables, defaults, startup, finale…)* |
| O | `~/.local/share` | `hyde/` *(loader + templates + migration)* |
| O | `~/.local/lib` | `hyde/` *(scripts mà keybind gọi)* |
| O | `~/.local/bin` | `hyde-shell` `hydectl` ⭐ bắt buộc |
| P | `~/.local/state/hyde` | `hyprland.conf` *(biên dịch từ config.toml)* |
| P | `~/.config/hyde` | `config.toml` |
| S | `~/.config/hyde` | `wallbash/` *(template sinh màu)* |

> ⚠️ Hyprland **không chạy** nếu thiếu `~/.local/share/hypr`, `~/.local/lib/hyde`
> và `~/.local/bin/hyde-shell`. Xem chi tiết trong `HYPRLAND_CONFIG_GUIDE.md`.

### 2. Waybar (thanh trạng thái) — `waybar` *(+ `wttrbar` cho thời tiết)*

| Loại | Đích | File |
|------|------|------|
| P | `~/.config/waybar` | `config.jsonc` `style.css` `theme.css` `user-style.css` |
| I | `~/.config/waybar` | `modules/` `styles/` `layouts/` `menus/` |
| S | `~/.local/share` | `waybar/` *(layout HyDE, module dựng sẵn)* |

### 3. Kitty (terminal) — `kitty`

| Loại | Đích | File |
|------|------|------|
| P | `~/.config/kitty` | `kitty.conf` *(file chính, bạn sửa)* |
| S | `~/.config/kitty` | `hyde.conf` `theme.conf` *(HyDE quản lý màu/font)* |

### 4. Zsh (shell) — `zsh starship fzf` *(+ `bat eza duf`)*

| Loại | Đích | File |
|------|------|------|
| S | `~` | `.zshenv` |
| S | `~/.config/zsh` | `.zshenv` |
| S | `~/.config/zsh/conf.d` | `hyde` `00-hyde.zsh` |
| S | `~/.config/zsh/functions` | `error-handlers.zsh` `fzf.zsh` `duf.zsh` `eza.zsh` `bat.zsh` |
| S | `~/.config/zsh/completions` | `fzf.zsh` `hydectl.zsh` |
| P | `~/.config/zsh` | `.zshrc` `user.zsh` `prompt.zsh` `plugin.zsh` `.p10k.zsh` |

> Plugin zsh cài thêm theo `restore_zsh.lst` (autosuggestions, syntax-highlighting…).

### 5. Fish (shell thay thế) — `fish starship`

| Loại | Đích | File |
|------|------|------|
| S | `~/.config/fish` | `conf.d/` `functions/` `completions/` |
| P | `~/.config/fish` | `config.fish` |

### 6. Starship (prompt) — `starship`

| Loại | Đích | File |
|------|------|------|
| P | `~/.config/starship` | `starship.toml` |

### 7. Fastfetch — `fastfetch`

| Loại | Đích | File |
|------|------|------|
| P | `~/.config` | `fastfetch/` |
| O | `~/.local/share/fastfetch/presets` | `hyde/` |

### 8. Rofi (launcher) — `rofi`

| Loại | Đích | File |
|------|------|------|
| P | `~/.config` | `rofi/` |

### 9. Dunst (thông báo) — `dunst`

| Loại | Đích | File |
|------|------|------|
| S | `~/.config` | `dunst/` |

### 10. Wlogout (menu đăng xuất) — `wlogout`

| Loại | Đích | File |
|------|------|------|
| S | `~/.config` | `wlogout/` |

### 11. Lock screen — `hyprlock` *(và/hoặc `swaylock-effects`)*

| Loại | Đích | File |
|------|------|------|
| P | `~/.config/hypr` | `hyprlock.conf` |
| S | `~/.config/hypr` | `hyprlock/` *(các layout)* |
| S | `~/.config` | `swaylock/` |

### 12. Trình soạn thảo VS Code — `code` / `code-oss` / `vscodium`

| Loại | Đích | File |
|------|------|------|
| P | `~/.config/Code - OSS/User` | `settings.json` |
| P | `~/.config/Code/User` | `settings.json` |
| P | `~/.config/VSCodium/User` | `settings.json` |

### 13. Dolphin + KDE theming — `dolphin`

| Loại | Đích | File |
|------|------|------|
| P | `~/.local/state` | `dolphinstaterc` |
| P | `~/.config` | `baloofilerc` |
| S | `~/.config` | `dolphinrc` `kdeglobals` `menus/applications.menu` |
| S | `~/.local/share` | `dolphin/` + servicemenu + kxmlgui5 |

### 14. Theming Qt/GTK — `nwg-look qt5ct qt6ct kvantum`

| Loại | Đích | File |
|------|------|------|
| S | `~/.config` | `gtk-3.0` `nwg-look` `xsettingsd` `Kvantum` `qt5ct` `qt6ct` |
| S | `~` | `.gtkrc-2.0` |
| T | `~/.config/qt5ct` `~/.config/qt6ct` | `colors.conf` *(sinh theo theme)* |

### 15. Vim — `vim`

| Loại | Đích | File |
|------|------|------|
| P | `~/.config/vim` | `vimrc` |
| S | `~/.config/vim` | `hyde.vim` `colors/wallbash.vim` |

### 16. Các tiện ích khác

| Thành phần | Package | File |
|-----------|---------|------|
| Pyprland (dropdown term) | `pyprland` | `~/.config/pypr/config.toml` (P) |
| Session uwsm | `uwsm systemd` | `~/.config/uwsm/{env,env-hyprland,env.d,…}` (S) |
| lsd (ls đẹp) | `lsd` | `~/.config/lsd` (P) |
| Cử chỉ touchpad | `libinput-gestures` | `~/.config/libinput-gestures.conf` (P) |
| MangoHud (gaming) | `mangohud` | `~/.config/MangoHud` (S) |
| Cờ Wayland cho app | `spotify code electron` | `~/.config/{spotify,code,codium,electron}-flags.conf` (P) |
| systemd user units | `systemd` | `~/.config/systemd/user` (S) |
| xdg terminal | `xdg-utils` | `~/.config/xdg-terminals.list` (P) |

---

## C. Cách dùng nhanh khi cài trên Arch

```bash
# 1. Cài package cốt lõi (bỏ comment, bỏ phần |aurhelper)
sudo pacman -S --needed $(grep -vE '^\s*#|^\s*$' Scripts/pkg_core.lst | awk '{print $1}' | cut -d'|' -f1)

# 2. (Tùy chọn) package thêm
yay -S --needed $(grep -vE '^\s*#|^\s*$' Scripts/pkg_extra.lst | awk '{print $1}' | cut -d'|' -f1)

# 3. Bật service
sudo systemctl enable --now NetworkManager bluetooth
sudo systemctl enable sddm

# 4. Triển khai config (dùng script HyDE sẵn có thay vì cp -r)
./Scripts/restore_cfg.sh        # đọc restore_cfg.psv, xử lý P/S/O + backup
./Scripts/restore_fnt.sh        # font + cursor
./Scripts/restore_zsh.sh        # plugin zsh

# 5. Đăng xuất, đăng nhập lại bằng phiên Hyprland (uwsm)
```

> Lệnh trích package ở trên là cơ bản — một số dòng có cú pháp `pkg|cond`; script
> `install_pkg.sh` của HyDE xử lý các điều kiện đó chính xác hơn `awk` thủ công.
