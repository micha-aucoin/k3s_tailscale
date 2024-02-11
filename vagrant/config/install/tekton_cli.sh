#!/bin/bash

# Function to check if Tekton CLI is installed and matches the desired version
is_correct_version_installed() {
    # Check if Tekton CLI is installed
    if ! command -v tkn &> /dev/null; then
        return 1
    fi

    # Check if the installed version of Tekton CLI matches the desired version
    local installed_version
    installed_version=$(tkn version | grep 'Client version' | cut -d ' ' -f 3)
    if [[ "$installed_version" == "$TEKTON_CLI_VERSION" ]]; then
        return 0
    else
        return 1
    fi
}

# Install Tekton CLI if it's not installed or if the installed version doesn't match
if ! is_correct_version_installed; then
    echo "Installing Tekton CLI v$TEKTON_CLI_VERSION..."
    curl -fsSLO "https://github.com/tektoncd/cli/releases/download/v${TEKTON_CLI_VERSION}/tkn_${TEKTON_CLI_VERSION}_Linux_x86_64.tar.gz"
    tar xvzf tkn_${TEKTON_CLI_VERSION}_Linux_x86_64.tar.gz --no-same-owner
    sudo mv tkn /usr/local/bin
    rm tkn_${TEKTON_CLI_VERSION}_Linux_x86_64.tar.gz
else
    echo "Tekton CLI v$TEKTON_CLI_VERSION is already installed."
fi

# Remove the LICENSE and README.md files from /home/vagrant
echo "Removing downloaded files..."
rm -f /home/vagrant/LICENSE
rm -f /home/vagrant/README.md

echo "Installation and cleanup complete."