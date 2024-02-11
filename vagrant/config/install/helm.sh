#!/bin/bash

# Function to check if Helm is installed and matches the desired version
is_correct_version_installed() {
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        return 1
    fi

    # Check if the installed version of helm matches the desired version
    local installed_version
    installed_version=$(helm version --short | cut -d "+" -f1 | sed 's/Version://g')
    if [[ "$installed_version" == "v$HELM_VERSION" ]]; then
        return 0
    else
        return 1
    fi
}

# Install Helm if it's not installed or if the installed version doesn't match
if ! is_correct_version_installed; then
    echo "Installing Helm v$HELM_VERSION..."
    curl -sSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar zx
    sudo mv linux-amd64/helm /usr/local/bin/helm
    rm -rf linux-amd64
else
    echo "Helm v$HELM_VERSION is already installed."
fi
