import 'package:dartssh2/dartssh2.dart';

class SshClientService {
  SSHClient? _client;

  SSHClient? get client => _client;
  bool get isConnected => _client != null;

  Future<void> connect({
    required String host,
    required int port,
    required String username,
    String? privateKey,
    String? password,
  }) async {
    try {
      final socket = await SSHSocket.connect(host, port);

      if (password != null) {
        _client = SSHClient(
          socket,
          username: username,
          onPasswordRequest: () => password,
        );
      } else if (privateKey != null) {
        _client = SSHClient(
          socket,
          username: username,
          identities: [...SSHKeyPair.fromPem(privateKey)],
        );
      } else {
        throw Exception('Either password or privateKey must be provided');
      }

      await _client!.authenticated;
    } catch (e) {
      _client = null;
      throw Exception('SSH Connection Failed: ${e.toString()}');
    }
  }

  Future<void> disconnect() async {
    try {
      _client?.close();
      _client = null;
    } catch (e) {
      throw Exception('Disconnect Failed: ${e.toString()}');
    }
  }

  Future<String> execute(String command) async {
    if (_client == null) {
      throw Exception('Not connected to SSH server');
    }

    try {
      final result = await _client!.run(command);
      return result.toString();
    } catch (e) {
      throw Exception('Command execution failed: ${e.toString()}');
    }
  }

  Future<SSHSession> shell() async {
    if (_client == null) {
      throw Exception('Not connected to SSH server');
    }

    try {
      return await _client!.shell(
        pty: SSHPtyConfig(width: 80, height: 40, type: 'xterm-256color'),
      );
    } catch (e) {
      throw Exception('Failed to create shell: ${e.toString()}');
    }
  }

  Future<SSHForwardChannel> openForwardChannel({
    required String remoteHost,
    required int remotePort,
  }) async {
    if (_client == null) {
      throw Exception('Not connected to SSH server');
    }

    try {
      final channel = await _client!.forwardLocal(remoteHost, remotePort);
      return channel;
    } catch (e) {
      throw Exception('Port forwarding failed: ${e.toString()}');
    }
  }
}
