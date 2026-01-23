#!/bin/bash
# UPDATE & UPGRADE
echo "Updating repositories..."
sleep 1
apt update -y && sudo apt upgrade -y

# MARIADB INSTALLATION
echo "Installing mariadb....."
sleep 1
# Menggunakan --fix-missing untuk mengatasi error 'Failed to fetch' dari mirror
apt install -y --fix-missing mariadb-server mariadb-client
apt --fix-broken install -y

echo "installing mariadb finish"

# SQL CONFIGURATION
DB_NAME="moodle"
DB_USER="moodleuser"
DB_PASS="12345"
# DB_HOST="%"
echo -n "Masukkan ip web server: "
read DB_HOST
echo
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

# FINISHING
systemctl restart mariadb
systemctl restart mysql 

# COUNTDOWN
for i in {5..1}
do
    echo "$i"
    sleep 1
done

# IMPORT MYSQL 50-SERVER CONFIG
rm /etc/mysql/mariadb.conf.d/50-server.cnf
mv db/50-server.cnf /etc/mysql/mariadb.conf.d/
echo "session terminated"
sleep 1
echo "THANK YOU FOR USING ALVIN'S PRODUCT"

# Membersihkan folder db/ (Pastikan script ini tidak sedang dijalankan di dalam folder tersebut)
rm -rf db
rm -rf "$0"








