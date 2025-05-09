# Script to build and run the Swift VPN client in Docker

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Server,
    
    [Parameter(Mandatory=$false, Position=1)]
    [string]$Port = "443",
    
    [Parameter(Mandatory=$false, Position=2)]
    [string]$Username = "",
    
    [Parameter(Mandatory=$false, Position=3)]
    [string]$Password = ""
)

# Build the Docker image
Write-Host "Building Docker image for Swift VPN client..." -ForegroundColor Green
docker build -t softether-swift-vpn -f Dockerfile.swift .

# Run the Docker container
Write-Host "Running VPN client connecting to $Server..." -ForegroundColor Green
docker run --rm -it softether-swift-vpn swift fixed_vpn_client.swift $Server $Port $Username $Password
