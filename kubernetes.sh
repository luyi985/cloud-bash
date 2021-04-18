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

function clusterSingle() {
    swapoff -a

    # https://www.redpill-linpro.com/techblog/2019/04/04/kubernetes-setup.html

    # The --pod-network-cidr setting is required by Flannel, which I chose to use for pod networking.
    kubeadm init --pod-network-cidr=10.244.0.0/16

    # There is still a bunch of work to do to make the cluster actually useful. 
    # You can do most of the rest of this as a non-root user. 
    # Follow the instructions kubeadm gave you to copy the credential as your regular user.

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    source <(kubectl completion bash)

    # Install Flannel for pod networking
    # https://github.com/flannel-io/flannel/blob/master/Documentation/kube-flannel.yml
    kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
    kubectl get pods --all-namespaces

    # Untaint the master so you can run pods
    # At this point you can run pods and expose them with services. If that’s all you need, you’re done
    kubectl taint nodes --all node-role.kubernetes.io/master-

    # Set up nginx-ingress
    # https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.45.0/deploy/static/provider/baremetal/deploy.yaml
cat > nginx-host-networking.yaml << EOF
spec:
  template:
    spec:
      hostNetwork: true
EOF
    kubectl -n ingress-nginx patch deployment ingress-nginx-controller --patch="$(<nginx-host-networking.yaml)"

    # dashboard
    # https://github.com/kubernetes/dashboard
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
}