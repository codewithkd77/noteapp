import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';
import '../utils/app_theme.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTaskUpdated,
    required this.onDelete,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late TextEditingController _textController;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.task.textValue ?? '');
    _numberController = TextEditingController(
      text: widget.task.numberValue?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - only show time for non-default tasks
            if (!widget.task.isDefault) ...[
              Row(
                children: [
                  // Time
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.task.timeString,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Delete button for custom tasks
                  GestureDetector(
                    onTap: () => _showDeleteConfirmation(context),
                    child: Icon(
                      Icons.delete_outline,
                      size: AppDimensions.iconSmall,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
            ],

            // Royal Routine header for default tasks
            if (widget.task.isDefault) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⚜ Royal Routine',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
            ],

            // Task content based on type
            _buildTaskContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskContent() {
    switch (widget.task.taskType) {
      case TaskType.checkbox:
        return _buildCheckboxTask();
      case TaskType.text:
        return _buildTextTask();
      case TaskType.number:
        return _buildNumberTask();
    }
  }

  Widget _buildCheckboxTask() {
    return Row(
      children: [
        // Checkbox
        GestureDetector(
          onTap: () {
            final updatedTask = widget.task;
            updatedTask.isCompleted = !updatedTask.isCompleted;
            widget.onTaskUpdated(updatedTask);
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.task.isCompleted
                  ? AppColors.success
                  : Colors.transparent,
              border: Border.all(
                color: widget.task.isCompleted
                    ? AppColors.success
                    : AppColors.border,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: widget.task.isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),

        const SizedBox(width: AppDimensions.paddingMedium),

        // Task title
        Expanded(
          child: Text(
            widget.task.title,
            style: AppTextStyles.bodyMedium.copyWith(
              decoration: widget.task.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
              color: widget.task.isCompleted
                  ? AppColors.textHint
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextTask() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppDimensions.paddingSmall),

        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Enter your response...',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: AppTextStyles.bodyMedium,
          maxLines: 2,
          onChanged: (value) {
            final updatedTask = widget.task;
            updatedTask.textValue = value;
            widget.onTaskUpdated(updatedTask);
          },
        ),
      ],
    );
  }

  Widget _buildNumberTask() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppDimensions.paddingSmall),

        SizedBox(
          width: 120,
          child: TextField(
            controller: _numberController,
            decoration: InputDecoration(
              hintText: '0',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: AppTextStyles.bodyMedium,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (value) {
              final updatedTask = widget.task;
              updatedTask.numberValue = double.tryParse(value);
              widget.onTaskUpdated(updatedTask);
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
