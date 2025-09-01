import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/category_provider.dart';

class CategoryEntryDescriptionScreen extends StatefulWidget {
  final String categoryId;
  final String title;
  final String? link;

  const CategoryEntryDescriptionScreen({
    super.key,
    required this.categoryId,
    required this.title,
    this.link,
  });

  @override
  State<CategoryEntryDescriptionScreen> createState() =>
      _CategoryEntryDescriptionScreenState();
}

class _CategoryEntryDescriptionScreenState
    extends State<CategoryEntryDescriptionScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Add Description'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.paddingLarge),

              // Progress indicator
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary(
                      context,
                    ).withOpacity(0.3),
                    child: Icon(
                      Icons.check,
                      color: AppColors.primary(context),
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.primary(context),
                    ),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary(
                      context,
                    ).withOpacity(0.3),
                    child: Icon(
                      Icons.check,
                      color: AppColors.primary(context),
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.primary(context),
                    ),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary(context),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              Text(
                'Step 3 of 3',
                style: AppTextStyles.caption(
                  context,
                ).copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingSmall),

              // Title and link display
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.title, color: AppColors.primary(context)),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: AppTextStyles.bodyMedium(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    if (widget.link != null) ...[
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Row(
                        children: [
                          Icon(Icons.link, color: AppColors.primary(context)),
                          const SizedBox(width: AppDimensions.paddingSmall),
                          Expanded(
                            child: Text(
                              widget.link!,
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // Description instruction
              Text(
                'Add description',
                style: AppTextStyles.headline1(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                'Write a detailed description for your entry',
                style: AppTextStyles.bodyMedium(
                  context,
                ).copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // Description input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.textHint(context).withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText:
                          'Write your description here...\n\nYou can write as much as you want. This is your space to capture all the details about this entry.',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTextStyles.bodyMedium(context),
                    autofocus: true,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // Navigation buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Save Entry',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEntry() async {
    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.mediumImpact();

      final categoryProvider = context.read<CategoryProvider>();

      // Create new entry
      await categoryProvider.addCategoryEntry(
        widget.categoryId,
        _descriptionController.text.trim(),
        title: widget.title,
        link: widget.link,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry saved successfully!')),
      );

      // Navigate back to category detail (pop all the way back)
      Navigator.of(context).popUntil(
        (route) => route.isFirst || route.settings.name == '/category_detail',
      );
    } catch (e) {
      _showError('Failed to save entry: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
