import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ActionButtonWidget extends StatefulWidget {
  final String label;
  final String command;
  final VoidCallback onExecute;

  const ActionButtonWidget({
    super.key,
    required this.label,
    required this.command,
    required this.onExecute,
  });

  @override
  State<ActionButtonWidget> createState() => _ActionButtonWidgetState();
}

class _ActionButtonWidgetState extends State<ActionButtonWidget> {
  bool _isExecuting = false;

  void _handlePress() async {
    setState(() {
      _isExecuting = true;
    });

    try {
      widget.onExecute();
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      if (mounted) {
        setState(() {
          _isExecuting = false;
        });
      }
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
      child: Center(
        child: OutlinedButton(
          onPressed: _isExecuting ? null : _handlePress,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: _isExecuting
                  ? (isDark ? AppTheme.borderGrey : AppTheme.lightBorder)
                  : Theme.of(context).colorScheme.primary,
              width: 1,
            ),
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isExecuting
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : Text(
                  widget.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
        ),
      ),
    );
  }
}
