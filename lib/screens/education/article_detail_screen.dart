// lib/screens/education/article_detail_screen.dart
import 'package:flutter/material.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article['title'] ?? 'Article')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['category']?.toString().toUpperCase() ?? '',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 12),
            Text(article['content'] ?? '',
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}