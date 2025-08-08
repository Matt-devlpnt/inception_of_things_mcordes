#!/bin/bash


VERT='\033[38;5;82m'
ROUGE='\033[38;5;196m'
RESET='\033[0m'


sudo apt-get update
sudo apt-get upgrade -y


echo -ne "${VERT}K3d installation | ${RESET}"
k3d --version
if [ $? -ne 0 ]; then
    # Install K3d
    sudo wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -e "${VERT}K3d autocompletion${RESET}"
grep 'source <(k3d completion bash)' $HOME/.bashrc || echo '' >> $HOME/.bashrc
grep 'source <(k3d completion bash)' $HOME/.bashrc || echo 'source <(k3d completion bash)' >> $HOME/.bashrc
source $HOME/.bashrc


# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# docker installation
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


echo -ne "${VERT}cluster-1 creation | ${RESET}"
k3d cluster list cluster-1
if [ $? -ne 0 ]; then
    # Create a cluster
    k3d cluster create cluster-1 -p 443:443 -p 80:80
    rm -rf $HOME/.kube
    mkdir $HOME/.kube
    k3d kubeconfig get cluster-1 > $HOME/.kube/config

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}Kubectl installation | ${RESET}"
kubectl version --client
if [ $? -ne 0 ]; then
    # Download the Kubectl latest release
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

    # Install Kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm ./kubectl

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -e "${VERT}Kubectl autocompletion, alias and shortcut${RESET}"
grep 'source <(kubectl completion bash)' $HOME/.bashrc || echo '' >> $HOME/.bashrc
grep 'source <(kubectl completion bash)' $HOME/.bashrc || echo 'source <(kubectl completion bash)' >> $HOME/.bashrc
grep 'alias k="kubectl"' $HOME/.bashrc || echo 'alias k="kubectl"' >> $HOME/.bashrc
grep 'complete -o default -F __start_kubectl k' $HOME/.bashrc || echo 'complete -o default -F __start_kubectl k' >> $HOME/.bashrc
source $HOME/.bashrc


echo -e "${VERT}Argocd autocompletion${RESET}"
grep 'source <(argocd completion bash)' $HOME/.bashrc || echo '' >> $HOME/.bashrc
grep 'source <(argocd completion bash)' $HOME/.bashrc || echo 'source <(argocd completion bash)' >> $HOME/.bashrc
source $HOME/.bashrc


echo -ne "${VERT}argocd namespace creation | ${RESET}"
kubectl get namespace argocd
if [ $? -ne 0 ]; then
    kubectl create namespace argocd

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}dev namespace creation | ${RESET}"
kubectl get namespace dev
if [ $? -ne 0 ]; then
    kubectl create namespace dev

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


# Argocd deployment
kubectl apply -n argocd -f ./confs/argocd.yaml

# Ingress deployment
kubectl apply -n argocd -f ./confs/ingress.yaml


# Argocd connection
until argocd login localhost:443 --username admin --password "$(kubectl --insecure-skip-tls-verify -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)" --insecure --grpc-web; do
	sleep 2
done

# App deployment
argocd app create app --repo https://github.com/Matt-devlpnt/inception_of_things_mcordes.git --path p3/confs/app --dest-server https://kubernetes.default.svc --dest-namespace dev --grpc-web

# Synchronise app
argocd app sync app



#VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep tag_name | cut -d '"' -f 4)
#curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64"
#chmod +x argocd
#sudo mv argocd /usr/local/bin/

#######################################################

# NOTA BENE :

# Le Username par default est :
# admin

# Le password se trouve comme cela :
# kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
