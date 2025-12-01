import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../features/connection/models/server_config.dart';

class KeyStorage {
  static const _storage = FlutterSecureStorage();
  static const _serverConfigKey = 'server_config';
  static const _hashKey = 'agent_secret_hash';

  static String _hashSecret(String secret) {
    final bytes = utf8.encode(secret);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<void> saveConfig(ServerConfig config) async {
    try {
      final hash = _hashSecret(config.agentSecret);
      await _storage.write(key: _hashKey, value: hash);

      final jsonString = json.encode(config.toJson());
      await _storage.write(key: _serverConfigKey, value: jsonString);
    } catch (e) {
      throw Exception('Failed to save config: ${e.toString()}');
    }
  }

  static Future<ServerConfig?> loadConfig() async {
    try {
      final jsonString = await _storage.read(key: _serverConfigKey);
      if (jsonString == null) return null;

      final jsonData = json.decode(jsonString);
      return ServerConfig.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load config: ${e.toString()}');
    }
  }

  static Future<void> deleteConfig() async {
    try {
      await _storage.delete(key: _serverConfigKey);
    } catch (e) {
      throw Exception('Failed to delete config: ${e.toString()}');
    }
  }

  static Future<bool> hasConfig() async {
    try {
      final config = await loadConfig();
      return config != null;
    } catch (e) {
      return false;
    }
  }

  static Future<void> clearAll() async {
    try {
      await _storage.delete(key: _serverConfigKey);
      await _storage.delete(key: _hashKey);
    } catch (e) {
      throw Exception('Failed to clear storage: ${e.toString()}');
    }
  }
}
