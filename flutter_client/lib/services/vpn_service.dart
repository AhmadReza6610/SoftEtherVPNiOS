import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VpnService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _keyServer = 'vpn_server';
  static const _keyPort = 'vpn_port';
  static const _keyUsername = 'vpn_username';
  static const _keyPassword = 'vpn_password';
  static const _keyConnected = 'vpn_connected';

  // Store password securely
  Future<void> storePassword(String password) async {
    await _secureStorage.write(key: _keyPassword, value: password);
  }
  
  // Retrieve password
  Future<String?> getPassword() async {
    return await _secureStorage.read(key: _keyPassword);
  }
  
  // Save configuration
  Future<void> saveConfiguration({
    required String serverAddress,
    required int port,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServer, serverAddress);
    await prefs.setInt(_keyPort, port);
    await prefs.setString(_keyUsername, username);
  }
  
  // Load configuration
  Future<Map<String, dynamic>> loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'serverAddress': prefs.getString(_keyServer) ?? '',
      'port': prefs.getInt(_keyPort) ?? 443,
      'username': prefs.getString(_keyUsername) ?? '',
    };
  }
  
  // Connect to VPN
  Future<bool> connect({
    required String serverAddress,
    required int port,
    String? username,
    String? password
  }) async {
    try {
      // Save the configuration
      await saveConfiguration(
        serverAddress: serverAddress,
        port: port,
        username: username ?? '',
      );
      
      // In a real implementation, this would use platform channels to:
      // 1. Call the native Swift VPN implementation on iOS
      // 2. Call the native Kotlin implementation on Android
      
      // For demonstration, we'll simulate a successful connection
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyConnected, true);
      
      // In a real implementation, we would trigger the VPN connection here
      
      // Simulating network delay
      await Future.delayed(const Duration(seconds: 2));
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('VPN connection error: $e');
      }
      return false;
    }
  }
  
  // Disconnect from VPN
  Future<bool> disconnect() async {
    try {
      // In a real implementation, this would use platform channels to:
      // 1. Call the native Swift VPN implementation on iOS to disconnect
      // 2. Call the native Kotlin implementation on Android to disconnect
      
      // For demonstration, we'll simulate a successful disconnection
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyConnected, false);
      
      // Simulating network delay
      await Future.delayed(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('VPN disconnection error: $e');
      }
      return false;
    }
  }
  
  // Check if VPN is connected
  Future<bool> checkConnectionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyConnected) ?? false;
  }

  // In a real implementation, these methods would be connected to platform-specific code
  // using MethodChannel to call the native SoftEther VPN implementation
}
