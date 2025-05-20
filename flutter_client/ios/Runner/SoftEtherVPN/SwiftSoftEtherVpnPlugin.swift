// This file serves as a bridge between the Swift VPN implementation and Flutter

import Flutter
import UIKit
import NetworkExtension

class SwiftSoftEtherVpnPlugin: NSObject, FlutterPlugin {
  private let vpnManager = NEVPNManager.shared()
  
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.softethervpn.ios/vpn", binaryMessenger: registrar.messenger())
    let instance = SwiftSoftEtherVpnPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "connect":
      connect(call, result: result)
    case "disconnect":
      disconnect(result: result)
    case "isConnected":
      isConnected(result: result)
    case "getStatus":
      getStatus(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func connect(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let server = args["server"] as? String,
          let port = args["port"] as? Int else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      return
    }
    
    let username = args["username"] as? String
    let password = args["password"] as? String
    
    // Use the existing Swift VPN client implementation
    SoftEtherVPNClient.shared.connect(to: server, port: port, username: username, password: password) { success, error in
      if let error = error {
        result(FlutterError(code: "CONNECTION_ERROR", message: error.localizedDescription, details: nil))
      } else {
        result(success)
      }
    }
  }
  
  private func disconnect(result: @escaping FlutterResult) {
    SoftEtherVPNClient.shared.disconnect { success, error in
      if let error = error {
        result(FlutterError(code: "DISCONNECTION_ERROR", message: error.localizedDescription, details: nil))
      } else {
        result(success)
      }
    }
  }
  
  private func isConnected(result: @escaping FlutterResult) {
    result(SoftEtherVPNClient.shared.isConnected)
  }
  
  private func getStatus(result: @escaping FlutterResult) {
    let status = SoftEtherVPNClient.shared.connectionStatus
    result(status)
  }
}
