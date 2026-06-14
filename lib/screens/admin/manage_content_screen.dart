import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';

class ManageContentScreen extends StatefulWidget {
  const ManageContentScreen({super.key});

  @override
  State<ManageContentScreen> createState() => _ManageContentScreenState();
}

class _ManageContentScreenState extends State<ManageContentScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();   // 👈 NEW controller
  String _category = 'general';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _imageUrlCtrl.dispose();                        // 👈 dispose it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithNav(
      title: 'Manage Content',
      currentRoute: '/admin/content',
      isAdmin: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add / Edit Content',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 12),
            // 👇 NEW: Image URL field
            TextField(
              controller: _imageUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
                hintText: 'https://example.com/image.jpg',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'general', child: Text('General')),
                DropdownMenuItem(value: 'hygiene', child: Text('Hygiene')),
                DropdownMenuItem(value: 'nutrition', child: Text('Nutrition')),
                DropdownMenuItem(value: 'exercise', child: Text('Exercise')),
                DropdownMenuItem(
                    value: 'mental_health', child: Text('Mental Health')),
              ],
              onChanged: (val) => setState(() => _category = val!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await DatabaseService.upsertContent({
                  'title': _titleCtrl.text,
                  'content': _contentCtrl.text,
                  'category': _category,
                  'is_published': true,
                  if (_imageUrlCtrl.text.isNotEmpty) 'image_url': _imageUrlCtrl.text,  // 👈 optional
                });
                _titleCtrl.clear();
                _contentCtrl.clear();
                _imageUrlCtrl.clear();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Content saved')),
                  );
                }
              },
              child: const Text('Save Content'),
            ),
            const Divider(height: 40),
            Text('Existing Content',
                style: Theme.of(context).textTheme.titleLarge),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseService.getAllContent(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final items = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item['title']),
                      subtitle: Text(item['category']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await DatabaseService.upsertContent({
                            'id': item['id'],
                            'is_published': false,
                          });
                          setState(() {});
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}