import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          _buildSection(
            title: 'Account',
            children: [
              _buildSettingItem(
                icon: Icons.person,
                title: 'Username',
                subtitle: 'User', // TODO: Get from user settings
                onTap: () {
                  // TODO: Implement username change
                },
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          _buildSection(
            title: 'Appearance',
            children: [
              _buildSettingItem(
                icon: Icons.palette,
                title: 'Theme',
                subtitle: 'Light',
                onTap: () {
                  // TODO: Implement theme selection
                },
              ),
              _buildSettingItem(
                icon: Icons.color_lens,
                title: 'Primary Color',
                subtitle: 'Indigo',
                onTap: () {
                  // TODO: Implement color selection
                },
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          _buildSection(
            title: 'Data',
            children: [
              _buildSettingItem(
                icon: Icons.backup,
                title: 'Export Data',
                subtitle: 'Export all your data',
                onTap: () {
                  // TODO: Implement data export
                  _showComingSoon(context);
                },
              ),
              _buildSettingItem(
                icon: Icons.restore,
                title: 'Import Data',
                subtitle: 'Import data from backup',
                onTap: () {
                  // TODO: Implement data import
                  _showComingSoon(context);
                },
              ),
              _buildSettingItem(
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
            title: 'PDF Reports',
            children: [
              _buildSettingItem(
                icon: Icons.picture_as_pdf,
                title: 'Auto-generate Monthly PDF',
                subtitle: 'Automatically create monthly reports',
                trailing: Switch(
                  value: true, // TODO: Get from settings
                  onChanged: (value) {
                    // TODO: Update setting
                  },
                ),
              ),
              _buildSettingItem(
                icon: Icons.folder,
                title: 'PDF Storage Location',
                subtitle: 'Documents folder',
                onTap: () {
                  // TODO: Show storage location
                  _showComingSoon(context);
                },
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          _buildSection(
            title: 'About',
            children: [
              _buildSettingItem(
                icon: Icons.info,
                title: 'App Version',
                subtitle: '1.0.0',
              ),
              _buildSettingItem(
                icon: Icons.bug_report,
                title: 'Report a Bug',
                subtitle: 'Help us improve the app',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _buildSettingItem(
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
            style: AppTextStyles.headline2.copyWith(color: AppColors.primary),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySmall)
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
}
