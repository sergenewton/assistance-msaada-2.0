import 'package:flutter/material.dart';

class EduCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String imageUrl;
  final int articles;
  final int videos;
  final int infographics;
  final int quizzes;
  final int faqs;

  const EduCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imageUrl,
    this.articles = 0,
    this.videos = 0,
    this.infographics = 0,
    this.quizzes = 0,
    this.faqs = 0,
  });
}

const List<EduCategory> kEduCategories = [
  EduCategory(
    id: 'vbg-intro',
    title: "Qu'est-ce que les VBG ?",
    subtitle: 'Définitions, mythes et signes',
    icon: Icons.info_outline,
    imageUrl: 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?q=80&w=1200&auto=format&fit=crop',
    articles: 6,
    videos: 3,
    infographics: 4,
    quizzes: 1,
    faqs: 8,
  ),
  EduCategory(
    id: 'mes-droits',
    title: 'Mes droits',
    subtitle: 'Cadre légal et protection',
    icon: Icons.gavel_outlined,
    imageUrl: 'https://images.unsplash.com/photo-1555375771-14b2a63968ee?q=80&w=1200&auto=format&fit=crop',
    articles: 5,
    videos: 2,
    infographics: 2,
    quizzes: 1,
    faqs: 6,
  ),
  EduCategory(
    id: 'se-proteger',
    title: 'Comment me protéger ?',
    subtitle: 'Plan de sécurité et urgence',
    icon: Icons.shield_outlined,
    imageUrl: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=1200&auto=format&fit=crop',
    articles: 7,
    videos: 2,
    infographics: 3,
    quizzes: 2,
    faqs: 5,
  ),
  EduCategory(
    id: 'soutenir-victime',
    title: 'Soutenir une victime',
    subtitle: 'Écoute, empathie, référer',
    icon: Icons.volunteer_activism_outlined,
    imageUrl: 'https://images.unsplash.com/photo-1518481612222-68bbe828ecd1?q=80&w=1200&auto=format&fit=crop',
    articles: 4,
    videos: 2,
    infographics: 2,
    quizzes: 1,
    faqs: 4,
  ),
];

class EduItem {
  final String id;
  final String title;
  final String format; // article | video | infographic | quiz | faq
  final String? duration; // for videos
  final String? summary;

  const EduItem({
    required this.id,
    required this.title,
    required this.format,
    this.duration,
    this.summary,
  });
}

Map<String, List<EduItem>> kCategoryItems = {
  'vbg-intro': [
    EduItem(id: 'a1', title: 'Définitions et types de VBG', format: 'article', summary: 'Comprendre la diversité des violences.'),
    EduItem(id: 'a2', title: 'Mythes et réalités', format: 'article', summary: 'Démystifier les idées reçues.'),
    EduItem(id: 'v1', title: 'Reconnaître les signes', format: 'video', duration: '2:10'),
    EduItem(id: 'i1', title: 'Infographie: Cycle de la violence', format: 'infographic'),
    EduItem(id: 'q1', title: 'Quiz: Vrai ou faux ?', format: 'quiz'),
    EduItem(id: 'f1', title: 'FAQ: Symptômes et alertes', format: 'faq'),
  ],
  'mes-droits': [
    EduItem(id: 'a3', title: 'Cadre juridique national', format: 'article', summary: 'Lois et textes clés.'),
    EduItem(id: 'a4', title: 'Procédure de plainte', format: 'article', summary: 'Étapes pour signaler.'),
    EduItem(id: 'v2', title: 'Vos droits expliqués', format: 'video', duration: '1:45'),
    EduItem(id: 'i2', title: 'Infographie: Parcours judiciaire', format: 'infographic'),
    EduItem(id: 'f2', title: 'FAQ: Aide juridictionnelle', format: 'faq'),
  ],
  'se-proteger': [
    EduItem(id: 'a5', title: 'Plan de sécurité personnel', format: 'article', summary: 'Préparer, anticiper, agir.'),
    EduItem(id: 'a6', title: 'Signes d\'escalade', format: 'article', summary: 'Repérer l\'urgence.'),
    EduItem(id: 'v3', title: 'Composer un kit d\'urgence', format: 'video', duration: '2:35'),
    EduItem(id: 'i3', title: 'Infographie: Numéros utiles', format: 'infographic'),
    EduItem(id: 'q2', title: 'Quiz: Réflexes sécurité', format: 'quiz'),
  ],
  'soutenir-victime': [
    EduItem(id: 'a7', title: 'Aborder le sujet', format: 'article', summary: 'Sans juger, avec respect.'),
    EduItem(id: 'a8', title: 'Écoute active', format: 'article', summary: 'Techniques clés.'),
    EduItem(id: 'v4', title: 'Référer vers services', format: 'video', duration: '1:55'),
    EduItem(id: 'i4', title: 'Infographie: Postures à éviter', format: 'infographic'),
    EduItem(id: 'f3', title: 'FAQ: Réactions courantes', format: 'faq'),
  ],
};
