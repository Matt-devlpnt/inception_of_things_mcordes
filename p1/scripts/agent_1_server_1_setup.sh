#!/bin/bash
set -e

sudo apt-get update
sudo apt-get install -y net-tools curl vim ufw

sudo ufw disable

echo "Attente du serveur K3s..."
until curl -k https://192.168.56.110:6443; do
  sleep 5
done

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111 --server https://192.168.56.110:6443 --token 12345" sh -s -
