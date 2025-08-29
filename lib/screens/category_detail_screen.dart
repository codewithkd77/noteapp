import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../utils/app_theme.dart';
import '../utils/date_utils.dart' as date_utils;
import '../widgets/add_category_entry_dialog.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final _entryController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _entryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(widget.category.color);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          final category = categoryProvider.getCategoryById(widget.category.id);
          if (category == null) {
            return const Center(child: Text('Category not found'));
          }

          return Column(
            children: [
              // Header with category info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppDimensions.radiusLarge),
                    bottomRight: Radius.circular(AppDimensions.radiusLarge),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Colors.white,
                          size: AppDimensions.iconLarge,
                        ),
                        const SizedBox(width: AppDimensions.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: AppTextStyles.headline1.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${category.entries.length} entries',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Text(
                      'Created ${date_utils.DateUtils.formatDate(category.createdAt)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Entries list
              Expanded(
                child: category.entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_add,
                              size: 64,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            Text(
                              'No entries yet',
                              style: AppTextStyles.headline2.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingSmall),
                            Text(
                              'Add your first entry using the text field below',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textHint,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(
                          AppDimensions.paddingMedium,
                        ),
                        itemCount: category.entries.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppDimensions.paddingMedium),
                        itemBuilder: (context, index) {
                          final entry = category.entries[index];
                          return _buildEntryCard(entry, color);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntryDialog(),
        backgroundColor: color,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEntryCard(CategoryEntry entry, Color categoryColor) {
    return Card(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showEntryDialog(entry);
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        if (entry.title?.isNotEmpty == true) ...[
                          Text(
                            entry.title!,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingSmall),
                        ],

                        // Description or content
                        Text(
                          entry.description?.isNotEmpty == true
                              ? entry.description!
                              : entry.content,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Link
                        if (entry.link?.isNotEmpty == true) ...[
                          const SizedBox(height: AppDimensions.paddingSmall),
                          InkWell(
                            onTap: () => _openLink(entry.link!),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    entry.link!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: AppDimensions.paddingSmall),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Created ${date_utils.DateUtils.formatDateTime(entry.createdAt)}',
                              style: AppTextStyles.caption,
                            ),
                            if (entry.updatedAt != null)
                              Text(
                                'Edited ${date_utils.DateUtils.formatRelativeTime(entry.updatedAt!)}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editEntry(entry);
                      } else if (value == 'delete') {
                        _deleteEntry(entry);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editEntry(CategoryEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: entry.content);
        return AlertDialog(
          title: const Text('Edit Entry'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Content'),
            maxLines: null,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newContent = controller.text.trim();
                if (newContent.isNotEmpty) {
                  await context.read<CategoryProvider>().updateCategoryEntry(
                    widget.category.id,
                    entry.id,
                    newContent,
                  );
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(CategoryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<CategoryProvider>().deleteCategoryEntry(
                widget.category.id,
                entry.id,
              );
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Category'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Implement edit category
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Change Color'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Implement change color
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.error),
            title: const Text(
              'Delete Category',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _deleteCategory();
            },
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
        ],
      ),
    );
  }

  void _deleteCategory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category? This will also delete all entries in this category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<CategoryProvider>().deleteCategory(
                widget.category.id,
              );
              if (mounted) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to categories screen
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEntryDialog([CategoryEntry? entry]) async {
    HapticFeedback.lightImpact();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddCategoryEntryDialog(entry: entry),
    );

    if (result != null) {
      final categoryProvider = context.read<CategoryProvider>();

      if (entry == null) {
        // Add new entry
        await categoryProvider.addCategoryEntry(
          widget.category.id,
          '', // Empty content since we're using title/description
          title: result['title'],
          description: result['description'],
          link: result['link'],
        );
      } else {
        // Update existing entry
        await categoryProvider.updateCategoryEntry(
          widget.category.id,
          entry.id,
          '', // Empty content since we're using title/description
          title: result['title'],
          description: result['description'],
          link: result['link'],
        );
      }
    }
  }

  Future<void> _openLink(String url) async {
    HapticFeedback.lightImpact();
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
