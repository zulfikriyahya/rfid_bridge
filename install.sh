#!/usr/bin/env bash
set -euo pipefail

REPO="zulfikriyahya/rfid_bridge"
BINARY_NAME="rfid_bridge"
INSTALL_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"

echo "==> RFID Bridge Installer"
echo "==> Membuat direktori instalasi..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$SERVICE_DIR"

echo "==> Mengambil rilis terbaru dari GitHub..."
LATEST_URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep "browser_download_url.*x86_64-unknown-linux-gnu" \
  | cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
  echo "ERROR: Gagal menemukan binary rilis terbaru."
  echo "Pastikan sudah ada Release dengan asset 'x86_64-unknown-linux-gnu' di:"
  echo "https://github.com/${REPO}/releases"
  exit 1
fi

echo "==> Mengunduh binary dari: $LATEST_URL"
curl -fsSL -o "$INSTALL_DIR/$BINARY_NAME" "$LATEST_URL"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

echo "==> Menulis unit file systemd (user service)..."
cat > "$SERVICE_DIR/rfid-bridge.service" << EOF
[Unit]
Description=RFID Bridge Service
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=${INSTALL_DIR}/${BINARY_NAME}
Restart=always
RestartSec=2

[Install]
WantedBy=default.target
EOF

echo "==> Reload systemd user daemon..."
systemctl --user daemon-reload

echo "==> Enable service supaya jalan otomatis saat login..."
systemctl --user enable rfid-bridge.service

echo "==> Enable lingering (agar service tetap jalan meski belum login manual)..."
if command -v sudo >/dev/null 2>&1; then
  sudo loginctl enable-linger "$USER" || echo "Peringatan: gagal enable-linger, mungkin butuh password sudo interaktif. Jalankan manual: sudo loginctl enable-linger \$USER"
fi

echo "==> Menjalankan service sekarang..."
systemctl --user start rfid-bridge.service

echo ""
echo "=================================================="
echo "Instalasi selesai."
echo "Cek status  : systemctl --user status rfid-bridge.service"
echo "Lihat log   : journalctl --user -u rfid-bridge.service -f"
echo "=================================================="
