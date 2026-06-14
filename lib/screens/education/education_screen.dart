// lib/screens/education/education_screen.dart
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  late Future<List<Map<String, dynamic>>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = DatabaseService.getPublishedContent();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithNav(
      title: 'Health Education',
      currentRoute: '/education',
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading articles'));
          }
          final articles = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final article = articles[index];
              return ListTile(
                title: Text(article['title']),
                subtitle: Text(
                  article['category'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(
                    context, '/education/detail',
                    arguments: article),
              );
            },
          );
        },
      ),
    );
  }
}