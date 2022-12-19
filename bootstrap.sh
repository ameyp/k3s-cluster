#!/bin/bash

CLOUDFLARE_TOKEN_FILE="cloudflare-api-token.secret"

if [ ! -f $CLOUDFLARE_TOKEN_FILE ]; then
    echo "Please write the cloudflare API token to a file named $CLOUDFLARE_TOKEN_FILE." >2
    exit 1
fi

# Get the kubeconfig file
ssh-keygen -f "/home/amey/.ssh/known_hosts" -R "192.168.1.201" && ssh core@192.168.1.201 cat /etc/rancher/k3s/k3s.yaml | sed "s/127.0.0.1/192.168.1.201/" - > ~/.kube/config-test

# Create cert-manager namespace and secret
kubectl --kubeconfig ~/.kube/config-test create namespace cert-manager
kubectl --kubeconfig ~/.kube/config-test create secret generic cloudflare-api-token \
        -n cert-manager \
        --from-literal=apitoken=$(cat $CLOUDFLARE_TOKEN_FILE)

# Install argocd
kubectl --kubeconfig ~/.kube/config-test create namespace argocd
kubectl --kubeconfig ~/.kube/config-test apply -f https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/install.yaml -n argocd
kubectl --kubeconfig ~/.kube/config-test apply -f root/config-map.yaml
kubectl --kubeconfig ~/.kube/config-test apply -f root/project.yaml
kubectl --kubeconfig ~/.kube/config-test apply -f root/app.yaml
kubectl --kubeconfig ~/.kube/config-test apply -f root/self.yaml
