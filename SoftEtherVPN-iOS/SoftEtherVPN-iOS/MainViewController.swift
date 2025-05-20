//
//  MainViewController.swift
//  SoftEtherVPN-iOS
//
//  Created for SoftEther VPN iOS Client
//

import UIKit
import NetworkExtension

class MainViewController: UIViewController {
    
    // UI Components
    private let connectionButton = UIButton(type: .system)
    private let serverTextField = UITextField()
    private let portTextField = UITextField()
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let statusLabel = UILabel()
    
    // VPN Manager
    private let vpnManager = NEVPNManager.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedConfiguration()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "SoftEther VPN"
        
        // Configure connection button
        connectionButton.setTitle("Connect", for: .normal)
        connectionButton.setTitleColor(.white, for: .normal)
        connectionButton.backgroundColor = .systemBlue
        connectionButton.layer.cornerRadius = 8
        connectionButton.addTarget(self, action: #selector(toggleConnection), for: .touchUpInside)
        
        // Configure text fields
        serverTextField.placeholder = "Server (example.com)"
        serverTextField.borderStyle = .roundedRect
        serverTextField.autocorrectionType = .no
        serverTextField.autocapitalizationType = .none
        
        portTextField.placeholder = "Port (443)"
        portTextField.borderStyle = .roundedRect
        portTextField.keyboardType = .numberPad
        
        usernameTextField.placeholder = "Username (optional)"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none
        
        passwordTextField.placeholder = "Password (optional)"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        
        // Configure status label
        statusLabel.text = "Disconnected"
        statusLabel.textAlignment = .center
        statusLabel.textColor = .systemRed
        
        // Add components to view
        let stackView = UIStackView(arrangedSubviews: [
            serverTextField,
            portTextField,
            usernameTextField,
            passwordTextField,
            connectionButton,
            statusLabel
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            connectionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadSavedConfiguration() {
        vpnManager.loadFromPreferences { [weak self] error in
            if let error = error {
                print("Error loading VPN preferences: \(error.localizedDescription)")
                return
            }
            
            // Update UI based on current configuration
            if let serverAddress = self?.vpnManager.protocolConfiguration?.serverAddress {
                self?.serverTextField.text = serverAddress
            }
            
            // Update connection status
            self?.updateConnectionStatus()
        }
    }
    
    @objc private func toggleConnection() {
        guard let serverAddress = serverTextField.text, !serverAddress.isEmpty else {
            showAlert(title: "Error", message: "Please enter a server address")
            return
        }
        
        let port = Int(portTextField.text ?? "") ?? 443
        
        if vpnManager.connection.status == .disconnected || vpnManager.connection.status == .invalid {
            connectToVPN(server: serverAddress, port: port)
        } else {
            disconnectVPN()
        }
    }
    
    private func connectToVPN(server: String, port: Int) {
        // This is a simplified implementation
        // For a full implementation, we would need to connect to the SoftEther protocol
        // through a custom NetworkExtension provider
        
        let vpnProtocol = NEVPNProtocolIKEv2()
        vpnProtocol.serverAddress = server
        vpnProtocol.serverCertificateIssuerCommonName = server
        vpnProtocol.serverCertificateCommonName = server
        vpnProtocol.remoteIdentifier = server
        vpnProtocol.localIdentifier = "client"
        vpnProtocol.useExtendedAuthentication = true
        vpnProtocol.disconnectOnSleep = false
        vpnProtocol.serverPort = port
        
        if let username = usernameTextField.text, !username.isEmpty,
           let password = passwordTextField.text, !password.isEmpty {
            vpnProtocol.username = username
            vpnProtocol.passwordReference = storePasswordInKeychain(password: password)
        }
        
        vpnManager.protocolConfiguration = vpnProtocol
        vpnManager.localizedDescription = "SoftEther VPN"
        vpnManager.isEnabled = true
        
        vpnManager.saveToPreferences { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to save VPN configuration: \(error.localizedDescription)")
                return
            }
            
            do {
                try self?.vpnManager.connection.startVPNTunnel()
                self?.updateConnectionStatus()
            } catch {
                self?.showAlert(title: "Error", message: "Failed to start VPN: \(error.localizedDescription)")
            }
        }
    }
    
    private func disconnectVPN() {
        vpnManager.connection.stopVPNTunnel()
        updateConnectionStatus()
    }
    
    private func updateConnectionStatus() {
        switch vpnManager.connection.status {
        case .connected:
            statusLabel.text = "Connected"
            statusLabel.textColor = .systemGreen
            connectionButton.setTitle("Disconnect", for: .normal)
            connectionButton.backgroundColor = .systemRed
        case .connecting:
            statusLabel.text = "Connecting..."
            statusLabel.textColor = .systemOrange
            connectionButton.setTitle("Cancel", for: .normal)
            connectionButton.backgroundColor = .systemOrange
        case .disconnecting:
            statusLabel.text = "Disconnecting..."
            statusLabel.textColor = .systemOrange
            connectionButton.setTitle("Disconnecting...", for: .normal)
            connectionButton.backgroundColor = .systemGray
            connectionButton.isEnabled = false
        default:
            statusLabel.text = "Disconnected"
            statusLabel.textColor = .systemRed
            connectionButton.setTitle("Connect", for: .normal)
            connectionButton.backgroundColor = .systemBlue
            connectionButton.isEnabled = true
        }
    }
    
    private func storePasswordInKeychain(password: String) -> Data? {
        // In a real app, this would store the password securely in the Keychain
        // This is a simplified implementation for demonstration purposes
        return password.data(using: .utf8)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
