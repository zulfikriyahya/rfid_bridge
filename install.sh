#!/usr/bin/env bash
set -euo pipefail

REPO="zulfikriyahya/rfid_bridge"
BINARY_NAME="rfid_bridge"
INSTALL_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"

echo "==> Membuat direktori instalasi..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$SERVICE_DIR"

echo "==> Mengambil rilis terbaru dari GitHub..."
LATEST_URL=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep "browser_download_url.*x86_64-unknown-linux-gnu" \
  | cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
  echo "Gagal menemukan binary rilis terbaru. Cek nama asset di GitHub Releases."
  exit 1
fi

echo "==> Mengunduh binary dari: $LATEST_URL"
curl -L -o "$INSTALL_DIR/$BINARY_NAME" "$LATEST_URL"
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

echo "==> Enable lingering supaya service tetap jalan walau belum login (opsional)..."
sudo loginctl enable-linger "$USER"

echo "==> Menjalankan service sekarang..."
systemctl --user start rfid-bridge.service

echo ""
echo "Instalasi selesai."
echo "Cek status dengan: systemctl --user status rfid-bridge.service"
