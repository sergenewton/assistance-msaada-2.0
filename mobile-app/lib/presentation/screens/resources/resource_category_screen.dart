import 'package:flutter/material.dart';
import 'resource_mock_data.dart';

class ResourceCategoryScreen extends StatelessWidget {
  final String categoryId;
  const ResourceCategoryScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final category = kEduCategories.firstWhere((c) => c.id == categoryId, orElse: () => kEduCategories.first);
    final items = kCategoryItems[category.id] ?? const <EduItem>[];
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          title: Text(category.title),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Articles'),
              Tab(text: 'Vidéos'),
              Tab(text: 'Infographies'),
              Tab(text: 'Quiz'),
              Tab(text: 'FAQ'),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF7F8FA),
        body: TabBarView(
          children: [
            _ItemsList(items.where((e) => e.format == 'article').toList(), emptyLabel: 'Aucun article'),
            _ItemsList(items.where((e) => e.format == 'video').toList(), emptyLabel: 'Aucune vidéo'),
            _ItemsList(items.where((e) => e.format == 'infographic').toList(), emptyLabel: 'Aucune infographie'),
            _ItemsList(items.where((e) => e.format == 'quiz').toList(), emptyLabel: 'Aucun quiz'),
            _ItemsList(items.where((e) => e.format == 'faq').toList(), emptyLabel: 'Aucune question'),
          ],
        ),
      ),
    );
  }
}

class _ItemsList extends StatelessWidget {
  final List<EduItem> items;
  final String emptyLabel;
  const _ItemsList(this.items, {required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(emptyLabel, style: const TextStyle(color: Colors.grey)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) => _ItemTile(item: items[i]),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: items.length,
    );
  }
}

class _ItemTile extends StatelessWidget {
  final EduItem item;
  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.format) {
      'article' => Icons.article_outlined,
      'video' => Icons.play_circle_outline,
      'infographic' => Icons.image_outlined,
      'quiz' => Icons.quiz_outlined,
      'faq' => Icons.help_outline,
      _ => Icons.description_outlined,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF16A34A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (item.summary != null) ...[
                  const SizedBox(height: 2),
                  Text(item.summary!, style: const TextStyle(color: Colors.grey)),
                ],
              ],
            ),
          ),
          if (item.duration != null)
            Row(children: [const Icon(Icons.timer_outlined, size: 16, color: Colors.grey), const SizedBox(width: 4), Text(item.duration!, style: const TextStyle(color: Colors.grey))]),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
