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
    echo 'source <(k3d completion bash)' >> $HOME/.bashrc

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


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
sudo k3d cluster list cluster-1
if [ $? -ne 0 ]; then
    # Create a cluster
    sudo k3d cluster create cluster-1 -p 443:443 -p 80:80

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}Kubectl installation | ${RESET}"
sudo kubectl version --client
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


echo -ne "${VERT}Kubectl alias and shortcut | ${RESET}"
cat $HOME/.bashrc | grep 'alias k="sudo kubectl"'
if [ $? -ne 0 ]; then
    echo '' >> $HOME/.bashrc
    echo 'source <(kubectl completion bash)' >> $HOME/.bashrc
    echo 'alias k="sudo kubectl"' >> $HOME/.bashrc
    echo 'complete -o default -F __start_kubectl k' >> $HOME/.bashrc
    source $HOME/.bashrc

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}argocd namespace creation | ${RESET}"
sudo kubectl get namespace argocd
if [ $? -ne 0 ]; then
    sudo kubectl create namespace argocd

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


echo -ne "${VERT}dev namespace creation | ${RESET}"
sudo kubectl get namespace dev
if [ $? -ne 0 ]; then
    sudo kubectl create namespace dev

    echo -e "${VERT}OK${RESET}"
else
    echo -e "${VERT}already exist${RESET}"
fi


# Argocd deployment
sudo kubectl apply -n argocd -f ./confs/argocd.yaml

# Ingress deployment
sudo kubectl apply -n argocd -f ./confs/ingress.yaml


#VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep tag_name | cut -d '"' -f 4)
#curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64"
#chmod +x argocd
#sudo mv argocd /usr/local/bin/

#######################################################

# NOTA BENE :

# Le Username par default est :
# admin

# Le password se trouve comme cela :
# sudo argocd admin initial-password -n argocd

# La connection a au serveur argocd :
# sudo argocd login localhost:443 --username admin --password PTb2j8jSU6UvcaeD --insecure

# La deconnection a au serveur argocd :
# sudo argocd logout localhost:443

# Deployer une app :
# sudo argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace dev
