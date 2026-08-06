# RFID Bridge

Sistem RFID reader yang membaca kartu lewat modul RC522 di ESP32, lalu meneruskan UID sebagai input keyboard (auto-type + Enter) ke komputer — meniru cara kerja reader HID prox 125KHz atau barcode scanner USB biasa.

## Cara Kerja

```
[Kartu RFID] --> [RC522] --> [ESP32] --Serial (USB)--> [Rust Bridge] --> Simulasi Keyboard --> [Aplikasi Aktif]
```

ESP32 membaca UID kartu lewat modul RC522, mengirimkannya sebagai string desimal 10 digit lewat Serial. Program bridge di komputer (ditulis dalam Rust) membaca data ini dan "mengetik"-nya secara otomatis ke aplikasi yang sedang aktif/fokus, diikuti tombol Enter.

## Dukungan Board

| Board | Status |
|-------|--------|
| DOIT ESP32 Devkit V1 | ✅ Didukung |
| ESP32-C3 Super Mini | ✅ Didukung |

## Dukungan OS (Bridge)

| OS | Status |
|----|--------|
| Linux | ✅ Didukung (systemd user service) |
| Windows | ✅ Didukung |
| macOS | ⚠️ Perlu izin Accessibility manual |

---

## 1. Firmware ESP32

Source code firmware ada di folder `docs/`:
- `docs/doitdevkit1v1/main.ino` — untuk DOIT ESP32 Devkit V1
- `docs/c3supermini/main.ino` — untuk ESP32-C3 Super Mini

### Wiring

Lihat dokumentasi lengkap di [`docs/wiring.md`](docs/wiring.md).

### Upload Firmware

1. Buka file `.ino` sesuai board kamu di Arduino IDE
2. Pilih board yang sesuai:
   - `ESP32 Dev Module` untuk DOIT Devkit V1
   - `ESP32C3 Dev Module` untuk C3 Super Mini
3. Install library `MFRC522` lewat Library Manager
4. Upload

---

## 2. Bridge (Rust)

Program yang jalan di komputer, membaca Serial dari ESP32 dan mensimulasikan keyboard.

### Instalasi Cepat (Linux — Debian/Ubuntu)

Install langsung tanpa clone repo:

```bash
curl -fsSL https://raw.githubusercontent.com/zulfikriyahya/rfid_bridge/main/install.sh | bash
```

Script ini otomatis akan:
- Mengunduh binary rilis terbaru dari GitHub Releases
- Memasangnya di `~/.local/bin`
- Membuat systemd user service supaya berjalan otomatis saat login
- Mengaktifkan `linger` supaya tetap jalan meski belum login manual setelah reboot

### Instalasi Manual (build dari source)

Butuh [Rust](https://rustup.rs) terinstall.

```bash
git clone https://github.com/zulfikriyahya/rfid_bridge.git
cd rfid_bridge

# Linux — install dependency sistem dulu
sudo apt install libxdo-dev pkg-config libudev-dev

cargo build --release
# Binary ada di target/release/rfid_bridge
```

### Download Binary Manual

Binary siap pakai untuk setiap rilis tersedia di halaman [Releases](https://github.com/zulfikriyahya/rfid_bridge/releases).

---

## 3. Menjalankan Bridge

### Linux (setelah install via script)

Bridge otomatis berjalan sebagai systemd user service. Perintah yang berguna:

```bash
# Cek status
systemctl --user status rfid-bridge.service

# Lihat log real-time
journalctl --user -u rfid-bridge.service -f

# Restart manual
systemctl --user restart rfid-bridge.service

# Stop
systemctl --user stop rfid-bridge.service
```

### Manual (semua OS)

```bash
./rfid_bridge
```

Mode debug (menampilkan log koneksi & UID yang terbaca):

```bash
./rfid_bridge --verbose
```

---

## 4. Uninstall (Linux)

```bash
systemctl --user stop rfid-bridge.service
systemctl --user disable rfid-bridge.service
rm ~/.config/systemd/user/rfid-bridge.service
rm ~/.local/bin/rfid_bridge
systemctl --user daemon-reload
```

---

## Struktur Project

```
.
├── Cargo.toml              # Konfigurasi Rust project
├── install.sh              # Installer otomatis untuk Linux
├── src/
│   └── main.rs             # Source code bridge
├── docs/
│   ├── wiring.md           # Dokumentasi wiring RC522
│   ├── doitdevkit1v1/
│   │   └── main.ino        # Firmware untuk ESP32 Devkit V1
│   └── c3supermini/
│       └── main.ino        # Firmware untuk ESP32-C3 Super Mini
└── .github/
    └── workflows/
        └── build.yml       # CI/CD: build & publish release otomatis
```

---

## Development

### Build untuk semua platform sekaligus

Project ini menggunakan GitHub Actions untuk build otomatis. Setiap push tag berformat `v*` (misal `v1.0.0`) akan memicu build untuk Linux dan Windows, lalu otomatis publish ke [Releases](https://github.com/zulfikriyahya/rfid_bridge/releases).

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Build lokal untuk target tertentu

```bash
# Linux
cargo build --release --target x86_64-unknown-linux-gnu

# Windows (dari Linux, butuh mingw-w64)
rustup target add x86_64-pc-windows-gnu
cargo build --release --target x86_64-pc-windows-gnu
```

---

## Troubleshooting

**UID tidak terbaca sama sekali di Serial Monitor Arduino IDE**
Cek kembali wiring SPI (SCK/MISO/MOSI/SS) dan pastikan modul RC522 disuplai 3.3V (bukan 5V).

**Bridge tidak mendeteksi device ESP32**
Cek VID/PID device kamu, lalu pastikan sudah terdaftar di `find_esp32_port()` pada `src/main.rs`. Jalankan dengan `--verbose` untuk melihat status deteksi port.

**Enigo gagal inisialisasi (Linux)**
Pastikan dependency `libxdo-dev` sudah terinstall, dan sesi desktop yang dipakai adalah **X11**, bukan Wayland (dukungan Wayland untuk simulasi input masih terbatas).

**Enigo gagal inisialisasi (macOS)**
Berikan izin Accessibility ke aplikasi lewat System Settings → Privacy & Security → Accessibility.
