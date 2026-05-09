#!/bin/bash
# ==========================================
# easyroot.sh
# MODULE: AUTOMATIC ROOT ACCESS ENABLER (INTERACTIVE - VISIBLE)
# Deskripsi: Mengaktifkan login root & password via SSH dengan input manual (Teks Terlihat)
# ==========================================

clear
echo "=========================================="
echo "      SETTING AKSES ROOT VPS             "
echo "=========================================="
echo " PERINGATAN: Password akan terlihat saat "
echo " diketik untuk menghindari salah ketik.   "
echo "=========================================="

# Fungsi untuk meminta password secara interaktif
get_password() {
    while true; do
        # Menghapus flag -s agar password terlihat saat diketik
        echo -n "Masukkan Password Root Baru : "
        read NEW_PASS < /dev/tty
        echo -n "Konfirmasi Password Root    : "
        read CONFIRM_PASS < /dev/tty

        if [[ -z "$NEW_PASS" ]]; then
            echo -e "\n\e[31m[ERROR]\e[0m Password tidak boleh kosong!\n"
        elif [[ "$NEW_PASS" != "$CONFIRM_PASS" ]]; then
            echo -e "\n\e[31m[ERROR]\e[0m Password tidak cocok! Silakan coba lagi.\n"
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
sleep 1

echo -e "\n=========================================="
echo "      KONFIRMASI AKSES ROOT VPS          "
echo "=========================================="
echo " AKUN LOGIN ANDA TELAH SIAP:              "
echo "                                          "
echo " Username : root                          "
echo " Password : $NEW_PASS                     "
echo "                                          "
echo " CATATAN: Pastikan Anda mencatat password "
echo " di atas sebelum VPS melakukan reboot.    "
echo "=========================================="
echo " Server akan reboot dalam 10 detik...     "
echo "=========================================="
sleep 10

reboot
