import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/sdui/models/widget_data.dart';

void main() {
  group('WidgetData.fromJson', () {
    test('Valid JSON returns correct Object', () {
      final json = {
        'type': 'metric_card',
        'data': {'label': 'CPU Load', 'value': '45%', 'status': 'success'},
      };

      final widget = WidgetData.fromJson(json);

      expect(widget.type, 'metric_card');
      expect(widget.data['label'], 'CPU Load');
      expect(widget.data['value'], '45%');
      expect(widget.data['status'], 'success');
    });

    test('Missing type field returns unknown type (graceful failure)', () {
      final json = {
        'data': {'label': 'RAM Usage', 'value': '2GB'},
      };

      final widget = WidgetData.fromJson(json);

      expect(widget.type, 'unknown');
      expect(widget.data['label'], 'RAM Usage');
    });

    test('Malformed JSON with missing data field', () {
      final json = {'type': 'metric_card'};

      expect(() => WidgetData.fromJson(json), throwsA(isA<Error>()));
    });

    test('Valid progress_bar widget with gridWidth', () {
      final json = {
        'type': 'progress_bar',
        'data': {'label': 'Memory', 'value': 65.5, 'max': 100},
        'gridWidth': 2,
      };

      final widget = WidgetData.fromJson(json);

      expect(widget.type, 'progress_bar');
      expect(widget.gridWidth, 2);
      expect(widget.data['label'], 'Memory');
      expect(widget.data['value'], 65.5);
      expect(widget.data['max'], 100);
    });

    test('Valid action_button widget', () {
      final json = {
        'type': 'action_button',
        'data': {
          'label': 'Restart Service',
          'command': 'systemctl restart nginx',
        },
      };

      final widget = WidgetData.fromJson(json);

      expect(widget.type, 'action_button');
      expect(widget.data['label'], 'Restart Service');
      expect(widget.data['command'], 'systemctl restart nginx');
    });

    test('Empty data map is handled correctly', () {
      final json = {'type': 'metric_card', 'data': {}};

      final widget = WidgetData.fromJson(json);

      expect(widget.type, 'metric_card');
      expect(widget.data, isEmpty);
    });

    test('Null values in data are preserved', () {
      final json = {
        'type': 'metric_card',
        'data': {'label': 'Status', 'value': null},
      };

      final widget = WidgetData.fromJson(json);

      expect(widget.type, 'metric_card');
      expect(widget.data['label'], 'Status');
      expect(widget.data['value'], isNull);
    });
  });
}
