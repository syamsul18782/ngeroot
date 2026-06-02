#!/bin/bash

# ==========================================================================
# SCRIPT OTOMATIS: SETUP TRIPAY PAYMENT PROXY DI VPS
# srpcom store 2026
# ==========================================================================

# Mencegah eksekusi jika bukan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Silakan jalankan script ini sebagai root (atau gunakan sudo)."
  exit 1
fi

echo "====================================================="
echo "  MEMULAI INSTALASI TRIPAY PROXY SERVER DI VPS  "
echo "====================================================="

# 1. Menentukan VPS_API_KEY (Mengambil dari argumen pertama, atau default ke key user)
if [ -n "$1" ]; then
    VPS_KEY="$1"
    echo "-> Menggunakan VPS_API_KEY kustom: $VPS_KEY"
else
    VPS_KEY="465eaf4a-178c-4e8b-96d7-831f2568a9df"
    echo "-> Menggunakan VPS_API_KEY default: $VPS_KEY"
fi

# 2. Update System Packages
echo "-> Memperbarui daftar paket sistem..."
apt-get update -y

# 3. Install Node.js (Menggunakan NodeSource v18.x)
echo "-> Memasang Node.js v18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs build-essential curl git

# Verifikasi Node.js
NODE_VER=$(node -v)
NPM_VER=$(npm -v)
echo "   Node.js terpasang: $NODE_VER"
echo "   NPM terpasang: $NPM_VER"

# 4. Install PM2 Secara Global
echo "-> Memasang PM2 (Process Manager)..."
npm install pm2 -g

# 5. Membuat Folder Aplikasi dan Inisialisasi
echo "-> Menyiapkan direktori aplikasi..."
TARGET_DIR="/opt/tripay-proxy"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR" || exit 1

# Inisialisasi package.json dan instal Express
npm init -y > /dev/null
npm install express

# 6. Menulis server.js dengan Integrasi VPS_API_KEY
echo "-> Menulis file konfigurasi server.js..."
cat << EOF > server.js
const express = require('express');
const app = express();

app.use(express.json());

// Kunci Autentikasi VPS (Pencocokan dari Cloudflare Workers)
const VPS_API_KEY = "${VPS_KEY}";

app.post('/tripay_proxy', async (req, res) => {
    try {
        const vpsAuthHeader = req.headers['x-vps-auth'];
        const authorizationHeader = req.headers['authorization']; // Bearer TRIPAY_API_KEY

        // 1. Validasi Kunci Keamanan VPS
        if (!vpsAuthHeader || vpsAuthHeader !== VPS_API_KEY) {
            return res.status(401).json({ success: false, message: 'VPS Unauthorized (Wrong API Key)' });
        }

        // 2. URL API TriPay untuk Transaksi
        const tripayUrl = 'https://tripay.co.id/api/transaction/create';

        // 3. Teruskan request ke TriPay
        const response = await fetch(tripayUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': authorizationHeader
            },
            body: JSON.stringify(req.body)
        });

        const tripayData = await response.json();
        
        // 4. Kembalikan respon dari TriPay ke Cloudflare Worker
        return res.status(response.status).json(tripayData);

    } catch (error) {
        console.error("Proxy Error:", error);
        return res.status(500).json({ success: false, message: 'Internal Proxy Error: ' + error.message });
    }
});

const PORT = 8080;
app.listen(PORT, '0.0.0.0', () => {
    console.log(\`TriPay Proxy server running on port \${PORT}\`);
});
EOF

# 7. Menjalankan Aplikasi di Background via PM2
echo "-> Menyalakan aplikasi menggunakan PM2..."
pm2 start server.js --name "tripay-proxy"
pm2 save

# Mengatur startup PM2 agar otomatis jalan saat server reboot
env PATH=$PATH:/usr/bin pm2 startup systemd -u root --hp /root

# 8. Membuka Firewall Port 8080 (Menggunakan UFW jika terpasang)
if command -v ufw >/dev/null 2>&1; then
    echo "-> Membuka firewall port 8080 (UFW)..."
    ufw allow 8080/tcp
    ufw reload
fi

# 9. Dapatkan IP Publik VPS untuk mempermudah instruksi
PUBLIC_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || echo "IP_VPS_ANDA")

echo "====================================================="
echo "        🎉 INSTALASI SELESAI DENGAN SUKSES!         "
echo "====================================================="
echo "Gunakan detail berikut untuk dikonfigurasi pada Cloudflare Worker Anda:"
echo ""
echo "1. VPS_IP      : $PUBLIC_IP"
echo "2. VPS_API_KEY : $VPS_KEY"
echo ""
echo "Catatan: Pastikan VPS_API_KEY di atas disalin persis ke"
echo "Variabel Environment 'VPS_API_KEY' di panel Cloudflare Workers."
echo "====================================================="
