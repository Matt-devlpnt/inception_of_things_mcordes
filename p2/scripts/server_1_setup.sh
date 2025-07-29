#!/bin/bash

set -e

sudo apt-get update
sudo apt-get install -y net-tools curl vim ufw jq

sudo ufw disable

mkdir /home/vagrant/inception_of_things

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode --node-ip=192.168.56.110 --token 12345" sh -s -

# add autocomplete permanently to your bash shell.
echo "source <(sudo kubectl completion bash)" >> /home/vagrant/.bashrc

echo "alias k='sudo kubectl'" >> /home/vagrant/.bashrc
echo "complete -o default -F __start_kubectl k" >> /home/vagrant/.bashrc

# Apps creation
sudo kubectl apply -f /vagrant/confs/app1.yaml
sudo kubectl apply -f /vagrant/confs/app2.yaml
sudo kubectl apply -f /vagrant/confs/app3.yaml

# Services creation
sudo kubectl expose deployment/app-one --type='ClusterIP' --port=80 --cluster-ip='10.43.171.213'
sudo kubectl expose deployment/app-two --type='ClusterIP' --port=80 --cluster-ip='10.43.193.160'
sudo kubectl expose deployment/app-three --type='ClusterIP' --port=80 --cluster-ip='10.43.229.156'

# Ingress creation
sudo kubectl create ingress apps --class=traefik --rule="app1.com/=app-one:80" --rule="app2.com/=app-two:80"
sudo kubectl create ingress apps-default --class=traefik --default-backend="app-three:80"

until pods=($(sudo kubectl get pods -n default -o custom-columns=NAME:.metadata.name --no-headers)) && [ ${#pods[@]} -ge 5 ]; do
    sleep 2
done

for pod in "${pods[@]}"; do
    until sudo kubectl exec "pods/$pod" -- bash /root/script.sh; do
        sleep 2
    done
done
