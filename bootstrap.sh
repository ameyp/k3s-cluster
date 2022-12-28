#!/bin/bash

CLOUDFLARE_TOKEN_FILE="cloudflare-api-token.secret"
export CLUSTER=${CLUSTER:-test}
KUBECONFIG="$HOME/.kube/config-$CLUSTER"

if [ ! -f $CLOUDFLARE_TOKEN_FILE ]; then
    echo "Please write the cloudflare API token to a file named $CLOUDFLARE_TOKEN_FILE." >2
    exit 1
fi

# Get the kubeconfig file
ssh-keygen -f "/home/amey/.ssh/known_hosts" -R "192.168.1.201" && ssh core@192.168.1.201 cat /etc/rancher/k3s/k3s.yaml | sed "s/127.0.0.1/192.168.1.201/" - > $KUBECONFIG

# Create cert-manager namespace and secret
kubectl --kubeconfig $KUBECONFIG create namespace cert-manager
kubectl --kubeconfig $KUBECONFIG create namespace vault
kubectl --kubeconfig $KUBECONFIG create secret generic cloudflare-api-token \
        -n cert-manager \
        --from-literal=apitoken=$(cat $CLOUDFLARE_TOKEN_FILE)

# Bootstrap fluxcd
kubectl --kubeconfig $KUBECONFIG apply -f https://github.com/fluxcd/flux2/releases/latest/download/install.yaml
cat fluxcd/bootstrap/root.yaml | envsubst | kubectl --kubeconfig $KUBECONFIG apply -f -
