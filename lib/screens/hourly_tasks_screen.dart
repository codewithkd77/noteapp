import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/hourly_tasks_provider.dart';
import '../models/hourly_activity.dart';
import '../utils/app_theme.dart';

class HourlyTasksScreen extends StatefulWidget {
  const HourlyTasksScreen({super.key});

  @override
  State<HourlyTasksScreen> createState() => _HourlyTasksScreenState();
}

class _HourlyTasksScreenState extends State<HourlyTasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HourlyTasksProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: AppDimensions.paddingMedium),
          Expanded(child: _buildHourlyList()),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Consumer<HourlyTasksProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _changeDate(provider, -1),
                icon: const Icon(Icons.chevron_left),
                color: AppColors.primary(context),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDatePicker(provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingSmall,
                    ),
                    child: Text(
                      DateFormat(
                        'EEEE, MMMM d, y',
                      ).format(provider.selectedDate),
                      style: AppTextStyles.headline2(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _changeDate(provider, 1),
                icon: const Icon(Icons.chevron_right),
                color: AppColors.primary(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHourlyList() {
    return Consumer<HourlyTasksProvider>(
      builder: (context, provider, child) {
        final activities = provider.activities;

        if (activities.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary(context)),
          );
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildHourlyItem(activity, provider);
          },
        );
      },
    );
  }

  Widget _buildHourlyItem(
    HourlyActivity activity,
    HourlyTasksProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: activity.activity.isNotEmpty
                ? AppColors.primary(context).withOpacity(0.1)
                : AppColors.textSecondary(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                activity.hourDisplay.split(' ')[0], // Time without AM/PM
                style: AppTextStyles.caption(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: activity.activity.isNotEmpty
                      ? AppColors.primary(context)
                      : AppColors.textSecondary(context),
                ),
              ),
              Text(
                activity.hourDisplay.split(' ')[1], // AM/PM
                style: AppTextStyles.caption(context).copyWith(
                  fontSize: 10,
                  color: activity.activity.isNotEmpty
                      ? AppColors.primary(context)
                      : AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          activity.timeRange,
          style: AppTextStyles.bodyMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: activity.activity.isNotEmpty
            ? Text(
                activity.activity,
                style: AppTextStyles.bodySmall(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                'Tap to add activity',
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: AppColors.textSecondary(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
        trailing: activity.activity.isNotEmpty
            ? IconButton(
                onPressed: () => _editActivity(activity, provider),
                icon: const Icon(Icons.edit, size: 20),
                color: AppColors.primary(context),
              )
            : Icon(
                Icons.add_circle_outline,
                color: AppColors.textSecondary(context),
              ),
        onTap: () => _editActivity(activity, provider),
      ),
    );
  }

  void _changeDate(HourlyTasksProvider provider, int days) {
    HapticFeedback.lightImpact();
    final newDate = provider.selectedDate.add(Duration(days: days));
    provider.changeDate(newDate);
  }

  void _showDatePicker(HourlyTasksProvider provider) async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary(context)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.changeDate(picked);
    }
  }

  void _editActivity(HourlyActivity activity, HourlyTasksProvider provider) {
    HapticFeedback.lightImpact();
    final controller = TextEditingController(text: activity.activity);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'What did you do?',
          style: AppTextStyles.headline2(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.timeRange,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.primary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Describe your activity...',
                hintStyle: AppTextStyles.bodyMedium(
                  context,
                ).copyWith(color: AppColors.textSecondary(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                  borderSide: BorderSide(color: AppColors.primary(context)),
                ),
              ),
              maxLines: 3,
              maxLength: 200,
              style: AppTextStyles.bodyMedium(context),
            ),
          ],
        ),
        actions: [
          if (activity.activity.isNotEmpty)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                provider.updateActivity(activity.hour, '');
                Navigator.of(context).pop();
              },
              child: Text(
                'Clear',
                style: AppTextStyles.bodyMedium(
                  context,
                ).copyWith(color: AppColors.error),
              ),
            ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: AppColors.textSecondary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              provider.updateActivity(activity.hour, controller.text.trim());
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
