import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../features/connection/models/server_config.dart';

class KeyStorage {
  static const _storage = FlutterSecureStorage();
  static const _serverConfigKey = 'server_config';

  static Future<void> saveConfig(ServerConfig config) async {
    try {
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
}
