#!/bin/bash -eux

echo "==> waiting for cloud-init to finish"
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo 'Waiting for Cloud-Init...'
    sleep 1
done

echo "==> updating apt cache"
sudo apt-get update -qq

echo "==> upgrade apt packages"
sudo apt-get upgrade -y -qq

echo "==> installing qemu-guest-agent"
sudo apt-get install -y -qq qemu-guest-agent

# Actualizar los paquetes e instalar herramientas necesarias
sudo apt update
sudo apt install -y git nano curl wget make sudo rsync jq

# Instalar yq
sudo wget https://github.com/mikefarah/yq/releases/download/v4.34.2/yq_linux_amd64 -O /usr/bin/yq
sudo chmod +x /usr/bin/yq

# Instalar Docker
curl -fsSL https://get.docker.com | sh

# Configurar Docker para el usuario actual
sudo groupadd docker || true
sudo usermod -aG docker $USER

# Instalar Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Instalar Golang
wget https://go.dev/dl/go1.21.10.linux-amd64.tar.gz
rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.10.linux-amd64.tar.gz
# Configurar PATH globalmente
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go.sh
sudo chmod +x /etc/profile.d/go.sh

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client  # Verificar instalación

# Activar br_netfilter
echo 'br_netfilter' | sudo tee /etc/modules-load.d/containerd.conf
sudo modprobe br_netfilter

# Ajustar ulimit para el usuario
sudo sysctl -w fs.file-max=104000
ulimit -n 104000
