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
  bool _showLinkField = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title ?? '';
      _descriptionController.text = widget.entry!.description ?? '';
      _linkController.text = widget.entry!.link ?? '';
      _showLinkField = widget.entry!.link?.isNotEmpty == true;
    }

    // Auto-focus description field for immediate writing
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

          // More options menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_link') {
                setState(() {
                  _showLinkField = true;
                });
              } else if (value == 'add_title') {
                _showTitleDialog();
              }
            },
            itemBuilder: (context) => [
              if (!_showLinkField)
                const PopupMenuItem(
                  value: 'add_link',
                  child: Row(
                    children: [
                      Icon(Icons.link),
                      SizedBox(width: 8),
                      Text('Add Link'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'add_title',
                child: Row(
                  children: [
                    Icon(Icons.title),
                    SizedBox(width: 8),
                    Text('Add Title'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field (if exists)
          if (_titleController.text.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingLarge,
                AppDimensions.paddingMedium,
                AppDimensions.paddingLarge,
                AppDimensions.paddingSmall,
              ),
              child: Text(
                _titleController.text,
                style: AppTextStyles.headline1(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
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

          // Link field (if visible)
          if (_showLinkField)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
                vertical: AppDimensions.paddingSmall,
              ),
              child: TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  hintText: 'Add a link...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.link, color: color),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showLinkField = false;
                        _linkController.clear();
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
                style: AppTextStyles.bodyMedium(
                  context,
                ).copyWith(color: color, decoration: TextDecoration.underline),
              ),
            ),

          // Main writing area - This is the key part that matches your image
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
                      : 'Start writing or 💡 See examples',
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

          // Bottom toolbar (similar to your reference image)
          Container(
            padding: EdgeInsets.only(
              left: AppDimensions.paddingMedium,
              right: AppDimensions.paddingMedium,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  AppDimensions.paddingMedium,
              top: AppDimensions.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              border: Border(
                top: BorderSide(color: AppColors.border(context), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                // Mood indicator (like in your reference image)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('😊', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        'Great',
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Word count
                Text(
                  '${_descriptionController.text.split(' ').where((word) => word.isNotEmpty).length} words',
                  style: AppTextStyles.bodySmall(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                ),

                const SizedBox(width: AppDimensions.paddingMedium),

                // Quick action buttons (like in your reference)
                IconButton(
                  onPressed: () {
                    // Photo functionality
                  },
                  icon: Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Voice recording functionality
                  },
                  icon: Icon(
                    Icons.mic_outlined,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showLinkField = !_showLinkField;
                    });
                  },
                  icon: Icon(
                    Icons.tag_outlined,
                    color: _showLinkField
                        ? color
                        : AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTitleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _titleController.text);
        return AlertDialog(
          title: const Text('Add Title'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter a title for your entry',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _titleController.text = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
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
          description: description,
          link: link.isNotEmpty ? link : null,
        );
      } else {
        // Create new entry
        await context.read<CategoryProvider>().addCategoryEntry(
          widget.category.id,
          description,
          title: title.isNotEmpty ? title : null,
          description: description,
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
