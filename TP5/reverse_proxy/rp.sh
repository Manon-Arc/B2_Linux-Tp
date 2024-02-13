#!/bin/bash

echo "10.5.1.11 web1.tp5.b2" | sudo tee -a /etc/hosts >/dev/null
echo "10.5.1.211 db1.tp5.b2" | sudo tee -a /etc/hosts >/dev/null

cp app_nulle.conf /etc/nginx/conf.d/app_nulle.conf

sudo dnf install nginx 
sudo systemctl enable nginx
sudo systemctl start nginx
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload