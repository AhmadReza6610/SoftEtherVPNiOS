import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_connection_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _portController = TextEditingController(text: '443');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load saved configuration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VpnConnectionProvider>(context, listen: false).loadSavedConfiguration();
    });
  }

  @override
  void dispose() {
    _serverController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = Provider.of<VpnConnectionProvider>(context);
    
    // Update text controllers with provider values if they're empty
    if (_serverController.text.isEmpty && vpnProvider.serverAddress.isNotEmpty) {
      _serverController.text = vpnProvider.serverAddress;
    }
    
    if (_portController.text == '443' && vpnProvider.port != 443) {
      _portController.text = vpnProvider.port.toString();
    }
    
    if (_usernameController.text.isEmpty && vpnProvider.username.isNotEmpty) {
      _usernameController.text = vpnProvider.username;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SoftEther VPN Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusIndicator(vpnProvider.status),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _serverController,
                  decoration: const InputDecoration(
                    labelText: 'Server Address',
                    hintText: 'vpn.example.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a server address';
                    }
                    return null;
                  },
                  onChanged: (value) => vpnProvider.serverAddress = value,
                  enabled: vpnProvider.status != ConnectionStatus.connecting && 
                          vpnProvider.status != ConnectionStatus.disconnecting,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    hintText: '443',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a port';
                    }
                    final port = int.tryParse(value);
                    if (port == null || port < 1 || port > 65535) {
                      return 'Please enter a valid port (1-65535)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final port = int.tryParse(value);
                    if (port != null) {
                      vpnProvider.port = port;
                    }
                  },
                  enabled: vpnProvider.status != ConnectionStatus.connecting && 
                          vpnProvider.status != ConnectionStatus.disconnecting,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => vpnProvider.username = value,
                  enabled: vpnProvider.status != ConnectionStatus.connecting && 
                          vpnProvider.status != ConnectionStatus.disconnecting,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onChanged: (value) => vpnProvider.setPassword(value),
                  enabled: vpnProvider.status != ConnectionStatus.connecting && 
                          vpnProvider.status != ConnectionStatus.disconnecting,
                ),
                const SizedBox(height: 24),
                _buildActionButton(vpnProvider),
                if (vpnProvider.status == ConnectionStatus.error) ...[
                  const SizedBox(height: 16),
                  Text(
                    vpnProvider.errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ConnectionStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case ConnectionStatus.connected:
        color = Colors.green;
        text = 'Connected';
        icon = Icons.check_circle;
        break;
      case ConnectionStatus.connecting:
        color = Colors.orange;
        text = 'Connecting...';
        icon = Icons.sync;
        break;
      case ConnectionStatus.disconnecting:
        color = Colors.orange;
        text = 'Disconnecting...';
        icon = Icons.sync;
        break;
      case ConnectionStatus.error:
        color = Colors.red;
        text = 'Error';
        icon = Icons.error;
        break;
      case ConnectionStatus.disconnected:
      default:
        color = Colors.red;
        text = 'Disconnected';
        icon = Icons.cancel;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(VpnConnectionProvider vpnProvider) {
    switch (vpnProvider.status) {
      case ConnectionStatus.connected:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => vpnProvider.disconnect(),
          child: const Text('Disconnect', style: TextStyle(fontSize: 16)),
        );
      case ConnectionStatus.connecting:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: null,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 8),
              Text('Connecting...', style: TextStyle(fontSize: 16)),
            ],
          ),
        );
      case ConnectionStatus.disconnecting:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: null,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 8),
              Text('Disconnecting...', style: TextStyle(fontSize: 16)),
            ],
          ),
        );
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
      default:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              vpnProvider.connect();
            }
          },
          child: const Text('Connect', style: TextStyle(fontSize: 16)),
        );
    }
  }
}
