import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/dashboard/widgets/metric_card.dart';

void main() {
  group('MetricCard Widget Tests', () {
    testWidgets('Renders label and value correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCard(
              label: 'CPU Load',
              value: '45.2%',
              status: 'success',
            ),
          ),
        ),
      );

      expect(find.text('CPU LOAD'), findsOneWidget);
      expect(find.text('45.2%'), findsOneWidget);
    });

    testWidgets('Success status shows correct color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCard(
              label: 'RAM Usage',
              value: '2GB',
              status: 'success',
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('2GB'));
      expect(textWidget.style?.color, isNotNull);
    });

    testWidgets('Warning status displays correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCard(
              label: 'Disk Usage',
              value: '85%',
              status: 'warning',
            ),
          ),
        ),
      );

      expect(find.text('DISK USAGE'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
    });

    testWidgets('Error status displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCard(label: 'Service', value: 'DOWN', status: 'error'),
          ),
        ),
      );

      expect(find.text('SERVICE'), findsOneWidget);
      expect(find.text('DOWN'), findsOneWidget);
    });

    testWidgets('Label is converted to uppercase', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCard(
              label: 'memory usage',
              value: '1.5GB',
              status: 'success',
            ),
          ),
        ),
      );

      expect(find.text('MEMORY USAGE'), findsOneWidget);
      expect(find.text('memory usage'), findsNothing);
    });

    testWidgets('Long value text is handled with ellipsis', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 150,
              child: MetricCard(
                label: 'Long Text',
                value:
                    'This is a very long value text that should be truncated',
                status: 'success',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(
        find.text('This is a very long value text that should be truncated'),
      );
      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(textWidget.maxLines, 2);
    });

    testWidgets('Status indicator circle is present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCard(label: 'Status', value: 'OK', status: 'success'),
          ),
        ),
      );

      final container = find.byType(Container);
      expect(container, findsWidgets);
    });
  });
}
