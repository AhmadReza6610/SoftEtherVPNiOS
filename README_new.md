# SoftEther VPN iOS Client

An iOS client implementation for SoftEther VPN, allowing iOS devices to connect to SoftEther VPN servers.

## Overview

This project provides an iOS client for connecting to SoftEther VPN servers. It includes both a Swift implementation of the core VPN protocol and an iOS app with a network extension.

## Features

- Connect to SoftEther VPN servers using SSL protocol
- Save and manage multiple server configurations
- Background connection persistence
- Traffic statistics
- Support for various authentication methods

## Project Structure

- `/SoftEtherVPN-iOS` - iOS app source code
- `*.swift` - Core VPN client implementation in Swift
- `Dockerfile.swift` - Swift Docker environment for testing
- `Run-SwiftVpn.ps1` - PowerShell script for running the Docker test environment
- `run_swift_vpn.sh` - Bash script for running the Docker test environment

## Development Environment

To develop and test the SoftEther VPN iOS client, you'll need:

- Xcode 14.0 or higher
- iOS 15.0+ target device
- Network Extension entitlement (for App Store distribution)
- Swift 5.7+

## Docker Support

This repository includes a Docker environment for testing and development of the core VPN client functionality without requiring an iOS device.

### Building and Running with Docker

```bash
# Using the bash script
./run_swift_vpn.sh vpn.example.com 443

# Or using PowerShell on Windows
.\Run-SwiftVpn.ps1 -Server vpn.example.com -Port 443
```

## Building and Running

### Core VPN Client

The core VPN client can be run directly with Swift (on platforms that support it):

```bash
swift fixed_vpn_client.swift vpn.example.com 443
```

### iOS App

1. Open `SoftEtherVPN-iOS/SoftEtherVPN-iOS.xcodeproj` in Xcode
2. Configure your Apple Developer account
3. Set your bundle identifier
4. Enable Network Extension entitlement
5. Build and run on your device or simulator

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Repository

https://github.com/AhmadReza6610/SoftEtherVPNiOS.git
