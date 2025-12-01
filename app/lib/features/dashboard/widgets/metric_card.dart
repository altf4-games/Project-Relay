import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String status;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.status,
  });

  Color _getStatusColor(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'success':
        return Theme.of(context).colorScheme.primary;
      case 'warning':
        return AppTheme.warningYellow;
      case 'error':
        return AppTheme.errorRed;
      default:
        return AppTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceGrey : AppTheme.paperWhite,
        border: Border.all(
          color: isDark ? AppTheme.borderGrey : AppTheme.lightBorder,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getStatusColor(context),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  color: _getStatusColor(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
