import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../screens/category_entry_description_screen.dart';

class CategoryEntryLinkScreen extends StatefulWidget {
  final String categoryId;
  final String title;

  const CategoryEntryLinkScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  State<CategoryEntryLinkScreen> createState() =>
      _CategoryEntryLinkScreenState();
}

class _CategoryEntryLinkScreenState extends State<CategoryEntryLinkScreen> {
  final _linkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Add Link'),
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
                    backgroundColor: AppColors.primary(context),
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
                    child: Text(
                      '3',
                      style: TextStyle(color: AppColors.textHint(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              Text(
                'Step 2 of 3',
                style: AppTextStyles.caption(
                  context,
                ).copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingSmall),

              // Title display
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.title, color: AppColors.primary(context)),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyles.bodyLarge(
                          context,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // Link instruction
              Text(
                'Add a link (Optional)',
                style: AppTextStyles.headline1(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                'Add a website, document, or any URL related to this entry',
                style: AppTextStyles.bodyMedium(
                  context,
                ).copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingLarge * 2),

              // Link input
              TextFormField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Link URL',
                  hintText: 'https://example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.link),
                  suffixIcon: _linkController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: _testLink,
                          tooltip: 'Test link',
                        )
                      : null,
                ),
                keyboardType: TextInputType.url,
                style: AppTextStyles.bodyMedium(context),
                onChanged: (value) {
                  setState(() {}); // Rebuild to show/hide test button
                },
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              // Helper text
              Text(
                'You can skip this step if you don\'t have a link to add',
                style: AppTextStyles.caption(
                  context,
                ).copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

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
                      onPressed: _continueToDescription,
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
                        'Continue to Description',
                        style: TextStyle(
                          fontSize: 14,
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

  void _testLink() async {
    final link = _linkController.text.trim();
    if (link.isNotEmpty) {
      try {
        final uri = Uri.parse(link.startsWith('http') ? link : 'https://$link');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showError('Could not open the link');
        }
      } catch (e) {
        _showError('Invalid link format');
      }
    }
  }

  void _continueToDescription() {
    HapticFeedback.lightImpact();

    final link = _linkController.text.trim();

    // Navigate to the description screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CategoryEntryDescriptionScreen(
          categoryId: widget.categoryId,
          title: widget.title,
          link: link.isEmpty ? null : link,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
