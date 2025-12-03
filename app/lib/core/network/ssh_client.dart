import 'dart:convert';
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
      final session = await _client!.execute(command);
      final output = await utf8.decoder.bind(session.stdout).join();
      final stderr = await utf8.decoder.bind(session.stderr).join();

      // Check exit code instead of stderr (many commands write info to stderr)
      final exitCode = await session.exitCode;
      
      if (exitCode != null && exitCode != 0) {
        // Non-zero exit code indicates actual error
        throw Exception('Command failed (exit code $exitCode): ${stderr.isNotEmpty ? stderr : output}');
      }

      // Return stdout even if there was stderr (warnings/info messages are common)
      return output;
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
