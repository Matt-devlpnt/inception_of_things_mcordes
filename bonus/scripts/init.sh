#!/bin/bash
set -e

# k3d
if ! command -v k3d &> /dev/null; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# kubectl
if ! command -v kubectl &> /dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
fi

# Helm
if ! command -v helm &> /dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# ArgoCD CLI
if ! command -v argocd &> /dev/null; then
  curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
  chmod +x argocd
  sudo mv argocd /usr/local/bin/
fi

echo "Init successfully finished"

# k3d cluster
k3d cluster create bonus-cluster \
  --servers 1 \
  --agents 2 \
  -p "8080:80@loadbalancer"



# argo cd deployment
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d


# gitlab
kubectl create namespace gitlab

helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --timeout 600s \
  --set global.hosts.domain=localhost \
  --set global.hosts.externalIP=127.0.0.1 \
  --set gitlab-runner.install=false \
  --set certmanager-issuer.email="vicalvez@student.42nice.fr"

# start OK, connexion web KO

#  kubectl -n gitlab port-forward svc/gitlab-webservice-default 18080:8080

# /etc/hosts => 127.0.0.1 gitlab.localhost
# https://gitlab.localhost:18080
