import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../utils/app_theme.dart';
import '../widgets/task_item.dart';

class RoyalRoutineWidget extends StatelessWidget {
  final DateTime selectedDate;

  const RoyalRoutineWidget({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        // Get Royal Routine tasks for the selected date
        final royalTasks = taskProvider.tasks
            .where(
              (task) =>
                  task.isDefault &&
                  task.dateTime.year == selectedDate.year &&
                  task.dateTime.month == selectedDate.month &&
                  task.dateTime.day == selectedDate.day,
            )
            .toList();

        if (royalTasks.isEmpty) {
          return const SizedBox.shrink();
        }

        // Group tasks by sections
        final sections = _groupRoyalTasks(royalTasks);

        return Container(
          margin: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.05),
                AppColors.accent.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Royal Routine Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusLarge),
                    topRight: Radius.circular(AppDimensions.radiusLarge),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '⚜ The Royal Routine ⚜',
                      style: AppTextStyles.headline1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      'For the Elite, By the Elite',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Date indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
                color: AppColors.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(
                      _formatDate(selectedDate),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingMedium),

              // Royal Routine Sections
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                child: Column(
                  children: sections.map((section) {
                    final sectionTasks = section['tasks'] as List<Task>;
                    if (sectionTasks.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            section['title'] as String,
                            style: AppTextStyles.headline2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.paddingMedium),

                        // Section Tasks
                        ...sectionTasks
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

                        const SizedBox(height: AppDimensions.paddingLarge),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppDimensions.radiusLarge),
                    bottomRight: Radius.circular(AppDimensions.radiusLarge),
                  ),
                ),
                child: Text(
                  '⚜ Kingsya Royale – For the Elite, By the Elite ⚜',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _groupRoyalTasks(List<Task> royalTasks) {
    return [
      {
        'title': '🌅 Morning Rituals',
        'tasks': royalTasks
            .where(
              (task) =>
                  task.title.contains('Wake up') ||
                  task.title.contains('Meditation') ||
                  task.title.contains('Mindfulness practice') ||
                  task.title.contains('Gratitude note') ||
                  task.title.contains('Reading') ||
                  task.title.contains('Workout'),
            )
            .toList(),
      },
      {
        'title': '📖 Day\'s Focus',
        'tasks': royalTasks
            .where(
              (task) =>
                  task.title.contains('Priority') ||
                  task.title.contains('Notes / Ideas'),
            )
            .toList(),
      },
      {
        'title': '🌙 Night Rituals',
        'tasks': royalTasks
            .where(
              (task) =>
                  task.title.contains('Reflection') ||
                  task.title.contains('Breathing') ||
                  task.title.contains('Sleep'),
            )
            .toList(),
      },
      {
        'title': '🏆 Daily Self-Tracking',
        'tasks': royalTasks
            .where(
              (task) =>
                  task.title.startsWith('Meditation:') ||
                  task.title.startsWith('Mindfulness:') ||
                  task.title.startsWith('Workout:') ||
                  task.title.startsWith('Reading:') ||
                  task.title.startsWith('Diet'),
            )
            .toList(),
      },
      {
        'title': '📌 Reflection',
        'tasks': royalTasks
            .where(
              (task) =>
                  task.title.contains('One win') ||
                  task.title.contains('Lesson learned') ||
                  task.title.contains('Mood rating'),
            )
            .toList(),
      },
    ];
  }

  String _formatDate(DateTime date) {
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final dayName = dayNames[date.weekday - 1];
    final monthName = monthNames[date.month - 1];

    return '$dayName, $monthName ${date.day}, ${date.year}';
  }
}
