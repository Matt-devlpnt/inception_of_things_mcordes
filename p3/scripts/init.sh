#!/bin/bash


VERT='\033[38;5;82m'
ROUGE='\033[38;5;196m'
RESET='\033[0m'


sudo apt-get update &>/dev/null
sudo apt-get upgrade -y &>/dev/null


echo -ne "${VERT}K3d installation | ${RESET}"
k3d --version &>/dev/null
if [ $? -ne 0 ]; then
    # Install K3d
    sudo wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}cluster-1 creation | ${RESET}"
k3d cluster list cluster-1 &>/dev/null
if [ $? -ne 0 ]; then
    # Create a cluster
    k3d cluster create cluster-1 &>/dev/null

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}Kubectl installation | ${RESET}"
kubectl version --client &>/dev/null
if [ $? -ne 0 ]; then
    # Download the Kubectl latest release
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &>/dev/null

    # Install Kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm ./kubectl

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}Kubectl alias and shortcut | ${RESET}"
cat $HOME/.bashrc | grep 'alias k=kubectl' &>/dev/null
if [ $? -ne 0 ]; then
    echo 'source <(kubectl completion bash)' >> $HOME/.bashrc
    echo 'alias k=kubectl' >> $HOME/.bashrc
    echo 'complete -o default -F __start_kubectl k' >> $HOME/.bashrc
    source $HOME/.bashrc

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}microk8s installation | ${RESET}"
sudo microk8s version &>/dev/null
if [ $? -ne 0 ]; then
    sudo snap install microk8s --classic &>/dev/null
    sudo microk8s enable dns &>/dev/null
    sudo microk8s stop &>/dev/null
    sudo microk8s start &>/dev/null

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}argocd namespace creation | ${RESET}"
kubectl get namespace argocd &>/dev/null
if [ $? -ne 0 ]; then
    kubectl create namespace argocd &>/dev/null

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}dev namespace creation | ${RESET}"
kubectl get namespace dev &>/dev/null
if [ $? -ne 0 ]; then
    kubectl create namespace dev &>/dev/null

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}argocd deployment | ${RESET}"
kubectl get pods -n argocd &>/dev/null
if [ $? -ne 0 ]; then
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml &>/dev/null

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi



#kubectl get secrets argocd-secret -n argocd -o=jsonpath='{.data.tls\.crt}' | base64 --decode > ./argocd-tls.crt
#sudo cp ./argocd-tls.crt /usr/local/share/ca-certificates/
#sudo update-ca-certificates
#rm ./argocd-tls.crt

#VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep tag_name | cut -d '"' -f 4)
#curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64"
#chmod +x argocd
#sudo mv argocd /usr/local/bin/

#NOTA BENE :
#Le Username par default est :      admin
#Le password se trouve comme cela : kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
