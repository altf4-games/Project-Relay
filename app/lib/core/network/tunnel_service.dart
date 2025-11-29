import 'ssh_client.dart';

class TunnelService {
  final SshClientService _sshClient;

  TunnelService(this._sshClient);

  bool get isTunnelActive => false;

  Future<int> createTunnel({
    required int remotePort,
    String remoteHost = 'localhost',
  }) async {
    if (!_sshClient.isConnected) {
      throw Exception('SSH client not connected');
    }

    return remotePort;
  }

  Future<void> closeTunnel() async {}

  int? getLocalPort() {
    return null;
  }
}
