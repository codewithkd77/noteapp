import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../screens/categories_screen.dart';
import '../screens/search_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 48, color: Colors.white),
                  SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    'Daily Planner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () => Navigator.of(context).pop(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.category,
                  title: 'Categories',
                  onTap: () =>
                      _navigateToScreen(context, const CategoriesScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.search,
                  title: 'Search',
                  onTap: () => _navigateToScreen(context, const SearchScreen()),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Calendar',
                  onTap: () =>
                      _navigateToScreen(context, const CalendarScreen()),
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.picture_as_pdf,
                  title: 'Monthly Reports',
                  onTap: () => _showMonthlyReports(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () =>
                      _navigateToScreen(context, const SettingsScreen()),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Text('Daily Planner v1.0.0', style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  void _showMonthlyReports(BuildContext context) {
    Navigator.of(context).pop();
    // TODO: Implement monthly reports screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Monthly reports feature coming soon!')),
    );
  }
}
