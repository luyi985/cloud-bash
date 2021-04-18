#!/bin/bash

function install () {
    # Letting iptables see bridged traffic 
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

    sudo sysctl --system

    # Installing kubeadm, kubelet and kubectl
    # You will install these packages on all of your machines:

    # kubeadm: the command to bootstrap the cluster.

    # kubelet: the component that runs on all of the machines in your cluster and does things like starting pods and containers.

    # kubectl: the command line util to talk to your cluster.

    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl
    # Download the Google Cloud public signing key:
    echo "Download the Google Cloud public signing key:"
    sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    # Add the Kubernetes apt repository:
    echo "Add the Kubernetes apt repository:"
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
}

function uninstall () {
    kubeadm reset
    sudo apt-mark unhold kubeadm kubectl kubelet
    sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube*   
    sudo apt-get autoremove  
    sudo rm -rf ~/.kube
}