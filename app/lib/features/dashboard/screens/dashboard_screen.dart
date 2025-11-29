import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/connection/providers/connection_provider.dart';
import '../../../features/terminal/screens/terminal_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConnectionProvider>();
    final label =
        provider.currentConfig?.label ??
        provider.currentConfig?.host ??
        'Server';

    return Scaffold(
      appBar: AppBar(
        title: Text(label),
        actions: [
          IconButton(
            icon: const Icon(Icons.terminal),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TerminalScreen()),
              );
            },
            tooltip: 'Terminal',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt, size: 64, color: AppTheme.electricGreen),
              const SizedBox(height: 16),
              Text(
                'Connected to $label',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Dashboard - Phase 3',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
