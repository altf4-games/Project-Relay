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

  Color _getBarColor(BuildContext context) {
    final percentage = (value / max * 100).clamp(0, 100);
    if (percentage < 70) return Theme.of(context).colorScheme.primary;
    if (percentage < 90) return Colors.yellow;
    return AppTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (value / max * 100).clamp(0, 100);
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
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _getBarColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${value.toStringAsFixed(1)} / ${max.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.voidBlack,
              border: Border.all(color: AppTheme.borderGrey, width: 1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / max,
              child: Container(
                color: _getBarColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
