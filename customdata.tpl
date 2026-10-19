#!/bin/bash
set -euxo pipefail

# Update package lists
apt-get update -y

# Install Docker
apt-get install -y docker.io

# Start Docker and enable it after reboot
systemctl enable --now docker

# Add the configured VM user to the Docker group
usermod -aG docker azureuser