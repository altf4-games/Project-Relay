class WidgetData {
  final String title;
  final String type;
  final Map<String, dynamic> data;

  WidgetData({
    required this.title,
    required this.type,
    required this.data,
  });

  factory WidgetData.fromJson(Map<String, dynamic> json) {
    return WidgetData(
      title: json['title'] as String? ?? 'Unknown',
      type: json['type'] as String? ?? 'unknown',
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'data': data,
    };
  }
}

class PluginData {
  final String title;
  final List<WidgetData> widgets;
  final String? error;

  PluginData({
    required this.title,
    required this.widgets,
    this.error,
  });

  factory PluginData.fromJson(Map<String, dynamic> json) {
    final widgetsList = json['widgets'] as List<dynamic>? ?? [];
    return PluginData(
      title: json['title'] as String? ?? 'Unknown',
      widgets: widgetsList.map((w) => WidgetData.fromJson(w as Map<String, dynamic>)).toList(),
      error: json['error'] as String?,
    );
  }
}
