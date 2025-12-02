import 'package:flutter/material.dart';
import '../../features/dashboard/widgets/metric_card.dart';
import '../../features/dashboard/widgets/metric_chart.dart';
import '../../features/dashboard/widgets/progress_bar_widget.dart';
import '../../features/dashboard/widgets/action_button_widget.dart';
import '../theme/app_theme.dart';
import 'models/widget_data.dart';

class WidgetFactory {
  static Widget buildWidget(
    WidgetData widgetData, {
    VoidCallback? onActionExecute,
    Map<String, List<double>>? metricsHistory,
  }) {
    switch (widgetData.type) {
      case 'metric_card':
        return _buildMetricCard(widgetData.data);
      case 'metric_chart':
        return _buildMetricChart(widgetData.data, metricsHistory);
      case 'progress_bar':
        return _buildProgressBar(widgetData.data);
      case 'log_stream':
        return _buildLogStream(widgetData.data);
      case 'action_button':
        return _buildActionButton(widgetData.data, onActionExecute);
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

  static Widget _buildMetricChart(
    Map<String, dynamic> data,
    Map<String, List<double>>? metricsHistory,
  ) {
    final metricType = data['metricType'] as String?;
    List<double> history = [];
    
    if (metricsHistory != null && metricType != null) {
      history = metricsHistory[metricType] ?? [];
    }
    
    return MetricChart(
      label: data['label'] as String? ?? 'N/A',
      value: data['value'] as String? ?? '0',
      status: data['status'] as String? ?? 'unknown',
      history: history,
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

  static Widget _buildProgressBar(Map<String, dynamic> data) {
    return ProgressBarWidget(
      label: data['label'] as String? ?? 'Progress',
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      max: (data['max'] as num?)?.toDouble() ?? 100.0,
    );
  }

  static Widget _buildActionButton(
    Map<String, dynamic> data,
    VoidCallback? onExecute,
  ) {
    return ActionButtonWidget(
      label: data['label'] as String? ?? 'Action',
      command: data['command'] as String? ?? '',
      onExecute: onExecute ?? () {},
    );
  }
}
