import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import '../utils/app_theme.dart';

class AddJournalEntryDialog extends StatefulWidget {
  final JournalEntry? entry;

  const AddJournalEntryDialog({super.key, this.entry});

  @override
  State<AddJournalEntryDialog> createState() => _AddJournalEntryDialogState();
}

class _AddJournalEntryDialogState extends State<AddJournalEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  JournalType _selectedType = JournalType.diary;
  String? _selectedMood;
  List<String> _tags = [];

  final List<String> _moods = [
    '😊',
    '😢',
    '😡',
    '😴',
    '🤔',
    '😍',
    '😰',
    '🤗',
    '😎',
    '🥳',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _selectedType = widget.entry!.type;
      _selectedMood = widget.entry!.mood;
      _tags = List.from(widget.entry!.tags);
      _tagsController.text = _tags.join(', ');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.entry != null
                            ? 'Edit Entry'
                            : 'New Journal Entry',
                        style: AppTextStyles.headline2(context),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                // Type Selection
                Text('Type', style: AppTextStyles.bodyMedium(context)),
                const SizedBox(height: AppDimensions.paddingSmall),
                Wrap(
                  spacing: AppDimensions.paddingSmall,
                  children: JournalType.values
                      .map(
                        (type) => ChoiceChip(
                          label: Text(_getTypeName(type)),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = type;
                              });
                              HapticFeedback.selectionClick();
                            }
                          },
                          selectedColor: AppColors.primary(
                            context,
                          ).withOpacity(0.2),
                          checkmarkColor: AppColors.primary(context),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: _getTypeHint(_selectedType),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                // Content
                Container(
                  height: 150,
                  child: TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Content',
                      hintText: _getContentHint(_selectedType),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium,
                        ),
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter some content';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                // Mood Selection
                Text(
                  'Mood (Optional)',
                  style: AppTextStyles.bodyMedium(context),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _moods.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('None'),
                            selected: _selectedMood == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedMood = null;
                              });
                              HapticFeedback.selectionClick();
                            },
                          ),
                        );
                      }

                      final mood = _moods[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            mood,
                            style: const TextStyle(fontSize: 20),
                          ),
                          selected: _selectedMood == mood,
                          onSelected: (selected) {
                            setState(() {
                              _selectedMood = selected ? mood : null;
                            });
                            HapticFeedback.selectionClick();
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                // Tags
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: 'Tags (Optional)',
                    hintText: 'work, personal, goals',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _tags = value
                        .split(',')
                        .map((tag) => tag.trim())
                        .where((tag) => tag.isNotEmpty)
                        .toList();
                  },
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingMedium),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(widget.entry != null ? 'Update' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTypeName(JournalType type) {
    switch (type) {
      case JournalType.diary:
        return 'Diary';
      case JournalType.affirmation:
        return 'Affirmation';
      case JournalType.gratitude:
        return 'Gratitude';
      case JournalType.reflection:
        return 'Reflection';
    }
  }

  String _getTypeHint(JournalType type) {
    switch (type) {
      case JournalType.diary:
        return 'My day at...';
      case JournalType.affirmation:
        return 'I am...';
      case JournalType.gratitude:
        return 'I am grateful for...';
      case JournalType.reflection:
        return 'Today I learned...';
    }
  }

  String _getContentHint(JournalType type) {
    switch (type) {
      case JournalType.diary:
        return 'Write about your day, experiences, and thoughts...';
      case JournalType.affirmation:
        return 'Write positive affirmations and beliefs about yourself...';
      case JournalType.gratitude:
        return 'List things you are grateful for today...';
      case JournalType.reflection:
        return 'Reflect on lessons learned, insights, or personal growth...';
    }
  }

  void _saveEntry() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.mediumImpact();

    final provider = context.read<JournalProvider>();

    if (widget.entry != null) {
      // Update existing entry
      provider.updateEntry(
        widget.entry!,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        mood: _selectedMood,
        tags: _tags,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry updated successfully!')),
      );
    } else {
      // Create new entry
      provider.addEntry(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        mood: _selectedMood,
        tags: _tags,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry saved successfully!')),
      );
    }

    Navigator.of(context).pop();
  }
}
