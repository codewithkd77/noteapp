import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../screens/settings_screen.dart';
import '../screens/monthly_reports_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function(int)? onNavigationSelected;
  final int currentIndex;

  const AppDrawer({
    super.key,
    this.onNavigationSelected,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary(context),
                  AppColors.secondary(context),
                ],
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
                // Navigation Section
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Text(
                    'NAVIGATE',
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => _navigateToSection(context, 0),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.category,
                  title: 'Categories',
                  isSelected: currentIndex == 1,
                  onTap: () => _navigateToSection(context, 1),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.schedule,
                  title: 'Hourly Tasks',
                  isSelected: currentIndex == 2,
                  onTap: () => _navigateToSection(context, 2),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.search,
                  title: 'Search',
                  isSelected: currentIndex == 3,
                  onTap: () => _navigateToSection(context, 3),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Calendar',
                  isSelected: currentIndex == 4,
                  onTap: () => _navigateToSection(context, 4),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.book,
                  title: 'Journal',
                  isSelected: currentIndex == 5,
                  onTap: () => _navigateToSection(context, 5),
                ),

                const Divider(),

                // Other Options Section
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Text(
                    'OTHER OPTIONS',
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
            child: Text(
              'Daily Planner v1.0.0',
              style: AppTextStyles.caption(context),
            ),
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
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? AppColors.primary(context)
            : AppColors.textSecondary(context),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium(context).copyWith(
          color: isSelected
              ? AppColors.primary(context)
              : AppColors.textPrimary(context),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary(context).withOpacity(0.1),
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

  void _navigateToSection(BuildContext context, int index) {
    Navigator.of(context).pop();
    if (onNavigationSelected != null) {
      onNavigationSelected!(index);
    }
  }

  void _showMonthlyReports(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MonthlyReportsScreen()),
    );
  }
}
