# HyDE Hyprland — Đánh giá, Tài liệu & Hướng dẫn Refactor

> Phạm vi: tài liệu này đánh giá cấu hình Hyprland trong `Configs/.config/hypr`
> (và backend của nó trong `Configs/.local`), mô tả từng file, và đề xuất cách
> refactor thư mục `.config` thành một bộ có thể copy-paste lên máy Arch mới
> **sau khi** đã cài đủ package.

---

## 1. Bức tranh tổng thể — HyDE nạp Hyprland như thế nào

HyDE **không** nhét tất cả thiết lập Hyprland vào `~/.config/hypr/hyprland.conf`.
Nó chia config thành nhiều tầng:

| Tầng | Vị trí | Ai sở hữu | Mục đích |
|------|--------|-----------|----------|
| **Tầng người dùng** | `~/.config/hypr/` | **Bạn** chỉnh sửa | Tinh chỉnh cá nhân: keybind, monitor, prefs |
| **Tầng backend** | `~/.local/share/hypr/` + `~/.local/share/hyde/` | HyDE (bị ghi đè khi update) | Mặc định, env, startup, variables, bộ loader chính |
| **Tầng logic** | `~/.local/lib/hyde/` + `~/.local/bin/hyde-shell` | HyDE | Các script mà mọi keybind gọi tới |
| **Tầng tự sinh** | `~/.config/hypr/themes/*.conf`, `~/.local/state/hyde/` | wallbash / script | Màu sắc & giá trị theme theo từng wallpaper |

### Thứ tự nạp thực tế

```
~/.config/hypr/hyprland.conf            ← điểm vào (người dùng sửa, rất gọn)
   │
   ├─ source ~/.local/share/hyde/hyprland.conf   ← BỘ LOADER CHÍNH CỦA HYDE
   │     ├─ ~/.local/share/hypr/env.conf          (biến môi trường)
   │     ├─ ~/.local/share/hypr/variables.conf    ($mainMod, lệnh app, service $start.*)
   │     ├─ ~/.local/share/hypr/defaults.conf     (mặc định monitor/decoration/animation/input)
   │     ├─ ~/.local/share/hypr/windowrules.conf  (quy tắc cửa sổ gốc của HyDE)
   │     ├─ ~/.local/share/hypr/dynamic.conf      (keo dán theming → source file theme người dùng)
   │     │     ├─ ~/.config/hypr/themes/colors.conf    (wallbash, tự sinh)
   │     │     ├─ ~/.config/hypr/themes/theme.conf     (giao diện theme, tự sinh/sửa được)
   │     │     ├─ ~/.config/hypr/themes/wallbash.conf  (giá trị theme đã làm sạch)
   │     │     ├─ ~/.config/hypr/nvidia.conf
   │     │     ├─ ~/.config/hypr/animations.conf  → animations/<preset>.conf
   │     │     ├─ ~/.config/hypr/shaders.conf
   │     │     └─ ~/.local/state/hyde/hyprland.conf    (biên dịch từ hyde/config.toml)
   │     ├─ ~/.local/share/hypr/startup.conf      (exec-once: daemon/applet)
   │     ├─ ~/.config/hypr/workflows.conf  → workflows/<preset>.conf
   │     └─ ~/.local/share/hypr/finale.conf       (export property hyde:*)
   │
   ├─ source ./keybindings.conf
   ├─ source ./windowrules.conf
   ├─ source ./monitors.conf
   └─ source ./userprefs.conf       ← override cá nhân (cố tình nạp cuối cùng)
```

**Điểm mấu chốt cho phần refactor (Mục 4):** các file trong `~/.config/hypr`
*tự thân chúng vô dụng*. Chúng `source` các file trong `~/.local/share` và gọi
binary `hyde-shell` ở `~/.local/bin`. Chỉ copy riêng `.config` sẽ cho ra một
phiên làm việc hỏng.

---

## 2. Mô tả từng file — `~/.config/hypr` (tầng người dùng)

Đây là các file HyDE đánh dấu **P (Preserve - Giữ nguyên)** — tạo một lần rồi
là của bạn để sửa. Chúng sống sót qua các lần update HyDE.

### File điểm vào & file người dùng

| File | Sửa được? | Chức năng |
|------|-----------|-----------|
| `hyprland.conf` | ✅ có | Điểm vào gọn nhẹ. Có marker `$HYDE_HYPRLAND=set` (đừng xóa dòng đầu — nó ngăn HyDE ghi đè file). Source bộ loader chính + 4 file người dùng bên dưới. |
| `keybindings.conf` | ✅ có | Tất cả phím tắt. Dùng `bindd` (có mô tả), nhóm qua quy ước `$d=[Nhóm\|Nhóm phụ]` để GUI/rofi hiển thị. Cú pháp v0.53+. Hầu hết bind gọi `hyde-shell <lệnh con>`. |
| `windowrules.conf` | ✅ có | `windowrule`/`layerrule` theo từng app: opacity, quy tắc float, Picture-in-Picture, blur cho rofi/notifications/swaync. Bọc trong `# hyprlang if WINDOWRULES_HYPRLAND_V_0_53`. |
| `monitors.conf` | ✅ có | **Trống mặc định.** Đặt dòng `monitor = ...` của bạn vào đây. Nếu không động vào → mặc định `,preferred,auto,auto` từ `defaults.conf`. |
| `userprefs.conf` | ✅ có | Override cá nhân — nạp **cuối cùng** nên thắng. Có sẵn block stub cho `input`, `gestures`, `misc { enable_swallow }`, `ecosystem`. Đây là nơi nên đặt hầu hết tinh chỉnh. |
| `nvidia.conf` | ✅ có | Biến env NVIDIA (`LIBVA_DRIVER_NAME`, `GBM_BACKEND`, `__GLX_VENDOR_LIBRARY_NAME`), `no_hardware_cursors = true`. Chỉ liên quan khi dùng GPU NVIDIA. |
| `hypridle.conf` | ✅ có | Daemon nghỉ: 60s giảm sáng → 120s khóa → 300s tắt màn hình (DPMS) → 500s suspend. Khóa/mở khóa qua `hyde-shell lockscreen.sh`. |
| `hyprsunset.conf` | ✅ có | Profile lọc ánh sáng xanh ngày/đêm (mặc định comment hết). |

### File "selector" do HyDE quản lý (sửa qua script, không sửa tay)

Mỗi file chứa một `$VAR` + dòng `source` trỏ tới thư mục preset. Bạn đổi chúng
bằng cách chạy script selector, không sửa trực tiếp.

| File | Đổi bằng | Chọn từ |
|------|----------|---------|
| `animations.conf` | `hyde-shell animations --select` | `animations/*.conf` |
| `workflows.conf` | `hyde-shell workflows select` | `workflows/*.conf` |
| `shaders.conf` | `hyde-shell shaders --select` | `shaders/*.frag` |
| `hyprlock.conf` | `hyde-shell hyprlock --select` | `hyprlock/*.conf` |

### Thư mục preset

| Thư mục | Nội dung | Ghi chú |
|---------|----------|---------|
| `animations/` | 19 preset (`classic`, `dynamic`, `fast`, `minimal-1/2`, `me-1/2`, `diablo-1/2`, `disable`, `theme`, …) | Mỗi file là một block `animations { bezier… animation… }` độc lập. `theme.conf` là cái đang được chọn bởi `animations.conf`. |
| `workflows/` | `default`, `gaming`, `editing`, `powersaver`, `snappy` | Mỗi cái bật/tắt decoration/blur/gaps/animation cho một tình huống. `gaming.conf` tắt blur/shadow/rounding để tối đa hiệu năng. |
| `shaders/` | Shader GLSL `.frag`: `blue-light-filter`, `grayscale`, `invert-colors`, `vibrance`, `oled-saver`, `paper`, `color-vision`, `wallbash`, `custom`, `disable` | `.compiled.cache.glsl` là file tự sinh; `wallbash.inc` chứa define tùy biến. `screen_shader` trỏ tới shader đã biên dịch. |
| `hyprlock/` | Layout màn khóa: `HyDE`, `Anurati`, `SF Pro`, `IBM Plex`, `Arfan on Clouds`, `greetd`, `greetd-wallbash` | `theme.conf` chỉ `source = ./HyDE.conf` (layout đang dùng). |
| `themes/` | `colors.conf`, `theme.conf`, `wallbash.conf` | **Tự sinh** bởi wallbash từ wallpaper hiện tại. ⚠️ Bản đang commit chứa đường dẫn home của người khác (`/home/khing/...`) và màu cũ — chỉ là placeholder, sẽ sinh lại khi áp theme lần đầu. |

---

## 3. Mô tả từng file — `~/.local/share/hypr` (backend HyDE)

⚠️ Các file này bị ghi đè mỗi lần update HyDE — **đừng sửa**; hãy override
trong `userprefs.conf`.

| File | Định nghĩa gì |
|------|---------------|
| `hyprland.conf` (trong `share/hyde/`) | **Bộ loader chính** — điều phối toàn bộ chuỗi source ở §1. Đặt fallback `$XDG_*`, bọc bằng `hyprlang if !CONFIG_ALREADY_LOADED`. |
| `env.conf` | Biến env Wayland/Qt/GTK/Electron (`QT_QPA_PLATFORM=wayland;xcb`, `MOZ_ENABLE_WAYLAND=1`, `ELECTRON_OZONE_PLATFORM_HINT=auto`), thư mục XDG, và prepend `~/.local/bin` + `~/.local/lib/hyde` vào `PATH`. |
| `variables.conf` | `$mainMod=SUPER`; lệnh khởi chạy app (`$BROWSER`, `$EDITOR`, `$TERMINAL`, …); định nghĩa service `$start.*` (waybar, dunst, hypridle, hyprsunset, nm-applet, blueman, udiskie, cliphist, wallpaper) chạy như systemd unit qua `hyde-shell app`; biến theme/cursor/font mặc định. |
| `defaults.conf` | `monitor` mặc định, `decoration` (opacity/blur), block `animations` gốc, `input` (accel flat, numlock), gesture, layout dwindle/master, `misc` (tắt logo/splash, vrr), `xwayland` zero-scaling, snap cho floating. |
| `windowrules.conf` | Quy tắc cửa sổ nền của HyDE (tách biệt với `~/.config/hypr/windowrules.conf` của bạn). |
| `dynamic.conf` | Keo dán theming: source các file `themes/*.conf` của bạn, nvidia/animations/shaders, file state; set màu groupbar từ biến wallbash; định nghĩa `$exec.mkdir` + sinh keybind-hint chạy khi reload. |
| `startup.conf` | Tất cả dòng `exec-once`: import env dbus/systemd, polkit agent, waybar, dunst, daemon wallpaper, clipboard watcher, applet, battery notify, hypridle, hyprsunset, set cursor. |
| `finale.conf` | Export mọi giá trị đã giải quyết thành property `hyde { … }` (query nhanh hơn biến `$var` động). |
| `migration.conf`, `hyprlock.conf`, `hyprlock-fingerprint.conf` | Shim migration khi update và boilerplate hyprlock mà `hyprlock.conf` người dùng source. |

### Backend hỗ trợ

- `~/.local/share/hyde/` — schema config, template `config.toml`, file **migration**, và **template** (vd `templates/hypr/keybindings.conf` để cập nhật thủ công sau thay đổi phá vỡ tương thích).
- `~/.local/lib/hyde/` — script thực thi thật (`hypr.altab.lua`, `hyprlock.sh`, `hyprsunset.sh`, `keybinds/hint-hyprland.py`, `session/compositor/hyprland.py`, color/`hypr.sh`, các backend wallpaper). **Mọi lệnh con `hyde-shell` nằm ở đây.**
- `~/.local/bin/hyde-shell`, `hydectl` — binary điều phối mà gần như mọi keybind gọi.
- `~/.local/share/wallbash/` — template wallpaper→màu (`.dcol`) sinh ra `themes/colors.conf` v.v.

---

## 4. Refactor: làm cho `.config` copy-paste được trên máy Arch mới

### 4.1 Vì sao `cp -r .config ~/` đơn thuần sẽ KHÔNG chạy

1. **`~/.config/hypr/hyprland.conf` source `~/.local/share/hyde/hyprland.conf`.** Thiếu `.local` → Hyprland lỗi ngay lúc khởi động.
2. **~90% keybind gọi `hyde-shell …`**, tức `~/.local/bin/hyde-shell` + thư viện script ở `~/.local/lib/hyde`. Không có nó, audio/độ sáng/screenshot/wallpaper/rofi/khóa màn hình đều hỏng.
3. **File theme là tự sinh.** Bản `themes/colors.conf` / `wallbash.conf` đang commit mang đường dẫn home của người lạ và màu cũ; phải để wallbash sinh lại lần chạy đầu.
4. **Service được khởi chạy qua `hyde-shell app -u … -t service`**, vốn cần các wrapper service của HyDE tồn tại.
5. Nhiều app không thuộc hypr cũng chia ra `.local` (waybar, dolphin, fastfetch, zsh).

**Kết luận:** đơn vị triển khai không phải `.config` — mà là `.config` **+**
`.local/share/{hyde,hypr,wallbash,waybar,…}` **+** `.local/lib/hyde` **+**
`.local/bin/{hyde-shell,hydectl}` **+** vài dotfile trong `$HOME`.

### 4.2 Hướng tiếp cận khuyến nghị — giữ nguyên bố cục HyDE, bọc trong 1 script apply

`Scripts/restore_cfg.psv` của repo đã mã hóa **chính xác** file nào đi đâu và
cần package gì. **Đừng chống lại nó — hãy tái dùng.** Refactor theo hướng một
bộ tự chứa + một script apply idempotent.

#### Cấu trúc thư mục đề xuất

```
hyde-bundle/
├── apply.sh                 # lệnh duy nhất chạy sau khi cài package
├── packages.txt             # danh sách pacman/AUR rõ ràng (xem 4.3)
├── home/                    # phản chiếu $HOME y hệt — dễ kéo-thả
│   ├── .config/             # ← Configs/.config hiện có của bạn
│   │   └── hypr/ …
│   ├── .local/
│   │   ├── bin/   (hyde-shell, hydectl)
│   │   ├── lib/hyde/
│   │   ├── share/{hyde,hypr,wallbash,waybar,fastfetch,dolphin,…}
│   │   └── state/hyde/
│   ├── .gtkrc-2.0
│   └── .zshenv
└── README.md
```

Phản chiếu `$HOME` dưới `home/` giúp bước apply về cơ bản chỉ là "copy `home/*`
vào `~`", nhưng script thêm logic P/S/O để không ghi đè file bạn đã sửa.

#### `apply.sh` (phác thảo)

```bash
#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "$0")/home" && pwd)"
BACKUP="$HOME/.hyde-backup-$(date +%s)"

# 1. Giữ nguyên file người dùng (chỉ copy nếu chưa có) — nhóm "P"
preserve=(
  ".config/hypr/keybindings.conf" ".config/hypr/userprefs.conf"
  ".config/hypr/monitors.conf"    ".config/hypr/windowrules.conf"
  ".config/hypr/hyprland.conf"    ".config/hyde/config.toml"
  # …phản chiếu các dòng cờ P trong restore_cfg.psv…
)
# 2. Luôn ghi đè backend HyDE — nhóm "S/O"
overwrite=(
  ".local/share/hyde" ".local/share/hypr" ".local/share/wallbash"
  ".local/lib/hyde"   ".local/bin/hyde-shell" ".local/bin/hydectl"
)

copy_preserve() { [ -e "$HOME/$1" ] || { mkdir -p "$HOME/$(dirname "$1")"; cp -r "$SRC/$1" "$HOME/$1"; }; }
copy_overwrite(){ mkdir -p "$HOME/$(dirname "$1")"; [ -e "$HOME/$1" ] && { mkdir -p "$BACKUP/$(dirname "$1")"; cp -r "$HOME/$1" "$BACKUP/$1"; }; cp -rf "$SRC/$1" "$HOME/$1"; }

for f in "${preserve[@]}";  do copy_preserve  "$f"; done
for f in "${overwrite[@]}"; do copy_overwrite "$f"; done

chmod +x "$HOME/.local/bin/hyde-shell" "$HOME/.local/bin/hydectl"

# 3. Sinh theme/màu từ wallpaper (thay thế file cũ đang commit)
"$HOME/.local/bin/hyde-shell" wallpaper --backend hyprpaper --global || true
"$HOME/.local/bin/hyde-shell" theme --select || true   # hoặc themeselect

echo "Xong. Backup file bị ghi đè ở: $BACKUP"
echo "Đăng xuất rồi khởi động phiên Hyprland (uwsm)."
```

> Phiên bản gọn nhất là gọi thẳng `Scripts/restore_cfg.sh` upstream, vốn đã
> phân tích `restore_cfg.psv` và xử lý P/S/O/B/T/I, restore font/service/shell,
> và kiểm tra phụ thuộc. "Refactor" của bạn có thể nhỏ gọn cỡ: **đóng gói
> `Configs/` + `Scripts/restore_*` + một wrapper mỏng** thay vì viết lại logic copy.

### 4.3 Cài package trước (phần "sau khi cài đủ package")

Sinh danh sách từ cột phụ thuộc đã có sẵn trong PSV, để package và file không
bao giờ lệch nhau:

```bash
# từ thư mục gốc repo — trích các dep duy nhất mà restore_cfg.psv khai báo
awk -F'|' '!/^#|^ |^$/{print $4}' Scripts/restore_cfg.psv \
  | tr ' ' '\n' | sort -u
```

Bộ cốt lõi mà riêng config Hyprland đòi hỏi:

- **Compositor & hệ sinh thái:** `hyprland`, `hyprlock`, `hypridle`, `hyprsunset`, `hyprpaper` (hoặc `swww`), `hyprpicker`, `hyprpolkitagent`, `xdg-desktop-portal-hyprland`
- **Phiên:** `uwsm`, `systemd`
- **Bar / notify / launcher / khóa:** `waybar`, `dunst` (hoặc `swaync`), `rofi`, `wlogout`, `swaylock-effects`
- **Theming:** `nwg-look`, `qt5ct`, `qt6ct`, `kvantum`, `imagemagick` (wallbash), `bash`
- **Tray/applet:** `network-manager-applet`, `blueman`, `udiskie`
- **Clipboard/media:** `cliphist`, `wl-clipboard`, `wl-clip-persist`, `playerctl`, `brightnessctl`
- **App trong keybind:** `kitty`, `dolphin`, `code`/`code-oss`, một trình duyệt, `pyprland` (`pypr`)
- **Tiện ích:** `jq` (dùng trong bind move/resize), `grim`/`slurp`+`satty` (screenshot), `cantarell-fonts` + các Nerd Font trong `variables.conf`

> Người dùng NVIDIA cần thêm `nvidia-utils`; các quy tắc trong `nvidia.conf` chỉ
> có ý nghĩa khi đó.

### 4.4 Checklist refactor cụ thể

1. **Ngừng commit file theme tự sinh.** Thêm `themes/colors.conf`, `themes/wallbash.conf`, `shaders/.compiled.cache.glsl`, `state/hyde/hyprland.conf` vào `.gitignore`; thay bằng `*.conf.example` hoặc sinh khi apply. (Tránh lộ `/home/khing/...`)
2. **Đóng gói cả cây phụ thuộc**, không chỉ `.config`: gồm `.local/{bin,lib,share,state}` theo §4.1.
3. **Một lệnh vào duy nhất.** Một `apply.sh` (hoặc tái dùng `restore_cfg.sh`) làm P/S/O kèm backup theo timestamp — không bao giờ `cp -r` mù.
4. **Ghim danh sách package** cạnh bộ bundle và sinh nó từ `restore_cfg.psv` để luôn đồng bộ.
5. **Hook sau khi apply** phải (a) `chmod +x` các binary `~/.local/bin` và (b) chạy một lần apply wallpaper/theme để wallbash sinh lại màu.
6. **Giữ nguyên tách biệt user/backend** — đừng gộp `.local/share/hypr` vào `.config/hypr`; update HyDE dựa vào nó.
7. **Tài liệu hóa dòng marker** (`$HYDE_HYPRLAND=set`) để người dùng biết không được xóa.

---

## 5. Tham chiếu nhanh — sửa gì vs. không động vào gì

| Tôi muốn… | Sửa file này | Đừng động vào |
|-----------|--------------|---------------|
| Đổi một keybind | `~/.config/hypr/keybindings.conf` | |
| Cài đặt monitor | `~/.config/hypr/monitors.conf` | |
| Tinh chỉnh Hyprland cá nhân | `~/.config/hypr/userprefs.conf` | `defaults.conf` |
| Đổi animation/workflow/shader/khóa | chạy `hyde-shell <x> --select` | các file `*.conf` selector bằng tay |
| Đổi màu theme | áp một wallpaper/theme | `themes/colors.conf` (tự sinh) |
| Thêm app khởi động | `userprefs.conf` (`exec-once=`) | `startup.conf` |
| Đổi lệnh khởi chạy app | `hyde/config.toml` | `variables.conf` |
