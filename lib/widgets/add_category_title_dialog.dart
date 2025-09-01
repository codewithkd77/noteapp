import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../screens/category_entry_detail_screen.dart';

class AddCategoryTitleDialog extends StatefulWidget {
  final String categoryId;

  const AddCategoryTitleDialog({super.key, required this.categoryId});

  @override
  State<AddCategoryTitleDialog> createState() => _AddCategoryTitleDialogState();
}

class _AddCategoryTitleDialogState extends State<AddCategoryTitleDialog> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: const Text('Add Entry Title'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter entry title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _continueToDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(context),
            foregroundColor: Colors.white,
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  void _continueToDetails() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.lightImpact();

    final title = _titleController.text.trim();

    Navigator.of(context).pop(); // Close the title dialog

    // Navigate to the detailed entry screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryEntryDetailScreen(
          categoryId: widget.categoryId,
          initialTitle: title,
        ),
      ),
    );
  }
}
