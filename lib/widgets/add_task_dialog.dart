import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../utils/app_theme.dart';
import '../utils/date_utils.dart' as date_utils;

class AddTaskDialog extends StatefulWidget {
  final DateTime selectedDate;

  const AddTaskDialog({super.key, required this.selectedDate});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  late TimeOfDay _selectedTime;
  bool _isLoading = false;
  TaskType _selectedTaskType = TaskType.checkbox;
  bool _isDaily = false;

  @override
  void initState() {
    super.initState();
    // Auto-fill with current time rounded to nearest quarter hour
    final now = DateTime.now();
    final rounded = date_utils.DateUtils.roundToNearestQuarterHour(now);
    _selectedTime = TimeOfDay.fromDateTime(rounded);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task description',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              // Task Type Selection
              Text(
                'Task Type',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              DropdownButtonFormField<TaskType>(
                value: _selectedTaskType,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TaskType.checkbox,
                    child: Row(
                      children: [
                        Icon(Icons.check_box_outline_blank, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Checkbox',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: TaskType.text,
                    child: Row(
                      children: [
                        Icon(Icons.text_fields, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Text Input',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: TaskType.number,
                    child: Row(
                      children: [
                        Icon(Icons.numbers, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Number Input',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTaskType = value!;
                  });
                },
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              // Frequency Selection
              Text(
                'Frequency',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              RadioListTile<bool>(
                title: const Text('Today Only'),
                subtitle: const Text('One-time task'),
                value: false,
                groupValue: _isDaily,
                onChanged: (value) {
                  setState(() {
                    _isDaily = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<bool>(
                title: const Text('Daily'),
                subtitle: const Text('Recurring every day'),
                value: true,
                groupValue: _isDaily,
                onChanged: (value) {
                  setState(() {
                    _isDaily = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              // Time Selection
              Text(
                'Time',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      Text(_selectedTime.format(context)),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  _addTask();
                },
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _addTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final taskProvider = context.read<TaskProvider>();

      if (_isDaily) {
        // For daily tasks, create a template datetime with selected time
        final templateDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        await taskProvider.addTask(
          _titleController.text.trim(),
          templateDateTime,
          taskType: _selectedTaskType,
          isDaily: true,
        );
      } else {
        // For one-time tasks, use the selected date and time
        final taskDateTime = DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        await taskProvider.addTask(
          _titleController.text.trim(),
          taskDateTime,
          taskType: _selectedTaskType,
          isDaily: false,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isDaily
                  ? 'Daily task created successfully!'
                  : 'Task added successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding task: $e')));
      }
    }

    setState(() {
      _isLoading = false;
    });
  }
}
