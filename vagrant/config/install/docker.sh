#!/bin/bash
# Check if Docker is installed and install it if not
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "Docker is already installed."
fi

# Add the 'vagrant' user to the 'docker' group if not already added
if ! groups vagrant | grep &>/dev/null '\\bdocker\\b'; then
    echo "Adding 'vagrant' user to 'docker' group..."
    usermod -a -G docker vagrant
else
    echo "'vagrant' user is already in the 'docker' group."
fi

# Install Docker bash completion if it's not already installed
if [ ! -f /etc/bash_completion.d/docker.sh ]; then
    echo "Installing Docker bash completion..."
    sudo curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh
    sudo chmod +x /etc/bash_completion.d/docker.sh
else
    echo "Docker bash completion is already installed."
fi