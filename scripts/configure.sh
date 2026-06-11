#!/bin/bash

set -euo pipefail

SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/minecraft-key.pem}"

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "ERROR: SSH key not found at $SSH_KEY_PATH"
    echo "Set SSH_KEY_PATH or copy your key to ~/.ssh/minecraft-key.pem"
    exit 1
fi

INSTANCE_IP="$(terraform -chdir=terraform output -raw instance_public_ip)"

echo "Using EC2 public IP: $INSTANCE_IP"

cat > ansible/inventory.ini <<EOF
[minecraft]
$INSTANCE_IP ansible_user=ubuntu ansible_ssh_private_key_file=$SSH_KEY_PATH ansible_python_interpreter=/usr/bin/python3
EOF

echo "Testing Ansible connection..."
ansible -i ansible/inventory.ini minecraft -m ping

echo "Running Ansible playbook..."
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml

echo "Minecraft server configuration complete."