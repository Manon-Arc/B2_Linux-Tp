#!/bin/bash

PROJECT_DIR="/var/serv"
NEW_USER="web"

sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io

sudo systemctl start docker
sudo systemctl enable docker

sudo useradd -m $NEW_USER

sudo usermod -aG docker $NEW_USER

sudo tee /etc/systemd/system/serv.service > /dev/null <<EOF
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

sudo tee >compose.sh /dev/null <<EOF
docker compose up -d
EOF

chown $NEW_USER:$NEW_USER ./compose.sh

sudo systemctl daemon-reload
sudo systemctl enable serv.service
sudo systemctl start serv.service
