import 'package:flutter/material.dart';
import '../../../core/constants/route_constants.dart';
import 'resource_mock_data.dart';

class EducationalResourcesScreen extends StatelessWidget {
  const EducationalResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        title: const Text('Ressources éducatives'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.94,
        ),
        itemCount: kEduCategories.length,
        itemBuilder: (context, i) {
          final c = kEduCategories[i];
          return _CategoryCard(category: c, onTap: () {
            final path = RouteConstants.resourcesCategory.replaceFirst(':id', c.id);
            Navigator.of(context).pushNamed(path);
          });
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final EduCategory category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: const Color(0xFF2E7D32), size: 28),
            ),
            const SizedBox(height: 10),
            Text(category.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(category.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Spacer(),
            Wrap(
              spacing: 6,
              runSpacing: -8,
              children: [
                _countChip(Icons.article_outlined, category.articles),
                _countChip(Icons.play_circle_outline, category.videos),
                _countChip(Icons.image_outlined, category.infographics),
                _countChip(Icons.quiz_outlined, category.quizzes),
                _countChip(Icons.help_outline, category.faqs),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _countChip(IconData icon, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E7ED)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4B5563)),
          const SizedBox(width: 4),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
