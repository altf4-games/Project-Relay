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
    return Card(
      color: AppTheme.voidBlack.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: OutlinedButton(
          onPressed: _isExecuting ? null : _handlePress,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.electricGreen),
            foregroundColor: AppTheme.electricGreen,
          ),
          child: _isExecuting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.electricGreen),
                  ),
                )
              : Text(widget.label),
        ),
      ),
    );
  }
}
