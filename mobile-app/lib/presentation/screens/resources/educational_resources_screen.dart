import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kEduCategories.length,
        itemBuilder: (context, i) {
          final c = kEduCategories[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FeaturedCategoryCard(
              category: c,
              onTap: () {
                final path = RouteConstants.resourcesCategory.replaceFirst(':id', c.id);
                context.push(path);
              },
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedCategoryCard extends StatelessWidget {
  final EduCategory category;
  final VoidCallback onTap;
  const _FeaturedCategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured image with gradient overlay and title
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // image
                    Image.network(
                      category.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) => Container(color: const Color(0xFFE5E7EB)),
                    ),
                    // gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x99000000)],
                        ),
                      ),
                    ),
                    // icon chip + title
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(8),
                            child: Icon(category.icon, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              category.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _countRow(Icons.article_outlined, '${category.articles} articles'),
                      const SizedBox(width: 16),
                      _countRow(Icons.play_circle_outline, '${category.videos} vidéos'),
                      const Spacer(),
                      const Icon(Icons.arrow_forward, color: Colors.deepPurple),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Color(0xFF6B7280))),
        ],
      );
}
