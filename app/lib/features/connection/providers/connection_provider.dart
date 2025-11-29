import 'package:flutter/foundation.dart';
import '../../../core/network/ssh_client.dart';
import '../../../core/network/tunnel_service.dart';
import '../models/server_config.dart';

enum ConnectionStatus { disconnected, connecting, connected, error }

class ConnectionProvider extends ChangeNotifier {
  final SshClientService _sshClient = SshClientService();
  late final TunnelService _tunnelService;

  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _errorMessage;
  ServerConfig? _currentConfig;
  int? _localTunnelPort;

  ConnectionProvider() {
    _tunnelService = TunnelService(_sshClient);
  }

  ConnectionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  ServerConfig? get currentConfig => _currentConfig;
  int? get localTunnelPort => _localTunnelPort;
  bool get isConnected => _status == ConnectionStatus.connected;
  SshClientService get sshClient => _sshClient;

  Future<void> connect(ServerConfig config) async {
    _status = ConnectionStatus.connecting;
    _errorMessage = null;
    _currentConfig = config;
    notifyListeners();

    try {
      await _sshClient.connect(
        host: config.host,
        port: 22,
        username: config.username,
        privateKey: config.privateKey,
        password: config.password,
      );

      _localTunnelPort = config.agentPort;

      _status = ConnectionStatus.connected;
      _errorMessage = null;
    } catch (e) {
      _status = ConnectionStatus.error;
      _errorMessage = e.toString();
      _currentConfig = null;
      _localTunnelPort = null;
    }

    notifyListeners();
  }

  Future<void> disconnect() async {
    try {
      await _tunnelService.closeTunnel();
      await _sshClient.disconnect();
    } catch (e) {
      _errorMessage = 'Disconnect error: ${e.toString()}';
    } finally {
      _status = ConnectionStatus.disconnected;
      _currentConfig = null;
      _localTunnelPort = null;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<String> executeCommand(String command) async {
    if (!isConnected) {
      throw Exception('Not connected to server');
    }
    return await _sshClient.execute(command);
  }

  @override
  void dispose() {
    // Cleanup without notifying listeners after disposal
    _tunnelService.closeTunnel();
    _sshClient.disconnect();
    super.dispose();
  }
}
