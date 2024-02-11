#!/bin/bash

# Functionto check if k9s is installed and matches the desired version
is_correct_version_installed() {
    # Check if k9s is installed
    if ! command -v k9s &> /dev/null; then
        return 1
    fi

    # Check if the installed version of k9s matches the desired version
    local installed_version
    installed_version=$(k9s version | grep 'Version:' | awk '{print $2}')
    if [[ "$installed_version" == "v$K9S_VERSION" ]]; then
        return 0
    else
        return 1
    fi
}

# Install k9s if it's not installed or if the installed version doesn't match
if ! is_correct_version_installed; then
    echo "Installing k9s v$K9S_VERSION..."
    curl -fsSLO "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz"
    tar -xzvf k9s_Linux_x86_64.tar.gz --no-same-owner
    sudo mv k9s /usr/local/bin
    rm k9s_Linux_x86_64.tar.gz LICENSE README.md
else
    echo "k9s v$K9S_VERSION is already installed."
fi