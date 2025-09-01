import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../screens/category_entry_link_screen.dart';

class AddCategoryTitleScreen extends StatefulWidget {
  final String categoryId;

  const AddCategoryTitleScreen({super.key, required this.categoryId});

  @override
  State<AddCategoryTitleScreen> createState() => _AddCategoryTitleScreenState();
}

class _AddCategoryTitleScreenState extends State<AddCategoryTitleScreen> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Add Entry Title'),
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
                    backgroundColor: AppColors.primary(context),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.textHint(context).withOpacity(0.3),
                    ),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.textHint(
                      context,
                    ).withOpacity(0.3),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.textHint(context).withOpacity(0.3),
                    ),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.textHint(
                      context,
                    ).withOpacity(0.3),
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
                'Step 1 of 3',
                style: AppTextStyles.caption(
                  context,
                ).copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingSmall),

              // Title instruction
              Text(
                'Enter a title for your new entry',
                style: AppTextStyles.headline2(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                'You\'ll be able to add a link and description on the next page',
                style: AppTextStyles.bodyMedium(
                  context,
                ).copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingLarge * 2),

              // Title input
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Entry Title',
                  hintText: 'Enter a descriptive title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: AppTextStyles.bodyLarge(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const Spacer(),

              // Continue button
              ElevatedButton(
                onPressed: _continueToDetails,
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
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
            ],
          ),
        ),
      ),
    );
  }

  void _continueToDetails() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.lightImpact();

    final title = _titleController.text.trim();

    // Navigate to the link entry screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CategoryEntryLinkScreen(
          categoryId: widget.categoryId,
          title: title,
        ),
      ),
    );
  }
}
