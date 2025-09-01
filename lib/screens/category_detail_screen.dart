import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../utils/app_theme.dart';
import '../utils/date_utils.dart' as date_utils;
import '../screens/add_category_entry_screen.dart';
import '../widgets/add_subcategory_dialog.dart';

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
      backgroundColor: AppColors.background(context),
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
                                style: AppTextStyles.headline1(
                                  context,
                                ).copyWith(color: Colors.white),
                              ),
                              Consumer<CategoryProvider>(
                                builder: (context, categoryProvider, child) {
                                  if (category.isMainCategory) {
                                    final subcategories = categoryProvider
                                        .getSubcategories(category.id);
                                    return Text(
                                      '${subcategories.length} subcategories',
                                      style: AppTextStyles.bodyMedium(context)
                                          .copyWith(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                    );
                                  } else {
                                    return Text(
                                      '${category.entries.length} entries',
                                      style: AppTextStyles.bodyMedium(context)
                                          .copyWith(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Text(
                      'Created ${date_utils.DateUtils.formatDate(category.createdAt)}',
                      style: AppTextStyles.bodySmall(
                        context,
                      ).copyWith(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),

              // Entries list
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Subcategories section (only for main categories)
                      if (category.isMainCategory) ...[
                        _buildSubcategoriesSection(category, color),
                        const SizedBox(height: AppDimensions.paddingMedium),
                      ],

                      // Entries section (only for subcategories)
                      if (!category.isMainCategory) ...[
                        _buildEntriesSection(category, color),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          final category = categoryProvider.getCategoryById(widget.category.id);
          if (category == null) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () {
              if (category.isMainCategory) {
                // For main categories, add subcategory
                _showAddSubcategoryDialog(category.id, category.color);
              } else {
                // For subcategories, add entry
                _showEntryDialog();
              }
            },
            backgroundColor: color,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
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
                            style: AppTextStyles.bodyLarge(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppDimensions.paddingSmall),
                        ],

                        // Description or content
                        Text(
                          entry.description?.isNotEmpty == true
                              ? entry.description!
                              : entry.content,
                          style: AppTextStyles.bodyMedium(context),
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
                                  color: AppColors.primary(context),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    entry.link!,
                                    style: AppTextStyles.caption(context)
                                        .copyWith(
                                          color: AppColors.primary(context),
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
                              style: AppTextStyles.caption(context),
                            ),
                            if (entry.updatedAt != null)
                              Text(
                                'Edited ${date_utils.DateUtils.formatRelativeTime(entry.updatedAt!)}',
                                style: AppTextStyles.caption(
                                  context,
                                ).copyWith(color: AppColors.primary(context)),
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
    HapticFeedback.lightImpact();

    // Navigate to the full-page entry screen for editing
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddCategoryEntryScreen(category: widget.category, entry: entry),
      ),
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

    // Navigate to the full-page entry screen for both new and existing entries
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddCategoryEntryScreen(category: widget.category, entry: entry),
      ),
    );
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

  Widget _buildSubcategoriesSection(Category category, Color color) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final subcategories = categoryProvider.getSubcategoriesWithEntries(
          category.id,
        );

        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.folder_open, color: color),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Text(
                    'Subcategories',
                    style: AppTextStyles.headline2(context),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        _showAddSubcategoryDialog(category.id, category.color),
                    icon: const Icon(Icons.add_circle_outline),
                    color: color,
                    tooltip: 'Add Subcategory',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              if (subcategories.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.create_new_folder,
                        color: color.withOpacity(0.7),
                        size: 48,
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        'No subcategories yet',
                        style: AppTextStyles.bodyLarge(
                          context,
                        ).copyWith(color: color, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        'Tap + to create subcategories for better organization',
                        style: AppTextStyles.bodySmall(
                          context,
                        ).copyWith(color: AppColors.textSecondary(context)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimensions.paddingSmall,
                    mainAxisSpacing: AppDimensions.paddingSmall,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final subcategory = subcategories[index];
                    return _buildSubcategoryCard(subcategory, color);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubcategoryCard(Category subcategory, Color color) {
    return Card(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategoryDetailScreen(category: subcategory),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.folder, color: Colors.white, size: 20),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Expanded(
                    child: Text(
                      subcategory.name,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                '${subcategory.entries.length} entries',
                style: AppTextStyles.bodySmall(
                  context,
                ).copyWith(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntriesSection(Category category, Color color) {
    if (category.entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.note, color: color),
                const SizedBox(width: AppDimensions.paddingSmall),
                Text('Entries', style: AppTextStyles.headline2(context)),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add,
                    size: 64,
                    color: AppColors.textHint(context),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Text(
                    'No entries yet',
                    style: AppTextStyles.headline2(
                      context,
                    ).copyWith(color: AppColors.textHint(context)),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    'Add your first entry using the + button',
                    style: AppTextStyles.bodyMedium(
                      context,
                    ).copyWith(color: AppColors.textHint(context)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: color),
              const SizedBox(width: AppDimensions.paddingSmall),
              Text('Entries', style: AppTextStyles.headline2(context)),
              const Spacer(),
              Text(
                '${category.entries.length} entries',
                style: AppTextStyles.bodySmall(
                  context,
                ).copyWith(color: AppColors.textSecondary(context)),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category.entries.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppDimensions.paddingMedium),
            itemBuilder: (context, index) {
              final entry = category.entries[index];
              return _buildEntryCard(entry, color);
            },
          ),
        ],
      ),
    );
  }

  void _showAddSubcategoryDialog(String parentId, String parentColor) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AddSubcategoryDialog(
        parentCategoryId: parentId,
        parentCategoryColor: parentColor,
      ),
    );
  }
}
