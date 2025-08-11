#!/bin/bash

set -e

# Debug mode
if [ "$DEBUG" = "true" ]; then
  set -x
fi

# Install WireGuard if not already installed
if ! command -v wg >/dev/null 2>&1; then
  echo "Installing WireGuard..."
  sudo apt update
  sudo apt install -y wireguard
fi

# Setup WireGuard configuration
echo "Setting up WireGuard configuration..."
echo "$WIREGUARD_PRIVATE_KEY" > privatekey
sudo ip link add dev wg0 type wireguard
sudo ip address add dev wg0 $WIREGUARD_LOCAL_IP peer $WIREGUARD_PEER_IP
sudo wg set wg0 listen-port $WIREGUARD_LOCAL_PORT private-key privatekey peer $WIREGUARD_PEER_PUBLIC_KEY allowed-ips 0.0.0.0/0 endpoint $WIREGUARD_PEER_ENDPOINT
sudo ip link set up dev wg0

echo "WireGuard setup completed"