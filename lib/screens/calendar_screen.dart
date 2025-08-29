import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../utils/date_utils.dart' as date_utils;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
              _navigateToSelectedDate();
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              // Calendar widget
              Card(
                margin: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: TableCalendar<dynamic>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) {
                    return taskProvider.tasks
                        .where(
                          (task) => date_utils.DateUtils.isSameDay(
                            task.dateTime,
                            day,
                          ),
                        )
                        .toList();
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    markerDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: AppTextStyles.headline2,
                  ),
                ),
              ),

              // Selected date info
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textHint.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date_utils.DateUtils.getDateLabel(_selectedDay),
                      style: AppTextStyles.headline2,
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      date_utils.DateUtils.formatDate(_selectedDay),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingMedium),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _navigateToSelectedDate,
                        icon: const Icon(Icons.event_note),
                        label: const Text('View Day'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingMedium),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _getTaskCountForDate() > 0
                            ? _showDayTasks
                            : null,
                        icon: const Icon(Icons.list),
                        label: Text('Tasks (${_getTaskCountForDate()})'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingLarge),
            ],
          );
        },
      ),
    );
  }

  int _getTaskCountForDate() {
    final tasks = context.read<TaskProvider>().tasks;
    return tasks
        .where(
          (task) => date_utils.DateUtils.isSameDay(task.dateTime, _selectedDay),
        )
        .length;
  }

  void _navigateToSelectedDate() {
    final taskProvider = context.read<TaskProvider>();
    taskProvider.setSelectedDate(_selectedDay);
    Navigator.of(context).pop();
  }

  void _showDayTasks() {
    final tasks =
        context
            .read<TaskProvider>()
            .tasks
            .where(
              (task) =>
                  date_utils.DateUtils.isSameDay(task.dateTime, _selectedDay),
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textHint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Text(
                      'Tasks for ${date_utils.DateUtils.formatDate(_selectedDay)}',
                      style: AppTextStyles.headline2,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppDimensions.paddingSmall),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      leading: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task.isCompleted
                            ? AppColors.success
                            : AppColors.textHint,
                      ),
                      title: Text(
                        task.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        task.timeString,
                        style: AppTextStyles.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
