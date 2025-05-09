#!/bin/bash
# Script to build and run the Swift VPN client in Docker

# Build the Docker image
docker build -t softether-swift-vpn -f Dockerfile.swift .

# Run the Docker container
# Pass command line arguments to the Swift script
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <server-address> [port] [username] [password]"
  echo "Example: $0 vpn.example.com 443 user password"
  exit 1
fi

SERVER="$1"
PORT="${2:-443}"
USERNAME="${3:-}"
PASSWORD="${4:-}"

# Run the container with arguments
docker run --rm -it softether-swift-vpn swift fixed_vpn_client.swift "$SERVER" "$PORT" "$USERNAME" "$PASSWORD"
