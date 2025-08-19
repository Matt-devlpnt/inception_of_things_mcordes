#!/bin/bash


##############################  Variables ################################
GREEN='\033[38;5;82m'
RED='\033[38;5;196m'
RESET='\033[0m'


##############################  Functions ################################

# This function must take three arguments:
# First argument: there is two values "nnl" (no newline) or "nl" (newline)
# Second argument: this the color of message | there two values "r" (red) or "g" (green)
# Third argument: this is the message itself

print_message() {
    if [ $1 = "nnl" ]; then
        if [ $2 = "g" ]; then
            echo -ne "${GREEN}${3}${RESET}"
        else
            echo -ne "${RED}${3}${RESET}"
        fi
    else
        if [ $2 = "g" ]; then
            echo -e "${GREEN}${3}${RESET}"
        else
            echo -e "${RED}${3}${RESET}"
        fi
    fi
}


# This function must take two arguments:
# - First argument: the return value $? of the function used before using the response_status function
# - Second argument: the error message associated with the command

response_status() {
    if [ ${1} -eq 0 ]; then
        print_message "nl" "g" "OK"
        return 0
    else
        print_message "nl" "r" "KO"
        print_message "nl" "r" ${2}
        exit 1
    fi
}


# This function is an installation utils checker and take two arguments:
# - First argument: the return value $? of the function used before using the response_status function
# - Second argument: this argument is a util install command

installation_utils_checker() {
    if [ $1 -ne 0 ]; then
        bash $2 >> ./script.log 2>&1
        print_message "nl" "g" "OK"
    else
        print_message "nl" "g" "Already exist"
    fi
}


##########################################################################
sudo apt-get update >> ./script.log 2>&1
sudo apt-get upgrade -y >> ./script.log 2>&1
sudo apt-get install -y ca-certificates curl >> ./script.log 2>&1


##############################  K3d installation #########################
print_message "nnl" "g" "K3d installation | "
k3d --version >> ./script.log 2>&1
installation_utils_checker $? "sudo wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash"


##############################  Docker installation ######################
print_message "nnl" "g" "Docker installation | "
# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings >> ./script.log 2>&1
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc >> ./script.log 2>&1
sudo chmod a+r /etc/apt/keyrings/docker.asc >> ./script.log 2>&1

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update >> ./script.log 2>&1

# docker installation
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> ./script.log 2>&1

print_message "nl" "g" "OK"


##############################  Cluster creation #########################
print_message "nnl" "g" "cluster-1 creation | "
k3d cluster create cluster-1 -p 443:443 -p 8888:80 >> ./script.log 2>&1
rm -rf $HOME/.kube >> ./script.log 2>&1
mkdir $HOME/.kube >> ./script.log 2>&1
k3d kubeconfig get cluster-1 > $HOME/.kube/config

print_message "nl" "g" "OK"


##############################  Kubectl installation #####################
print_message "nnl" "g" "Kubectl installation | "
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" >> ./script.log 2>&1
kubectl version --client >> ./script.log 2>&1
installation_utils_checker $? "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl"
rm ./kubectl >> ./script.log 2>&1


##############################  Git alias creation #######################
print_message "nl" "g" "Git alias creation"
grep 'alias g="git"' $HOME/.bashrc >> ./script.log 2>&1 || echo 'alias g="git"' >> $HOME/.bashrc
git config --local alias.up '!f() { if [ -z "$1" ] || [ -z "$1" ]; then echo "Error: message and tag name required"; else git add . && git commit -m "$1" && git push; fi; }; f'
source $HOME/.bashrc


##############################  K3d autocompletion creation ##############
print_message "nl" "g" "K3d autocompletion"
grep 'source <(k3d completion bash)' $HOME/.bashrc >> ./script.log 2>&1 || echo '' >> $HOME/.bashrc
grep 'source <(k3d completion bash)' $HOME/.bashrc >> ./script.log 2>&1 || echo 'source <(k3d completion bash)' >> $HOME/.bashrc
source $HOME/.bashrc


##############################  Kubbeclt alias and autocompletion creation
print_message "nl" "g" "Kubectl autocompletion, alias and shortcut"
grep 'source <(kubectl completion bash)' $HOME/.bashrc >> ./script.log 2>&1 || echo '' >> $HOME/.bashrc
grep 'source <(kubectl completion bash)' $HOME/.bashrc >> ./script.log 2>&1 || echo 'source <(kubectl completion bash)' >> $HOME/.bashrc
grep 'alias k="kubectl"' $HOME/.bashrc >> ./script.log 2>&1 || echo 'alias k="kubectl"' >> $HOME/.bashrc
grep 'complete -o default -F __start_kubectl k' $HOME/.bashrc >> ./script.log 2>&1 || echo 'complete -o default -F __start_kubectl k' >> $HOME/.bashrc
source $HOME/.bashrc


##############################  Argocd autocompletion creation ###########
print_message "nl" "g" "Argocd autocompletion"
grep 'source <(argocd completion bash)' $HOME/.bashrc >> ./script.log 2>&1 || echo '' >> $HOME/.bashrc
grep 'source <(argocd completion bash)' $HOME/.bashrc >> ./script.log 2>&1 || echo 'source <(argocd completion bash)' >> $HOME/.bashrc
source $HOME/.bashrc


############################## Argocd namespace creation #################
print_message "nnl" "g" "argocd namespace creation | "
kubectl create namespace argocd >> ./script.log 2>&1

response_status $? "There is an argocd namespace creation problem"


############################## Dev namespace creation ####################
print_message "nnl" "g" "dev namespace creation | "
kubectl create namespace dev >> ./script.log 2>&1

response_status $? "There is an dev namespace creation problem"


############################## Argocd installation #######################
print_message "nnl" "g" "Argocd installation | "
kubectl apply -n argocd -f ./confs/argocd.yaml >> ./script.log 2>&1

response_status $? "There is an argocd installation problem"


############################## Argocd ingress creation ###################
print_message "nnl" "g" "Argocd ingress creation | "
kubectl apply -n argocd -f ./confs/ingress_argocd.yaml >> ./script.log 2>&1

response_status $? "There is an argocd ingress creation problem"


############################## Dev ingress creation ######################
print_message "nnl" "g" "Dev ingress creation | "
kubectl apply -n dev -f ./confs/ingress_dev.yaml >> ./script.log 2>&1

response_status $? "There is a dev ingress creation problem"


############################## Project creation ##########################
print_message "nnl" "g" "Development project creation | "
kubectl apply -n argocd -f ./confs/project.yaml >> ./script.log 2>&1

response_status $? "There is a development project creation problem"


############################## Argocd extraction key #####################
print_message "nnl" "g" "Argocd extraction key | "
until kubectl --insecure-skip-tls-verify -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' >> ./script.log 2>&1; do
	sleep 2
done

response_status $? "There is an extraction key problem"


############################## Argocd connection #########################
print_message "nnl" "g" "Argocd connection | "
KEY=$(kubectl --insecure-skip-tls-verify -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
until argocd login argocd.admin.com:443 --skip-test-tls --username admin --password ${KEY} --insecure --grpc-web >> ./script.log 2>&1; do
	sleep 2
done

response_status $? "There is an argocd login problem"


############################## Helm install ####################
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

############################## Gitlab namespace creation ####################
print_message "nnl" "g" "Gitlab namespace creation | "
kubectl create namespace gitlab >> ./script.log 2>&1
response_status $? "There is a Gitlab namespace creation problem"


############################## Gitlab installation #######################
print_message "nnl" "g" "Gitlab installation | "
helm repo add gitlab https://charts.gitlab.io/ >> ./script.log 2>&1
helm repo update >> ./script.log 2>&1

helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --timeout 900s \
  --set global.hosts.domain=local \
  --set global.hosts.https=true \
  --set global.ingress.enabled=false \
  --set nginx-ingress.enabled=false \
  --set gitlab-runner.install=false \
  --set certmanager-issuer.email="vicalvez@student.42nice.fr" >> ./script.log 2>&1

response_status $? "There is a gitlab installation problem"


############################## Gitlab ingress creation ###################
print_message "nnl" "g" "Gitlab ingress creation | "
kubectl apply -n gitlab -f ./confs/ingress_gitlab.yaml >> ./script.log 2>&1
response_status $? "There is an gitlab ingress creation problem"



# http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/<user>/<project>.git