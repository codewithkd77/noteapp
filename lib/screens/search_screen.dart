import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../utils/app_theme.dart';
import '../widgets/task_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks and categories...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Consumer<SearchProvider>(
                  builder: (context, searchProvider, child) {
                    if (searchProvider.searchQuery.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SearchProvider>().clearSearch();
                      },
                    );
                  },
                ),
              ),
              onChanged: (query) {
                context.read<SearchProvider>().search(query);
              },
            ),
          ),

          // Search results
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (searchProvider.searchQuery.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: AppColors.textHint(context),
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        Text(
                          'Search your tasks and categories',
                          style: AppTextStyles.headline2(
                            context,
                          ).copyWith(color: AppColors.textHint(context)),
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Text(
                          'Enter keywords in the search box above',
                          style: AppTextStyles.bodyMedium(
                            context,
                          ).copyWith(color: AppColors.textHint(context)),
                        ),
                      ],
                    ),
                  );
                }

                final results = searchProvider.searchResults;

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textHint(context),
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        Text(
                          'No results found',
                          style: AppTextStyles.headline2(
                            context,
                          ).copyWith(color: AppColors.textHint(context)),
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Text(
                          'Try different keywords',
                          style: AppTextStyles.bodyMedium(
                            context,
                          ).copyWith(color: AppColors.textHint(context)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  itemCount: results.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppDimensions.paddingSmall),
                  itemBuilder: (context, index) {
                    final result = results[index];

                    if (result is Task) {
                      return TaskItem(
                        task: result,
                        onTaskUpdated: (updatedTask) {
                          // TODO: Update task in provider
                        },
                        onDelete: () {
                          // TODO: Delete task
                        },
                      );
                    } else if (result is Category) {
                      return _buildCategoryResult(result);
                    } else if (result is CategoryEntry) {
                      return _buildCategoryEntryResult(result);
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryResult(Category category) {
    final color = AppColors.fromHex(category.color);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.folder, color: Colors.white),
        ),
        title: Text(
          category.name,
          style: AppTextStyles.bodyMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${category.entries.length} entries',
          style: AppTextStyles.bodySmall(context),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: Navigate to category detail
        },
      ),
    );
  }

  Widget _buildCategoryEntryResult(CategoryEntry entry) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent(context),
          child: const Icon(Icons.note, color: Colors.white),
        ),
        title: Text(
          entry.content,
          style: AppTextStyles.bodyMedium(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Created ${entry.formattedTimestamp}',
          style: AppTextStyles.bodySmall(context),
        ),
        onTap: () {
          // TODO: Navigate to category entry
        },
      ),
    );
  }
}
