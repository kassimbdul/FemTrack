import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl = article['image_url'] as String?;
    final category = article['category'] as String? ?? 'general';
    final title = article['title'] as String? ?? 'Article';
    final content = article['content'] as String? ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image or color
          SliverAppBar(
            expandedHeight: imageUrl != null ? 220 : 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, style: const TextStyle(fontSize: 18)),
              background: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primaryLight),
                    )
                  : Container(color: AppColors.primaryLight),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Chip(
                    label: Text(category.toUpperCase(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 16),
                  // Content
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          fontSize: 16,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}