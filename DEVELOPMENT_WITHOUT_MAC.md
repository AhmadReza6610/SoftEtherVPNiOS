# Cross-Platform SoftEther VPN Client

This project provides a cross-platform implementation of a SoftEther VPN client that can be developed on Windows and still run on iOS devices.

## Development Options

Since you don't have access to a Mac, here are several approaches to continue development:

### 1. Use Xamarin (Visual Studio)

Xamarin allows you to build iOS apps from Windows, though you'll still need a Mac build host for final compilation and app store submission.

- Install Visual Studio with Mobile Development workload
- Use the remote Mac build host service or a cloud Mac provider
- Implement the UI using Xamarin.Forms for cross-platform interface

### 2. Use Flutter with Swift Integration

Flutter can be used on Windows to develop iOS apps, with Swift code integration for the native VPN functionality.

- Install Flutter SDK on Windows
- Use Firebase or similar service for app distribution
- Create a Flutter plugin that interfaces with the Swift VPN implementation

### 3. Using a CI/CD Pipeline with GitHub Actions

- Develop the core Swift VPN client on Windows using Docker
- Use GitHub Actions to build the iOS app when pushing to the repository
- Distribute test builds via TestFlight or alternative services

## Building without Xcode

To work on this project without Xcode:

1. Focus on the core Swift VPN client using Docker for testing
2. Use cross-platform tools for the UI development
3. Use a CI/CD service for iOS-specific builds

## Cloud-based Options

- [MacinCloud](https://www.macincloud.com/) or [MacStadium](https://www.macstadium.com/) for remote Mac access
- GitHub Codespaces with iOS development environment 
- Azure DevOps pipelines with Mac build agents

## Testing without an iOS Device

- Use iOS simulators through remote Mac services
- Create a command-line version for functionality testing
- Focus on protocol implementation that can be tested via Docker
