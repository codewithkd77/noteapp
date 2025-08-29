import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/category.dart';
import '../utils/app_theme.dart';

class AddCategoryEntryDialog extends StatefulWidget {
  final CategoryEntry? entry; // null for new entry, existing entry for editing

  const AddCategoryEntryDialog({super.key, this.entry});

  @override
  State<AddCategoryEntryDialog> createState() => _AddCategoryEntryDialogState();
}

class _AddCategoryEntryDialogState extends State<AddCategoryEntryDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title ?? '';
      _descriptionController.text = widget.entry!.description ?? '';
      _linkController.text = widget.entry!.link ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.entry == null ? 'Add Entry' : 'Edit Entry'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter entry title',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              // Description Field
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter entry description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              // Link Field
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Link (optional)',
                  hintText: 'https://example.com',
                  border: const OutlineInputBorder(),
                  suffixIcon: _linkController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _testLink();
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) {
                  setState(() {}); // Rebuild to show/hide test button
                },
              ),

              if (_linkController.text.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'Tap the icon to test the link',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ],
          ),
        ),
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
                  _saveEntry();
                },
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.entry == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _testLink() async {
    final url = _linkController.text.trim();
    if (url.isNotEmpty) {
      try {
        final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');

        // Try different launch modes in order of preference
        bool launched = false;

        // Try external application first
        try {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          // If external app fails, try platform default
          try {
            launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
          } catch (e) {
            // If platform default fails, try in-app browser
            try {
              launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
            } catch (e) {
              launched = false;
            }
          }
        }

        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not open the link. Please check if you have a browser installed.',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error opening link: $e')));
        }
      }
    }
  }

  void _saveEntry() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final entryData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'link': _linkController.text.trim().isEmpty
          ? null
          : _linkController.text.trim(),
    };

    Navigator.of(context).pop(entryData);
  }
}
