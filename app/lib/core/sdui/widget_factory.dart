import 'package:flutter/material.dart';
import '../../features/dashboard/widgets/metric_card.dart';
import '../theme/app_theme.dart';
import 'models/widget_data.dart';

class WidgetFactory {
  static Widget buildWidget(WidgetData widgetData) {
    switch (widgetData.type) {
      case 'metric_card':
        return _buildMetricCard(widgetData.data);
      case 'log_stream':
        return _buildLogStream(widgetData.data);
      case 'action_button':
        return _buildActionButton(widgetData.data);
      default:
        return Card(
          color: AppTheme.errorRed.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Unknown: ${widgetData.type}',
                style: const TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ),
        );
    }
  }

  static Widget _buildMetricCard(Map<String, dynamic> data) {
    return MetricCard(
      label: data['label'] as String? ?? 'N/A',
      value: data['value'] as String? ?? '0',
      status: data['status'] as String? ?? 'unknown',
    );
  }

  static Widget _buildLogStream(Map<String, dynamic> data) {
    final logs = data['logs'] as List<dynamic>? ?? [];
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['label'] as String? ?? 'LOGS',
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 10),
            ),
            const SizedBox(height: 8),
            ...logs
                .take(5)
                .map(
                  (log) => Text(
                    log.toString(),
                    style: const TextStyle(
                      color: AppTheme.electricGreen,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionButton(Map<String, dynamic> data) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.electricGreen,
        side: const BorderSide(color: AppTheme.electricGreen),
      ),
      child: Text(data['label'] as String? ?? 'Action'),
    );
  }
}
