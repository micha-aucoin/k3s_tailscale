#!/bin/bash

# Define the installation directory
INSTALL_DIR="/home/vagrant/miniconda3"

# Function to clean up Miniconda initialization from bashrc
cleanup_conda_init() {
    local BASHRC="/home/vagrant/.bashrc"
    # Define the start and end markers for the conda init block
    local START_MARKER="# >>> conda initialize >>>"
    local END_MARKER="# <<< conda initialize <<<"

    # Remove the conda initialization block from .bashrc
    if [ -f "$BASHRC" ]; then
        # Use awk to remove the block between start and end markers
        awk -v start="$START_MARKER" -v end="$END_MARKER" '
        !p && $0~start {p=1; next}
        p && $0~end {p=0; next}
        !p' "$BASHRC" > temp_bashrc && mv temp_bashrc "$BASHRC"
    fi
    # awk '!p' "$BASHRC" > temp_bashrc
    # ^ this will print the intire bashrc file, (when p is false, print the line). 'p' is a varialbe we havn't defined, so it is false by default.
    # awk automatically iterates through each line of a file so we will need to keep track of whether we are in the conda init block or not.
    # $0~start {p=1; next}, when the current line matches the START_MARKER we set p=1. b/c p=1, "awk '!p' "$BASHRC" > temp_bashrc" will not print the line.
    # $0~end {p=0; next}, when the current line matches the END_MARKER we set p=0. b/c p=0, "awk '!p' "$BASHRC" > temp_bashrc" will print the line.
}

# Check if Miniconda is already installed
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Miniconda is already installed. Uninstalling..."
    # Remove the existing Miniconda installation
    rm -rf $INSTALL_DIR

    # Clean up conda initialization from .bashrc
    cleanup_conda_init
fi

echo "Installing Miniconda..."

# Create the installation directory
mkdir -p $INSTALL_DIR

# Download the Miniconda installer
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $INSTALL_DIR/miniconda.sh
wget https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -O $INSTALL_DIR/miniconda.sh

# Install Miniconda
bash $INSTALL_DIR/miniconda.sh -b -u -p $INSTALL_DIR

# Remove the installer script
rm -rf $INSTALL_DIR/miniconda.sh

# Initialize Conda for bash shell
$INSTALL_DIR/bin/conda init bash
