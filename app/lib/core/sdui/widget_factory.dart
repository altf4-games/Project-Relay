import 'package:flutter/material.dart';

class WidgetFactory {
  static Widget buildWidget(Map<String, dynamic> widgetData) {
    final type = widgetData['type'] as String?;

    switch (type) {
      case 'metric_card':
        return _buildMetricCard(widgetData['data']);
      case 'log_stream':
        return _buildLogStream(widgetData['data']);
      case 'action_button':
        return _buildActionButton(widgetData['data']);
      default:
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Unknown widget type'),
          ),
        );
    }
  }

  static Widget _buildMetricCard(Map<String, dynamic>? data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Metric Card: ${data?['label'] ?? 'N/A'}'),
      ),
    );
  }

  static Widget _buildLogStream(Map<String, dynamic>? data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Log Stream'),
      ),
    );
  }

  static Widget _buildActionButton(Map<String, dynamic>? data) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(data?['label'] ?? 'Action'),
    );
  }
}
