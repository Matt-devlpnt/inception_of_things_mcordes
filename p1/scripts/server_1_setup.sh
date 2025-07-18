#!/bin/bash
set -e

sudo apt-get update
sudo apt-get install -y net-tools curl vim ufw

sudo ufw disable

echo "alias k='sudo kubectl'" >> /home/vagrant/.bashrc
source /home/vagrant/.bashrc

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --token 12345" sh -s -
