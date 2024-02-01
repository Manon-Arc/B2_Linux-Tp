dnf update -y
firewall-cmd --add-port=22/tcp --permanent
firewall-cmd --reload
dnf install mariadb-server -y
systemctl start mariadb
systemctl enable mariadb
./db/init.sql > source /home/