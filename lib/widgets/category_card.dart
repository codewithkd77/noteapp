import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../utils/app_theme.dart';
import '../screens/category_detail_screen.dart';

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(category.color);

    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final subcategories = categoryProvider.getSubcategories(category.id);
        final totalEntries =
            category.entries.length +
            subcategories.fold<int>(0, (sum, sub) => sum + sub.entries.length);

        return Card(
          child: InkWell(
            onTap: () => _navigateToDetail(context),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.8)],
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
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalEntries',
                          style: AppTextStyles.bodySmall(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    category.name,
                    style: AppTextStyles.headline2(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),

                  if (subcategories.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.create_new_folder,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${subcategories.length} subcategories',
                          style: AppTextStyles.bodySmall(
                            context,
                          ).copyWith(color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    )
                  else
                    Text(
                      category.entries.isEmpty
                          ? 'No entries yet'
                          : 'Last updated ${_getLastUpdateText()}',
                      style: AppTextStyles.bodySmall(
                        context,
                      ).copyWith(color: Colors.white.withOpacity(0.8)),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLastUpdateText() {
    if (category.entries.isEmpty) return 'never';

    final lastEntry = category.entries.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );

    final now = DateTime.now();
    final difference = now.difference(lastEntry.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(category: category),
      ),
    );
  }
}
