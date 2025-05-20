import 'package:flutter/services.dart';

class SoftEtherVpnBridge {
  static const _channel = MethodChannel('com.softethervpn.ios/vpn');
  
  /// Connect to the VPN server
  static Future<bool> connect({
    required String server,
    required int port,
    String? username,
    String? password,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('connect', {
        'server': server,
        'port': port,
        'username': username,
        'password': password,
      });
      
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to connect to VPN: ${e.message}');
      return false;
    }
  }
  
  /// Disconnect from the VPN server
  static Future<bool> disconnect() async {
    try {
      final result = await _channel.invokeMethod<bool>('disconnect');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to disconnect from VPN: ${e.message}');
      return false;
    }
  }
  
  /// Check if the VPN is connected
  static Future<bool> isConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('isConnected');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to check VPN connection status: ${e.message}');
      return false;
    }
  }

  /// Get the current VPN status
  static Future<String> getStatus() async {
    try {
      final result = await _channel.invokeMethod<String>('getStatus');
      return result ?? 'unknown';
    } on PlatformException catch (e) {
      print('Failed to get VPN status: ${e.message}');
      return 'error';
    }
  }
}
