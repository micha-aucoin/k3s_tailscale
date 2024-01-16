#!/bin/bash

# Function to check if kubectl is installed
is_installed() {
    command -v kubectl >/dev/null 2>&1
}

# Uninstall kubectl if it is already installed
if is_installed; then
    echo "kubectl is already installed. Uninstalling..."
    rm -f /usr/local/bin/kubectl
fi

# Download and install the latest version of kubectl
echo "Installing kubectl..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"

# Download the kubectl checksum file
curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl.sha256"

# Validate the kubectl binary against the checksum file
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
if [ $? -ne 0 ]; then
    echo "Checksum validation failed."
    exit 1
fi
echo "Checksum validation passed."

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify kubectl version
kubectl version --client

# Remove the kubectl and kubectl.sha256 files from /home/vagrant
echo "Removing downloaded files..."
rm -f /home/vagrant/kubectl
rm -f /home/vagrant/kubectl.sha256

echo "Installation and cleanup complete."