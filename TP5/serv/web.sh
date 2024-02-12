#!/bin/bash

PROJECT_DIR="/var/serv"
NEW_USER="web"

echo "10.5.1.111 rp1.tp5.b2" | sudo tee -a /etc/hosts >/dev/null
echo "10.5.1.211 db1.tp5.b2" | sudo tee -a /etc/hosts >/dev/null

dnf install -y dnf-plugins-core
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io

systemctl start docker
systemctl enable docker

useradd -m $NEW_USER

usermod -aG docker $NEW_USER

tee /etc/systemd/system/serv.service > /dev/null <<EOF
[Unit]
Description=Serv Start Service
After=network.target

[Service]
User=$NEW_USER
Group=docker
WorkingDirectory=$PROJECT_DIR
Restart=on-failure
ExecStart=./compose.sh

[Install]
WantedBy=multi-user.target
EOF

tee >compose.sh /dev/null <<EOF
docker compose up -d
EOF

chown $NEW_USER:$NEW_USER ./compose.sh

systemctl daemon-reload
systemctl enable serv.service
systemctl start serv.service
