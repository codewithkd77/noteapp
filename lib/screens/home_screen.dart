import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../utils/date_utils.dart' as date_utils;
import '../widgets/task_item.dart';
import '../widgets/add_task_dialog.dart';

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
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(selectedDate: _currentDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Column(
        children: [
          // Date and time header
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date_utils.DateUtils.formatDayDate(_currentDate),
                          style: AppTextStyles.headline2(context),
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
                              style: AppTextStyles.bodySmall(
                                context,
                              ).copyWith(color: AppColors.primary(context)),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Hello,', style: AppTextStyles.bodySmall(context)),
                    Text(
                      'User', // TODO: Get from settings
                      style: AppTextStyles.bodyMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Page view for date navigation
          Expanded(
            child: PageView.builder(
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
          ),
        ],
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
        // Get all tasks for this date
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
                  color: AppColors.textHint(context),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  'No tasks for this day',
                  style: AppTextStyles.headline2(
                    context,
                  ).copyWith(color: AppColors.textHint(context)),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'Tap the + button to add a task',
                  style: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(color: AppColors.textHint(context)),
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
              onTaskUpdated: (updatedTask) =>
                  taskProvider.updateTask(updatedTask),
              onDelete: () => taskProvider.deleteTask(task.id),
            );
          },
        );
      },
    );
  }
}
