import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../utils/app_theme.dart';
import '../utils/date_utils.dart' as date_utils;
import '../widgets/task_item.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/royal_routine_widget.dart';

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
        // Ensure Royal Routine tasks exist for this date
        WidgetsBinding.instance.addPostFrameCallback((_) {
          taskProvider.ensureRoyalRoutineTasksForDate(date);
        });

        // Get regular tasks (non-Royal Routine) for this date
        final regularTasks =
            taskProvider.tasks
                .where(
                  (task) =>
                      !task.isDefault &&
                      date_utils.DateUtils.isSameDay(task.dateTime, date),
                )
                .toList()
              ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

        return SingleChildScrollView(
          child: Column(
            children: [
              // Royal Routine Widget
              RoyalRoutineWidget(selectedDate: date),

              // Regular Tasks Section
              if (regularTasks.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Regular Tasks Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMedium,
                          vertical: AppDimensions.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.task_alt,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: AppDimensions.paddingSmall),
                            Text(
                              'Daily Tasks',
                              style: AppTextStyles.headline2.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingMedium),

                      // Regular Tasks List
                      ...regularTasks
                          .map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.paddingSmall,
                              ),
                              child: TaskItem(
                                task: task,
                                onTaskUpdated: (updatedTask) =>
                                    taskProvider.updateTask(updatedTask),
                                onDelete: () =>
                                    taskProvider.deleteTask(task.id),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ] else ...[
                // Empty state for regular tasks
                Container(
                  margin: const EdgeInsets.all(AppDimensions.paddingMedium),
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.add_task, size: 48, color: AppColors.textHint),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      Text(
                        'No daily tasks yet',
                        style: AppTextStyles.headline2.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        'Tap the + button to add your personal tasks',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
