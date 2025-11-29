import 'package:flutter/foundation.dart';

class DashboardProvider extends ChangeNotifier {
  final List<dynamic> _widgets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get widgets => _widgets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardData() async {
    // Placeholder for Phase 3
    _isLoading = true;
    notifyListeners();

    // Simulated delay
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }
}
