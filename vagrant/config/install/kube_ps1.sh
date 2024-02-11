#!/bin/bash

# Check if kube-ps1 is already installed and at the correct version
if [ -f /usr/local/bin/kube-ps1 ]; then
    installed_version=$(grep 'KUBE_PS1_VERSION' /usr/local/bin/kube-ps1 | cut -d '"' -f 2)
    if [ "$installed_version" == "$KUBE_PS1_VERSION" ]; then
        echo "kube-ps1 version $KUBE_PS1_VERSION is already installed."
        exit 0
    fi
fi

# Install kube-ps1
echo "Installing kube-ps1 version $KUBE_PS1_VERSION..."
curl -fsSLO "https://github.com/jonmosco/kube-ps1/archive/v${KUBE_PS1_VERSION}.tar.gz"
tar -xzvf v${KUBE_PS1_VERSION}.tar.gz --no-same-owner
mv kube-ps1-${KUBE_PS1_VERSION}/kube-ps1.sh /usr/local/bin/kube-ps1
chmod +x /usr/local/bin/kube-ps1
chown vagrant:vagrant /usr/local/bin/kube-ps1

# Append the version information to the kube-ps1 script
echo "KUBE_PS1_VERSION=\"$KUBE_PS1_VERSION\"" >> /usr/local/bin/kube-ps1

rm -rf kube-ps1-${KUBE_PS1_VERSION} v${KUBE_PS1_VERSION}.tar.gz
