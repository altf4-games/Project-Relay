import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../../../utils/key_storage.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: FutureBuilder(
        future: KeyStorage.loadConfig(),
        builder: (context, snapshot) {
          final config = snapshot.data;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                title: 'CONNECTION',
                children: [
                  _buildInfoTile('Host', config?.host ?? 'Not configured'),
                  _buildInfoTile('Port', config?.agentPort.toString() ?? 'Not configured'),
                  _buildInfoTile('Username', config?.username ?? 'Not configured'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'APPEARANCE',
                children: [
                  _buildThemeModeTile(context, settings),
                  _buildAccentColorTile(context, settings),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'SECURITY',
                children: [
                  _buildBiometricToggle(settings),
                ],
              ),
              const SizedBox(height: 24),
              _buildDisconnectButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceGrey : AppTheme.paperWhite,
            border: Border.all(
              color: isDark ? AppTheme.borderGrey : AppTheme.lightBorder,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...children,
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? AppTheme.borderGrey : AppTheme.lightBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeModeTile(BuildContext context, SettingsProvider settings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.borderGrey : AppTheme.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Theme',
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 12,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppTheme.borderGrey : AppTheme.lightBorder,
                width: 1,
              ),
            ),
            child: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              dropdownColor: isDark ? AppTheme.surfaceGrey : AppTheme.paperWhite,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('SYSTEM'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('DARK'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('LIGHT'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccentColorTile(BuildContext context, SettingsProvider settings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = [
      AppTheme.electricGreen,
      AppTheme.neonBlue,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.borderGrey : AppTheme.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Accent Color',
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 12,
            ),
          ),
          Row(
            children: colors.map((color) {
              final isSelected = settings.accentColor.value == color.value;
              return GestureDetector(
                onTap: () => settings.setAccentColor(color),
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? AppTheme.borderGrey : AppTheme.lightBorder),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricToggle(SettingsProvider settings) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? AppTheme.borderGrey : AppTheme.lightBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Biometric Authentication',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                ),
              ),
              Switch(
                value: settings.isBiometricEnabled,
                onChanged: (value) => settings.toggleBiometrics(value),
                activeColor: Theme.of(context).colorScheme.primary,
                activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                inactiveThumbColor: AppTheme.textGrey,
                inactiveTrackColor: isDark ? AppTheme.borderGrey : AppTheme.lightBorder,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisconnectButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceGrey : AppTheme.paperWhite,
        border: Border.all(color: AppTheme.errorRed, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return AlertDialog(
                  backgroundColor: isDark ? AppTheme.surfaceGrey : AppTheme.paperWhite,
                  shape: const RoundedRectangleBorder(),
                  title: Text(
                    'DISCONNECT',
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.deepNavy),
                  ),
                  content: const Text(
                    'Are you sure you want to disconnect? All saved credentials will be removed.',
                    style: TextStyle(color: AppTheme.textGrey),
                  ),
                  actions: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.borderGrey, width: 1),
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: const Text('CANCEL'),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.errorRed, width: 1),
                        foregroundColor: AppTheme.errorRed,
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: const Text('DISCONNECT'),
                    ),
                  ],
                );
              },
            );

            if (confirm == true && context.mounted) {
              await KeyStorage.deleteConfig();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'DISCONNECT & CLEAR DATA'.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.errorRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
