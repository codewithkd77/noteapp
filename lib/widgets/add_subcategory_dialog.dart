import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../utils/app_theme.dart';

class AddSubcategoryDialog extends StatefulWidget {
  final String parentCategoryId;
  final String parentCategoryColor;

  const AddSubcategoryDialog({
    super.key,
    required this.parentCategoryId,
    required this.parentCategoryColor,
  });

  @override
  State<AddSubcategoryDialog> createState() => _AddSubcategoryDialogState();
}

class _AddSubcategoryDialogState extends State<AddSubcategoryDialog> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parentColor = AppColors.fromHex(widget.parentCategoryColor);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.create_new_folder, color: parentColor),
          const SizedBox(width: AppDimensions.paddingSmall),
          const Text('Add Subcategory'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a subcategory to organize your content better.',
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Subcategory Name',
              hintText: 'e.g., Fiction, Non-Fiction, Biography',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                borderSide: BorderSide(color: parentColor, width: 2),
              ),
              prefixIcon: Icon(Icons.folder_open, color: parentColor),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            maxLength: 30,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: parentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(color: parentColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: parentColor, size: 20),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: Text(
                    'This subcategory will inherit the parent color scheme.',
                    style: AppTextStyles.bodySmall(
                      context,
                    ).copyWith(color: parentColor),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                  _addSubcategory();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: parentColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _addSubcategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a subcategory name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<CategoryProvider>().addCategory(
        name,
        widget.parentCategoryColor, // Use parent's color
        parentId: widget.parentCategoryId,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subcategory "$name" created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating subcategory: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
