import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import '../utils/app_theme.dart';
import '../widgets/add_journal_entry_dialog.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.library_books)),
            Tab(text: 'Diary', icon: Icon(Icons.book)),
            Tab(text: 'Affirmations', icon: Icon(Icons.favorite)),
            Tab(text: 'Gratitude', icon: Icon(Icons.emoji_emotions)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'stats') {
                _showStatsDialog();
              } else if (value == 'templates') {
                _showTemplatesDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Statistics'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'templates',
                child: Row(
                  children: [
                    Icon(Icons.description),
                    SizedBox(width: 8),
                    Text('Templates'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<JournalProvider>(
        builder: (context, journalProvider, child) {
          if (journalProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary(context),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildEntryList(journalProvider.entries),
              _buildEntryList(journalProvider.diaryEntries),
              _buildEntryList(journalProvider.affirmations),
              _buildEntryList(journalProvider.gratitudeEntries),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(),
        backgroundColor: AppColors.primary(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEntryList(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
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
              'Start writing your thoughts and experiences',
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: AppColors.textHint(context)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildEntryCard(entry);
      },
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: InkWell(
        onTap: () => _editEntry(entry),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getTypeIcon(entry.type),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Expanded(
                    child: Text(
                      entry.title,
                      style: AppTextStyles.bodyLarge(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.mood != null) ...[
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(entry.mood!, style: AppTextStyles.bodyLarge(context)),
                  ],
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
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                entry.content,
                style: AppTextStyles.bodyMedium(context),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Row(
                children: [
                  Text(
                    DateFormat('MMM d, y • h:mm a').format(entry.createdAt),
                    style: AppTextStyles.caption(
                      context,
                    ).copyWith(color: AppColors.textSecondary(context)),
                  ),
                  if (entry.tags.isNotEmpty) ...[
                    const Spacer(),
                    Wrap(
                      spacing: 4,
                      children: entry.tags
                          .take(2)
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: AppTextStyles.caption(context),
                              ),
                              backgroundColor: AppColors.primary(
                                context,
                              ).withOpacity(0.1),
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTypeIcon(JournalType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case JournalType.diary:
        iconData = Icons.book;
        color = AppColors.primary(context);
        break;
      case JournalType.affirmation:
        iconData = Icons.favorite;
        color = Colors.pink;
        break;
      case JournalType.gratitude:
        iconData = Icons.emoji_emotions;
        color = Colors.orange;
        break;
      case JournalType.reflection:
        iconData = Icons.psychology;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  void _showAddEntryDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => const AddJournalEntryDialog(),
    );
  }

  void _editEntry(JournalEntry entry) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AddJournalEntryDialog(entry: entry),
    );
  }

  void _deleteEntry(JournalEntry entry) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "${entry.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<JournalProvider>().deleteEntry(entry);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Entry deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    // TODO: Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search feature coming soon!')),
    );
  }

  void _showStatsDialog() {
    final provider = context.read<JournalProvider>();
    final stats = provider.getEntriesByType();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Journal Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: stats.entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(
                        '${entry.value}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTemplatesDialog() {
    final templates = [
      'What are three things I\'m grateful for today?',
      'What was the highlight of my day?',
      'What did I learn today?',
      'What challenged me today and how did I handle it?',
      'What am I looking forward to tomorrow?',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Journal Templates'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: templates.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(templates[index]),
              onTap: () {
                Navigator.of(context).pop();
                _showAddEntryDialog();
                // TODO: Pre-fill the dialog with the selected template
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
