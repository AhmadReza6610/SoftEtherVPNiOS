import 'package:flutter/foundation.dart';
import '../services/vpn_service.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error
}

class VpnConnectionProvider with ChangeNotifier {
  final VpnService _vpnService = VpnService();
  
  String _serverAddress = '';
  int _port = 443;
  String _username = '';
  String _password = '';
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String _errorMessage = '';

  // Getters
  String get serverAddress => _serverAddress;
  int get port => _port;
  String get username => _username;
  ConnectionStatus get status => _status;
  String get errorMessage => _errorMessage;
  
  // Setters
  set serverAddress(String value) {
    _serverAddress = value;
    notifyListeners();
  }
  
  set port(int value) {
    _port = value;
    notifyListeners();
  }
  
  set username(String value) {
    _username = value;
    notifyListeners();
  }
  
  Future<void> setPassword(String value) async {
    _password = value;
    await _vpnService.storePassword(value);
    notifyListeners();
  }
  
  // Methods
  Future<void> connect() async {
    if (_serverAddress.isEmpty) {
      _status = ConnectionStatus.error;
      _errorMessage = 'Server address is required';
      notifyListeners();
      return;
    }
    
    try {
      _status = ConnectionStatus.connecting;
      notifyListeners();
      
      final result = await _vpnService.connect(
        serverAddress: _serverAddress, 
        port: _port,
        username: _username,
        password: _password
      );
      
      if (result) {
        _status = ConnectionStatus.connected;
      } else {
        _status = ConnectionStatus.error;
        _errorMessage = 'Failed to connect to VPN';
      }
    } catch (e) {
      _status = ConnectionStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  Future<void> disconnect() async {
    try {
      _status = ConnectionStatus.disconnecting;
      notifyListeners();
      
      final result = await _vpnService.disconnect();
      
      if (result) {
        _status = ConnectionStatus.disconnected;
      } else {
        _status = ConnectionStatus.error;
        _errorMessage = 'Failed to disconnect from VPN';
      }
    } catch (e) {
      _status = ConnectionStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  Future<void> loadSavedConfiguration() async {
    try {
      final config = await _vpnService.loadConfiguration();
      _serverAddress = config['serverAddress'] ?? '';
      _port = config['port'] ?? 443;
      _username = config['username'] ?? '';
      
      // Check current connection status
      final isConnected = await _vpnService.checkConnectionStatus();
      _status = isConnected ? ConnectionStatus.connected : ConnectionStatus.disconnected;
      
    } catch (e) {
      _status = ConnectionStatus.error;
      _errorMessage = 'Failed to load configuration: ${e.toString()}';
    }
    
    notifyListeners();
  }
}
