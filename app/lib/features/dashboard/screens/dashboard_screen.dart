import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/sdui/widget_factory.dart';
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
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: dashboardProvider.plugins.fold<int>(
                  0,
                  (sum, plugin) => sum + plugin.widgets.length,
                ),
                itemBuilder: (context, index) {
                  int currentIndex = 0;
                  for (final plugin in dashboardProvider.plugins) {
                    for (final widget in plugin.widgets) {
                      if (currentIndex == index) {
                        return WidgetFactory.buildWidget(widget);
                      }
                      currentIndex++;
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
      ),
    );
  }
}
