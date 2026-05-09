#!/bin/bash
# ==========================================
# easyroot.sh
# MODULE: AUTOMATIC ROOT ACCESS ENABLER (INTERACTIVE)
# Deskripsi: Mengaktifkan login root & password via SSH dengan input manual
# ==========================================

clear
echo "=========================================="
echo "      SETTING AKSES ROOT VPS             "
echo "=========================================="

# Fungsi untuk meminta password secara interaktif
get_password() {
    while true; do
        echo -n "Masukkan Password Root Baru: "
        read -s NEW_PASS
        echo ""
        echo -n "Konfirmasi Password Root   : "
        read -s CONFIRM_PASS
        echo ""

        if [[ -z "$NEW_PASS" ]]; then
            echo -e "\e[31m[ERROR]\e[0m Password tidak boleh kosong!\n"
        elif [[ "$NEW_PASS" != "$CONFIRM_PASS" ]]; then
            echo -e "\e[31m[ERROR]\e[0m Password tidak cocok! Silakan coba lagi.\n"
        else
            break
        fi
    done
}

# Memulai proses pengambilan password
get_password

echo -e "\n[1/3] Mengatur password untuk user root..."
echo "root:$NEW_PASS" | chpasswd

echo -e "[2/3] Memperbarui konfigurasi SSH..."
# Mengubah PermitRootLogin menjadi yes
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

# Mengubah PasswordAuthentication menjadi yes
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Memastikan baris tersebut ada jika sed tidak menemukannya
if ! grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

if ! grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
fi

echo -e "[3/3] Menyiapkan reboot sistem..."
sleep 2

echo -e "\n=========================================="
echo "  AKSES ROOT BERHASIL DIAKTIFKAN!"
echo "  Silakan login dengan user: root"
echo "  Server akan reboot dalam 5 detik..."
echo "=========================================="
sleep 5

reboot
