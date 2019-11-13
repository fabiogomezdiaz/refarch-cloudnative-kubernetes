#!/bin/bash

# Install socat, which is needed for port-forwarding
sudo apt-get update
sudo apt-get install socat

# Download kubectl, which is a requirement for using minikube.
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Download minikube.
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.35.0/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube
# Start Minikube
sudo minikube start --vm-driver=none --kubernetes-version=v1.13.0
# Update minikube directory permissions
sudo chown -R travis: /home/travis/.minikube/
# Fix the kubectl context, as it's often stale.
minikube update-context
# Getting ip for testing
minikube ip
# Wait for Minikube to be up and ready.
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl get nodes -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1; done

# Download helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh && chmod 700 get_helm.sh && ./get_helm.sh && rm get_helm.sh

# Add stable, incubator and bluecompute-charts Helm repos
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm repo add ibmcase https://raw.githubusercontent.com/fabiogomezdiaz/refarch-cloudnative-kubernetes/master/charts

# Get cluster info
kubectl cluster-info