import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'hourly_tasks_screen.dart';
import 'search_screen.dart';
import 'calendar_screen.dart';
import 'journal_screen.dart';
import 'monthly_reports_screen.dart';
import '../widgets/app_drawer.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const HourlyTasksScreen(),
    const SearchScreen(),
    const CalendarScreen(),
    const JournalScreen(),
  ];

  final List<String> _titles = [
    'Daily Planner',
    'Categories',
    'Hourly Tasks',
    'Search',
    'Calendar',
    'Journal',
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.category,
    Icons.schedule,
    Icons.search,
    Icons.calendar_today,
    Icons.book,
  ];

  void _onTabTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      drawer: AppDrawer(
        onNavigationSelected: _onTabTapped,
        currentIndex: _currentIndex,
      ),
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headline1(
          context,
        ).copyWith(color: AppColors.textPrimary(context)),
        iconTheme: IconThemeData(color: AppColors.primary(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _navigateToMonthlyReports(context),
            tooltip: 'Monthly Reports',
          ),
        ],
      ),
      body: _screens[_currentIndex],
    );
  }

  void _navigateToMonthlyReports(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MonthlyReportsScreen()),
    );
  }
}
