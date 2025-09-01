import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../utils/app_theme.dart';

class AddCategoryEntryScreen extends StatefulWidget {
  final Category category;
  final CategoryEntry? entry; // null for new entry, existing entry for editing

  const AddCategoryEntryScreen({super.key, required this.category, this.entry});

  @override
  State<AddCategoryEntryScreen> createState() => _AddCategoryEntryScreenState();
}

class _AddCategoryEntryScreenState extends State<AddCategoryEntryScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _descriptionFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title ?? '';
      _descriptionController.text = widget.entry!.description ?? '';
      _linkController.text = widget.entry!.link ?? '';
    }

    // Auto-focus description field for immediate writing after title is entered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _descriptionFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(widget.category.color);
    final isEditing = widget.entry != null;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headline2(
          context,
        ).copyWith(color: AppColors.textPrimary(context)),
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        actions: [
          // Save button
          TextButton(
            onPressed: _isLoading ? null : _saveEntry,
            child: Text(
              'Save',
              style: AppTextStyles.bodyLarge(
                context,
              ).copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field - Always visible for entry creation
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingLarge,
              AppDimensions.paddingMedium,
              AppDimensions.paddingLarge,
              AppDimensions.paddingSmall,
            ),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Entry title...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: AppTextStyles.headline2(
                  context,
                ).copyWith(color: AppColors.textHint(context)),
              ),
              style: AppTextStyles.headline2(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
              textCapitalization: TextCapitalization.words,
              cursorColor: color,
            ),
          ),

          // Date/Time info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingSmall,
            ),
            child: Text(
              isEditing
                  ? 'Editing entry'
                  : 'Today at ${TimeOfDay.now().format(context)}',
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: AppColors.textSecondary(context)),
            ),
          ),

          // Link field - Always visible, borderless like dialog
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingSmall,
            ),
            child: Row(
              children: [
                Icon(Icons.link, color: color, size: 20),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: TextField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      hintText: 'Add a link...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: AppTextStyles.bodyMedium(
                        context,
                      ).copyWith(color: AppColors.textHint(context)),
                    ),
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: color,
                      decoration: TextDecoration.underline,
                    ),
                    cursorColor: color,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingSmall,
            ),
            height: 1,
            color: AppColors.textHint(context).withOpacity(0.3),
          ),

          // Main writing area - Full page clean writing experience
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: TextField(
                controller: _descriptionController,
                focusNode: _descriptionFocusNode,
                decoration: InputDecoration(
                  hintText: isEditing
                      ? 'Continue writing...'
                      : 'Start writing your description...',
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.bodyLarge(
                    context,
                  ).copyWith(color: AppColors.textHint(context)),
                ),
                style: AppTextStyles.bodyLarge(context).copyWith(
                  height: 1.6,
                  fontSize: 18, // Larger font for better writing experience
                ),
                maxLines: null,
                expands: true, // This makes it take all available space
                textAlignVertical: TextAlignVertical.top,
                textCapitalization: TextCapitalization.sentences,
                cursorColor: color,
                onChanged: (value) {
                  // Auto-save functionality could be added here
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEntry() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final link = _linkController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something before saving'),
          backgroundColor: AppColors.error,
        ),
      );
      _descriptionFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.mediumImpact();

      if (widget.entry != null) {
        // Update existing entry
        await context.read<CategoryProvider>().updateCategoryEntry(
          widget.category.id,
          widget.entry!.id,
          description,
          title: title.isNotEmpty ? title : null,
          link: link.isNotEmpty ? link : null,
        );
      } else {
        // Create new entry
        await context.read<CategoryProvider>().addCategoryEntry(
          widget.category.id,
          description,
          title: title.isNotEmpty ? title : null,
          link: link.isNotEmpty ? link : null,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.entry != null
                  ? 'Entry updated successfully'
                  : 'Entry saved successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
