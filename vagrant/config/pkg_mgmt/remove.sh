#!/bin/bash

# Function to check if a package is installed
is_installed() {
    dpkg -l "$1" &> /dev/null
}

# List of packages to be uninstalled
packages=(
    curl
    unzip
    openssh-server
    bash-completion
    git
    ca-certificates
    fzf
    jq
)

# Uninstall packages only if they are installed
for pkg in "${packages[@]}"; do
    if is_installed "$pkg"; then
        echo "Uninstalling $pkg..."
        apt-get remove --purge -y "$pkg"
    else
        echo "$pkg is not installed."
    fi
done

# Optional: Autoremove to remove any unused dependencies
apt-get autoremove -y

# Optional: Clean up the local repository of retrieved package files
apt-get clean
