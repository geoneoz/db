#!/bin/bash

# --- PRE-FIX: Menghapus karakter hantu Windows (\r) jika ada ---
# Baris ini memastikan script berjalan lancar di Linux meskipun diedit di Windows
sed -i 's/\r$//' "$0"

# UPDATE & UPGRADE
echo "Updating repositories..."
apt update -y && sudo apt upgrade -y

# MARIADB INSTALLATION
echo "Installing mariadb....."
# Menggunakan --fix-missing untuk mengatasi error 'Failed to fetch' dari mirror
apt install -y --fix-missing mariadb-server mariadb-client
apt --fix-broken install -y

echo "installing mariadb finish"

# SQL CONFIGURATION
DB_NAME="moodle"
DB_USER="moodleuser"
DB_PASS="12345"
DB_HOST="%"

# Meminta input password root MySQL agar aman
echo -n "Masukkan password root MySQL: "
read -s ROOT_PASS
echo

# Menjalankan perintah MySQL menggunakan Here-Doc
mysql -u root -p"$ROOT_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';
FLUSH PRIVILEGES;
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
FILE_PATH="/etc/mysql/mariadb.conf.d/50-server.cnf"

if [ -f "$FILE_PATH" ]; then
    echo "Mengubah bind-address di $FILE_PATH..."
    # Menggunakan regex yang lebih fleksibel untuk menangkap variasi spasi
    sudo sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' "$FILE_PATH"

    CHECK=$(grep "bind-address = 0.0.0.0" "$FILE_PATH")
    
    if [ ! -z "$CHECK" ]; then
        echo "Berhasil: bind-address telah diubah menjadi 0.0.0.0"
        echo "Me-restart MariaDB..."
        sudo systemctl restart mariadb
    else
        echo "Gagal: Baris bind-address tidak ditemukan di file."
    fi
else
    echo "Error: File $FILE_PATH tidak ditemukan."
fi

# FINISHING
systemctl restart mariadb
systemctl restart mysql 

# COUNTDOWN
for i in {5..1}
do
    echo "$i"
    sleep 1
done

echo "session terminated"
sleep 1
echo "THANK YOU FOR USING ALVIN'S PRODUCT"

# Membersihkan folder db/ (Pastikan script ini tidak sedang dijalankan di dalam folder tersebut)
# sudo rm -rf db/



