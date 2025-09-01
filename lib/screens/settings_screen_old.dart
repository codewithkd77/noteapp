import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/theme_provider.dart';
import 'monthly_reports_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          _buildSection(
            context: context,
            title: 'Personal',
            children: [
              _buildSettingItem(
                context,
                icon: Icons.person,
                title: 'Username',
                subtitle: 'User', // TODO: Get from user settings
                onTap: () => _showUsernameDialog(context),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          _buildSection(
            context: context,
            title: 'Appearance',
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.palette,
                    title: 'Theme',
                    subtitle: themeProvider.themeName,
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        themeProvider.toggleTheme();
                      },
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          _buildSection(
            context: context,
            title: 'Data',
            children: [
              _buildSettingItem(
                context,
                icon: Icons.picture_as_pdf,
                title: 'Monthly Export',
                subtitle: 'Generate PDF reports for any month',
                onTap: () => _navigateToMonthlyReports(context),
              ),
              _buildSettingItem(
                context,
                icon: Icons.delete_forever,
                title: 'Clear All Data',
                subtitle: 'Delete all tasks and categories',
                onTap: () => _showClearDataDialog(context),
                textColor: AppColors.error,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          _buildSection(
            context: context,
            title: 'About',
            children: [
              _buildSettingItem(
                context,
                icon: Icons.info,
                title: 'App Version',
                subtitle: '1.0.0',
              ),
              _buildSettingItem(
                context,
                icon: Icons.bug_report,
                title: 'Report a Bug',
                subtitle: 'Help us improve the app',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.star,
                title: 'Rate App',
                subtitle: 'Rate us on the app store',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppDimensions.paddingMedium,
            bottom: AppDimensions.paddingSmall,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary(context)),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium(
          context,
        ).copyWith(color: textColor, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySmall(context))
          : null,
      trailing:
          trailing ??
          (onTap != null ? const Icon(Icons.arrow_forward_ios) : null),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This feature is coming soon!')),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your tasks, categories, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement clear all data
              _showComingSoon(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showUsernameDialog(BuildContext context) {
    final controller = TextEditingController(
      text: 'User',
    ); // TODO: Get from settings

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Username', style: AppTextStyles.headline2(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                  borderSide: BorderSide(color: AppColors.primary(context)),
                ),
              ),
              maxLength: 30,
              style: AppTextStyles.bodyMedium(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: AppColors.textSecondary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              final username = controller.text.trim();
              if (username.isNotEmpty) {
                // TODO: Save username to settings
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Username updated to "$username"'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _navigateToMonthlyReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MonthlyReportsScreen()),
    );
  }
}
