#!/bin/bash

set -euo pipefail

echo "Checking required tools..."

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "$1 is installed."
    else
        echo "ERROR: $1 is not installed."
        exit 1
    fi
}

check_command terraform
check_command ansible
check_command ansible-playbook
check_command nmap
check_command ssh

SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/minecraft-key.pem}"

if [ -f "$SSH_KEY_PATH" ]; then
    echo "SSH key found at $SSH_KEY_PATH"
else
    echo "ERROR: SSH key not found at $SSH_KEY_PATH"
    echo "Set SSH_KEY_PATH or copy your key to ~/.ssh/minecraft-key.pem"
    exit 1
fi

echo "Setup check complete."