#!/bin/bash

##################### Vagrant installation #########################
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant

##################### VirtualBox installation ######################
sudo apt-get update
sudo apt-get install -y wget gnupg2 lsb-release

wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | \
sudo gpg --dearmor -o /usr/share/keyrings/oracle-virtualbox.gpg

echo "deb [signed-by=/usr/share/keyrings/oracle-virtualbox.gpg] \
https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | \
sudo tee /etc/apt/sources.list.d/virtualbox.list

sudo apt-get update

sudo apt-get install -y virtualbox-7.0

##################### Vagrant launch ################################
vagrant up
