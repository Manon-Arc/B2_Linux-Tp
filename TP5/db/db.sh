#!/bin/bash

echo "10.5.1.111 rp1.tp5.b2" | sudo tee -a /etc/hosts >/dev/null
echo "10.5.1.11 web1.tp5.b2" | sudo tee -a /etc/hosts >/dev/null

sudo dnf install mariadb-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb

sudo sed -i 's/bind-address.*/bind-address = 127.0.0.1/' /etc/my.cnf.d/mariadb-server.cnf
sudo systemctl restart mariadb
sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS app_nulle;"
sudo mysql -u root -e "CREATE USER IF NOT EXISTS 'SQL'@'web1.tp5.b2' IDENTIFIED BY 'azerty';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON app_nulle.* TO 'SQL'@'web1.tp5.b2';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
sudo mysql -u root app_nulle < "./init.sql"

sudo firewall-cmd --add-port=3306/tcp --permanent
