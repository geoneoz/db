#!/bin/bash

apt update

# MARIADB
echo "Installinh mariadb....."
apt install mariadb-{server,client} -y
rm -f /etc/mysql/mariadb.conf.d/50-server.cnf
mv db/50-server.cnf /etc/mysql/mariadb.conf.d/
echo "installing mariadb finish"

# SQL 
# Konfigurasi Variabel
DB_NAME="moodle"
DB_USER="moodleuser"
DB_PASS="12345"
DB_HOST="%"

# Meminta input password root MySQL agar aman
echo -n "Masukkan password root MySQL: "
read -s ROOT_PASS
echo

# Menjalankan perintah MySQL
mysql -u root -p"$ROOT_PASS" <<EOF
-- 1. Buat database moodle
CREATE DATABASE IF NOT EXISTS $DB_NAME;

-- 2. Buat user dan password
CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';

-- 3. Memberikan akses penuh ke database moodle
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';

-- 4. Flush privileges
FLUSH PRIVILEGES;

-- 5. Keluar otomatis (implicit by EOF)
EOF

if [ $? -eq 0 ]; then
    echo "------------------------------------------"
    echo "Konfigurasi Database Moodle Berhasil!"
    echo "Database: $DB_NAME"
    echo "User    : $DB_USER"
    echo "Host    : $DB_HOST"
    echo "------------------------------------------"
else
    echo "Terjadi kesalahan saat mengonfigurasi database."
fi

# REWRITE BINDING IP
# Path ke file konfigurasi MariaDB
FILE_PATH="/etc/mysql/mariadb.conf.d/50-server.cnf"

# 1. Mengecek apakah file tersebut ada
if [ -f "$FILE_PATH" ]; then
    echo "Mengubah bind-address di $FILE_PATH..."

    # 2. Menggunakan sed untuk mencari baris bind-address dan menggantinya
    # 's' artinya substitute (ganti)
    sudo sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' "$FILE_PATH"

    # 3. Verifikasi apakah perubahan berhasil
    CHECK=$(grep "bind-address = 0.0.0.0" "$FILE_PATH")
    
    if [ ! -z "$CHECK" ]; then
        echo "Berhasil: bind-address telah diubah menjadi 0.0.0.0"
        
        # 4. Restart layanan MariaDB agar konfigurasi baru aktif
        echo "Me-restart MariaDB..."
        sudo systemctl restart mariadb
        echo "Selesai."
    else
        echo "Gagal: Teks tidak ditemukan atau tidak dapat diubah."
    fi
else
    echo "Error: File $FILE_PATH tidak ditemukan."
fi

# FINISHING
systemctl restart mysqld
systemctl restart mysql 
echo "5"
sleep 1
echo "4"
sleep 1
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
echo "session terminated"
sleep 1
echo "THANK YOU FOR USING ALVIN'S PROUCT"
rm -rf db/