import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/sdui/models/widget_data.dart';
import '../../../features/connection/providers/connection_provider.dart';

class DashboardProvider extends ChangeNotifier {
  final ConnectionProvider connectionProvider;

  List<PluginData> _plugins = [];
  Map<String, List<double>> _metricsHistory = {};
  List<String> _widgetOrder = [];
  bool _isLoading = false;
  String? _errorMessage;

  DashboardProvider({required this.connectionProvider}) {
    _loadWidgetOrder();
  }

  List<PluginData> get plugins => _plugins;
  Map<String, List<double>> get metricsHistory => _metricsHistory;
  List<String> get widgetOrder => _widgetOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadWidgetOrder() async {
    final prefs = await SharedPreferences.getInstance();
    _widgetOrder = prefs.getStringList('widget_order') ?? [];
    notifyListeners();
  }

  Future<void> saveWidgetOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('widget_order', order);
    _widgetOrder = order;
    notifyListeners();
  }

  Future<void> fetchDashboard() async {
    if (!connectionProvider.isConnected) {
      _errorMessage = 'Not connected to server';
      notifyListeners();
      return;
    }

    final config = connectionProvider.currentConfig;
    if (config == null) {
      _errorMessage = 'No server configuration';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final command =
          'curl -s -H "x-agent-secret: ${config.agentSecret}" http://127.0.0.1:${config.agentPort}/api/status';
      final result = await connectionProvider.sshClient.execute(command);

      if (result.isEmpty) {
        throw Exception('Empty response from server');
      }

      if (kDebugMode) {
        print('=== Dashboard API Response ===');
        print('Raw output: $result');
        print('Output length: ${result.length}');
        print('=============================');
      }

      dynamic jsonData;
      try {
        jsonData = jsonDecode(result);
      } catch (e) {
        throw Exception('Invalid JSON response: $result');
      }

      if (kDebugMode) {
        print('Parsed JSON: $jsonData');
        print('JSON keys: ${(jsonData as Map).keys}');
      }

      if (jsonData['status'] == 'error') {
        throw Exception(jsonData['error'] ?? 'Unknown error from server');
      }

      final dataList = jsonData['data'];
      if (dataList == null) {
        throw Exception(
          'No data field in response. Available fields: ${(jsonData as Map).keys.join(", ")}',
        );
      }

      _plugins = (dataList as List<dynamic>)
          .map((item) => PluginData.fromJson(item as Map<String, dynamic>))
          .toList();

      final historyData = jsonData['history'];
      if (historyData != null && historyData is Map) {
        _metricsHistory = {
          'cpu':
              (historyData['cpu'] as List<dynamic>?)
                  ?.map((e) => (e as num).toDouble())
                  .toList() ??
              [],
          'memory':
              (historyData['memory'] as List<dynamic>?)
                  ?.map((e) => (e as num).toDouble())
                  .toList() ??
              [],
        };
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch data: ${e.toString()}';
      _plugins = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
