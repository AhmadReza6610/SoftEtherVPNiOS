//
//  PacketTunnelProvider.swift
//  SoftEtherVPN-iOS
//
//  Created for SoftEther VPN iOS Client
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    private var connection: SoftEtherVPNClient?
    
    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Server configuration
        let serverAddress = protocolConfiguration.serverAddress ?? "unknown"
        let serverPort = (protocolConfiguration as? NETunnelProviderProtocol)?.serverPort ?? 443
        
        // Authentication
        var username: String?
        var password: String?
        
        if let protocolConfiguration = protocolConfiguration as? NETunnelProviderProtocol,
           let passwordRef = protocolConfiguration.passwordReference {
            username = protocolConfiguration.username
            password = String(data: passwordRef, encoding: .utf8)
        }
        
        // Set up network settings
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: serverAddress)
        
        // Configure IPv4 settings
        let ipv4Settings = NEIPv4Settings(addresses: ["192.168.1.2"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        networkSettings.ipv4Settings = ipv4Settings
        
        // DNS settings
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        dnsSettings.matchDomains = [""]
        networkSettings.dnsSettings = dnsSettings
        
        // Set the network settings
        setTunnelNetworkSettings(networkSettings) { error in
            if let error = error {
                NSLog("Failed to set tunnel network settings: \(error.localizedDescription)")
                completionHandler(error)
                return
            }
            
            // Initialize and start the SoftEther VPN client
            let client = SoftEtherVPNClient()
            self.connection = client
            
            // Connect to the VPN server
            client.connect(to: serverAddress, port: Int(serverPort), username: username, password: password) { result in
                switch result {
                case .success:
                    NSLog("Successfully connected to SoftEther VPN server")
                    completionHandler(nil)
                case .failure(let error):
                    NSLog("Failed to connect to SoftEther VPN server: \(error.localizedDescription)")
                    completionHandler(error)
                }
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Disconnect from the VPN server
        if let connection = connection {
            connection.disconnect { error in
                if let error = error {
                    NSLog("Error disconnecting from VPN: \(error.localizedDescription)")
                } else {
                    NSLog("Successfully disconnected from VPN")
                }
                completionHandler()
            }
        } else {
            completionHandler()
        }
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Handle messages from the containing app
        if let message = String(data: messageData, encoding: .utf8) {
            NSLog("Received message from app: \(message)")
        }
        
        completionHandler?(nil)
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Handle system sleep event
        NSLog("Device going to sleep")
        completionHandler()
    }
    
    override func wake() {
        // Handle system wake event
        NSLog("Device waking up")
    }
}
