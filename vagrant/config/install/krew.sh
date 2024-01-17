#!/bin/bash

# Define Krew root and add to PATH
export KREW_ROOT="/home/vagrant/.krew"

# Function to check if krew is installed
is_krew_installed() {
    command -v kubectl-krew >/dev/null 2>&1
}

# Function to install krew
install_krew() {
    cd "$(mktemp -d)"
    OS="$(uname | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
    KREW="krew-${OS}_${ARCH}"
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
    tar zxvf "${KREW}.tar.gz"
    ./"${KREW}" install krew
}

# Install Krew if not installed
if ! is_krew_installed; then
    echo "Installing Krew..."
    install_krew
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> /home/vagrant/.bashrc
    source home/vagrant/.bashrc
else
    echo "Krew is already installed."
fi

# Function to check if a krew plugin is installed
is_plugin_installed() {
    kubectl krew list | grep -qw "$1"
}

# Function to install a krew plugin
install_plugin() {
    if ! is_plugin_installed "$1"; then
        echo "Installing krew plugin: $1"
        kubectl krew install "$1"
    else
        echo "Krew plugin $1 is already installed."
    fi
}

# Install Krew plugins
for plugin in $KREW_PLUGINS; do
    install_plugin "$plugin"
done

# change ownership of .krew to vagrant user
sudo chown -R vagrant:vagrant "${HOME}/.krew"

echo "Krew and plugins installation complete."