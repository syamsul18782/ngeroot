🚀 EasyRoot VPS - Instant Root Enabler

EasyRoot VPS adalah solusi satu baris perintah (one-liner) untuk mengaktifkan akses login root melalui SSH pada VPS Ubuntu Anda secara otomatis. Sangat berguna untuk VPS dari penyedia seperti AWS, Google Cloud, atau Azure yang secara default menonaktifkan akses root atau hanya memberikan user biasa.

✨ Fitur Utama

⚡ Otomatisasi Total: Mengatur PermitRootLogin dan PasswordAuthentication dalam hitungan detik.

👁️ Input Password Aman: Password dibuat terlihat (visible) saat diketik untuk meminimalisir risiko gagal login akibat salah ketik (typo).

✅ Validasi Ganda: Sistem mengecek kesesuaian password dan konfirmasi sebelum melakukan perubahan pada sistem.

📝 Ringkasan Informasi: Menampilkan detail login (Username & Password) dengan jeda 10 detik agar Anda sempat mencatatnya.

🔄 Smart Reboot: Melakukan reboot otomatis untuk menerapkan konfigurasi baru secara instan.

🖥️ Cara Penggunaan

Cukup salin dan tempel perintah di bawah ini ke terminal VPS Anda (pastikan Anda sudah login menggunakan user biasa yang memiliki akses sudo):

```bash <(curl -Ls [https://raw.githubusercontent.com/syamsul18782/ngeroot/main/easyroot.sh]```


🛠️ Alur Kerja Skrip
Inisialisasi: Membersihkan layar dan menampilkan panduan input password.
Setup Password: Menghasilkan password root sesuai input manual yang Anda masukkan.
Konfigurasi SSH:
Mencari dan memodifikasi file /etc/ssh/sshd_config.
Mengizinkan login root dan autentikasi password secara eksplisit.
Verifikasi: Menampilkan teks konfirmasi detail akun root Anda untuk pengecekan terakhir.
Finalisasi: Menghitung mundur 10 detik, kemudian melakukan reboot sistem secara otomatis.

⚠️ Peringatan Keamanan
Mengaktifkan akses root dengan autentikasi password meningkatkan risiko terhadap serangan brute force.
Gunakanlah password yang sangat kuat (gabungan huruf besar, kecil, angka, dan simbol).
Sangat disarankan untuk segera mengganti password secara berkala atau beralih menggunakan SSH Key setelah akses root berhasil diaktifkan.

👤 Kontributor

 @syamsul18782

📝 Catatan
Skrip ini didesain khusus untuk keluarga sistem operasi Debian/Ubuntu. Penggunaan pada distribusi Linux lain mungkin memerlukan penyesuaian manual pada lokasi file konfigurasi SSH.
