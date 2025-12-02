import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/sdui/widget_factory.dart';
import '../../../core/sdui/models/widget_data.dart';
import '../../../features/connection/providers/connection_provider.dart';
import '../../../features/terminal/screens/terminal_screen.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
    });
  }

  void _executeCommand(
    WidgetData widget,
    ConnectionProvider connectionProvider,
  ) async {
    if (widget.type != 'action_button') return;

    final command = widget.data['command'] as String?;
    if (command == null || command.isEmpty) return;

    try {
      await connectionProvider.sshClient.execute(command);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Command executed successfully'),
            backgroundColor: AppTheme.electricGreen,
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.read<DashboardProvider>().fetchDashboard();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Command failed: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = context.watch<ConnectionProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();

    final label =
        connectionProvider.currentConfig?.label ??
        connectionProvider.currentConfig?.host ??
        'Server';

    return Scaffold(
      appBar: AppBar(
        title: Text(label),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: dashboardProvider.isLoading
                ? null
                : () => dashboardProvider.fetchDashboard(),
            tooltip: 'Refresh',
          ),
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dashboardProvider.fetchDashboard(),
        child: dashboardProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : dashboardProvider.errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.errorRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dashboardProvider.errorMessage!,
                      style: const TextStyle(color: AppTheme.errorRed),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => dashboardProvider.fetchDashboard(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : dashboardProvider.plugins.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: AppTheme.textGrey),
                    const SizedBox(height: 16),
                    const Text('No plugins data'),
                  ],
                ),
              )
            : _buildStaggeredGrid(dashboardProvider, connectionProvider),
      ),
    );
  }

  Widget _buildStaggeredGrid(
    DashboardProvider dashboardProvider,
    ConnectionProvider connectionProvider,
  ) {
    final allWidgets = <WidgetData>[];
    for (final plugin in dashboardProvider.plugins) {
      allWidgets.addAll(plugin.widgets);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final cardWidth = (width - 12) / 2;

          final List<Widget> rows = [];
          int i = 0;

          while (i < allWidgets.length) {
            final widget = allWidgets[i];

            if (widget.gridWidth == 2) {
              rows.add(
                SizedBox(
                  width: width,
                  height: 140,
                  child: WidgetFactory.buildWidget(
                    widget,
                    onActionExecute: () =>
                        _executeCommand(widget, connectionProvider),
                    metricsHistory: dashboardProvider.metricsHistory,
                  ),
                ),
              );
              i++;
            } else {
              final leftWidget = widget;
              final rightWidget =
                  (i + 1 < allWidgets.length &&
                      allWidgets[i + 1].gridWidth != 2)
                  ? allWidgets[i + 1]
                  : null;

              rows.add(
                Row(
                  children: [
                    SizedBox(
                      width: cardWidth,
                      height: 140,
                      child: WidgetFactory.buildWidget(
                        leftWidget,
                        onActionExecute: () =>
                            _executeCommand(leftWidget, connectionProvider),
                        metricsHistory: dashboardProvider.metricsHistory,
                      ),
                    ),
                    if (rightWidget != null) ...[
                      const SizedBox(width: 12),
                      SizedBox(
                        width: cardWidth,
                        height: 140,
                        child: WidgetFactory.buildWidget(
                          rightWidget,
                          onActionExecute: () =>
                              _executeCommand(rightWidget, connectionProvider),
                          metricsHistory: dashboardProvider.metricsHistory,
                        ),
                      ),
                    ],
                  ],
                ),
              );

              i += rightWidget != null ? 2 : 1;
            }

            if (i < allWidgets.length) {
              rows.add(const SizedBox(height: 12));
            }
          }

          return Column(children: rows);
        },
      ),
    );
  }
}
