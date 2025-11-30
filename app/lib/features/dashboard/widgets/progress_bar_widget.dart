import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProgressBarWidget extends StatelessWidget {
  final String label;
  final double value;
  final double max;

  const ProgressBarWidget({
    super.key,
    required this.label,
    required this.value,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / max * 100).clamp(0, 100);

    Color progressColor;
    if (percentage < 70) {
      progressColor = AppTheme.electricGreen;
    } else if (percentage < 90) {
      progressColor = Colors.yellow;
    } else {
      progressColor = AppTheme.errorRed;
    }

    return Card(
      color: AppTheme.voidBlack.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: value / max,
              backgroundColor: AppTheme.textGrey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: progressColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
