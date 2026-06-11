#!/bin/bash

set -euo pipefail

INSTANCE_IP="$(terraform -chdir=terraform output -raw instance_public_ip)"

echo "Verifying Minecraft server on $INSTANCE_IP:25565..."
nmap -sV -Pn -p T:25565 "$INSTANCE_IP"