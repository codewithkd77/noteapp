import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../utils/app_theme.dart';

class CategoryEntryDetailScreen extends StatefulWidget {
  final String categoryId;
  final String? initialTitle;
  final CategoryEntry? entry; // For editing existing entries

  const CategoryEntryDetailScreen({
    super.key,
    required this.categoryId,
    this.initialTitle,
    this.entry,
  });

  @override
  State<CategoryEntryDetailScreen> createState() =>
      _CategoryEntryDetailScreenState();
}

class _CategoryEntryDetailScreenState extends State<CategoryEntryDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize with existing data if editing
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title ?? '';
      _linkController.text = widget.entry!.link ?? '';
      _descriptionController.text = widget.entry!.description ?? '';
    } else if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(widget.entry != null ? 'Edit Entry' : 'New Entry'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.entry != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteEntry,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter entry title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.words,
                style: AppTextStyles.bodyLarge(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // Link Field (First as requested)
              Text(
                'Link',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              TextFormField(
                controller: _linkController,
                decoration: InputDecoration(
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
                          onPressed: _openLink,
                          tooltip: 'Open link',
                        )
                      : null,
                ),
                keyboardType: TextInputType.url,
                style: AppTextStyles.bodyMedium(context),
                onChanged: (value) {
                  setState(() {}); // Rebuild to show/hide open link button
                },
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // Description Field (Below link as requested)
              Text(
                'Description',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Container(
                height: 250,
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
                  decoration: InputDecoration(
                    hintText: 'Write your description here...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.bodyMedium(context),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge * 2),

              // Save Button
              ElevatedButton(
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
                    : Text(
                        widget.entry != null ? 'Update Entry' : 'Save Entry',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLink() async {
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

  void _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.mediumImpact();

      final categoryProvider = context.read<CategoryProvider>();

      if (widget.entry != null) {
        // Update existing entry
        await categoryProvider.updateCategoryEntry(
          widget.categoryId,
          widget.entry!.id,
          _descriptionController.text.trim(), // content parameter
          title: _titleController.text.trim(),
          link: _linkController.text.trim().isEmpty
              ? null
              : _linkController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry updated successfully!')),
        );
      } else {
        // Create new entry
        await categoryProvider.addCategoryEntry(
          widget.categoryId,
          _descriptionController.text.trim(), // content parameter
          title: _titleController.text.trim(),
          link: _linkController.text.trim().isEmpty
              ? null
              : _linkController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry saved successfully!')),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      _showError('Failed to save entry: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteEntry() async {
    if (widget.entry == null) return;

    HapticFeedback.lightImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
          'Are you sure you want to delete "${widget.entry!.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<CategoryProvider>().deleteCategoryEntry(
          widget.categoryId,
          widget.entry!.id,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully!')),
        );

        Navigator.of(context).pop();
      } catch (e) {
        _showError('Failed to delete entry: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
