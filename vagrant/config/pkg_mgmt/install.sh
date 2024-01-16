#!/bin/bash

# Function to check if a package is installed
is_installed() {
    dpkg -l "$1" &> /dev/null
}

# Update package lists
apt-get update

# List of packages to be installed
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

# Install packages only if they are not already installed
for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg"; then
        echo "Installing $pkg..."
        apt-get install -y --no-install-recommends "$pkg"
    else
        echo "$pkg is already installed."
    fi
done