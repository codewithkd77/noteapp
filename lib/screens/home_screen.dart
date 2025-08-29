import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../utils/date_utils.dart' as date_utils;
import '../widgets/task_item.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 1000);
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(selectedDate: _currentDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date_utils.DateUtils.formatDayDate(_currentDate),
                  style: AppTextStyles.headline2,
                ),
                StreamBuilder<DateTime>(
                  stream: Stream.periodic(
                    const Duration(seconds: 1),
                    (_) => DateTime.now(),
                  ),
                  builder: (context, snapshot) {
                    final now = snapshot.data ?? DateTime.now();
                    return Text(
                      DateFormat('hh:mm:ss a').format(now),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Hello,', style: AppTextStyles.bodySmall),
                Text(
                  'User', // TODO: Get from settings
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          final baseDate = DateTime.now();
          final daysOffset = index - 1000;
          setState(() {
            _currentDate = baseDate.add(Duration(days: daysOffset));
          });
          context.read<TaskProvider>().setSelectedDate(_currentDate);
        },
        itemBuilder: (context, index) {
          final baseDate = DateTime.now();
          final daysOffset = index - 1000;
          final pageDate = baseDate.add(Duration(days: daysOffset));

          return _buildDayView(pageDate);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDayView(DateTime date) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks =
            taskProvider.tasks
                .where(
                  (task) => date_utils.DateUtils.isSameDay(task.dateTime, date),
                )
                .toList()
              ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 64,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  'No tasks for this day',
                  style: AppTextStyles.headline2.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'Tap the + button to add a task',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          itemCount: tasks.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppDimensions.paddingSmall),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskItem(
              task: task,
              onTap: () => taskProvider.toggleTaskCompletion(task),
              onDelete: () => taskProvider.deleteTask(task.id),
            );
          },
        );
      },
    );
  }
}
