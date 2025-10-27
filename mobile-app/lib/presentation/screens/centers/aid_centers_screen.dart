import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AidCentersScreen extends StatefulWidget {
  const AidCentersScreen({super.key});

  @override
  State<AidCentersScreen> createState() => _AidCentersScreenState();
}

class _AidCentersScreenState extends State<AidCentersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _activeFilters = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filterResources(_RESOURCES, _searchCtrl.text, _activeFilters);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        title: const Text('Centres et dispositifs d\'aide'),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Rechercher un centre, un numéro, une ville…',
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                      },
                    )
                ],
              ),
            ),

            // Filter chips
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _CATEGORIES.map((c) {
                  final selected = _activeFilters.contains(c.key);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c.label),
                      selected: selected,
                      onSelected: (_) => setState(() {
                        if (selected) {
                          _activeFilters.remove(c.key);
                        } else {
                          _activeFilters.add(c.key);
                        }
                      }),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: filtered.isEmpty
                  ? _emptyState(theme)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final r = filtered[i];
                        return _AidResourceCard(resource: r);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_center_outlined, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          const Text('Aucun résultat', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Essayez un autre mot-clé ou retirez des filtres pour voir davantage de dispositifs disponibles.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  List<_AidResource> _filterResources(List<_AidResource> all, String q, Set<String> filters) {
    Iterable<_AidResource> res = all;
    if (filters.isNotEmpty) {
      res = res.where((r) => r.categories.any(filters.contains));
    }
    if (q.trim().isNotEmpty) {
      final qq = q.toLowerCase();
      res = res.where((r) =>
          r.name.toLowerCase().contains(qq) ||
          (r.city?.toLowerCase().contains(qq) ?? false) ||
          (r.region?.toLowerCase().contains(qq) ?? false) ||
          (r.description?.toLowerCase().contains(qq) ?? false) ||
          r.tags.any((t) => t.toLowerCase().contains(qq)));
    }
    return res.toList();
  }
}

class _AidResourceCard extends StatelessWidget {
  final _AidResource resource;
  const _AidResourceCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(resource.icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resource.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: -8,
                      children: resource.tags
                          .map((t) => Chip(
                                label: Text(t),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (resource.description != null) ...[
            const SizedBox(height: 6),
            Text(resource.description!, style: const TextStyle(color: Colors.black87)),
          ],
          const SizedBox(height: 8),
          if (resource.city != null || resource.region != null)
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    [resource.city, resource.region].where((e) => (e ?? '').isNotEmpty).join(' • '),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          if (resource.hours != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.schedule, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(resource.hours!, style: const TextStyle(color: Colors.grey))),
            ]),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (resource.phone != null)
                _ActionButton(
                  icon: Icons.call,
                  label: resource.phone!,
                  onTap: () => _call(resource.phone!),
                ),
              if (resource.whatsapp != null)
                _ActionButton(
                  icon: Icons.chat_outlined,
                  label: 'WhatsApp',
                  onTap: () => _openWhatsapp(resource.whatsapp!),
                ),
              if (resource.website != null)
                _ActionButton(
                  icon: Icons.public,
                  label: 'Site web',
                  onTap: () => _openUrl(resource.website!),
                ),
            ],
          ),
          if (resource.notes != null) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(resource.notes!, style: const TextStyle(color: Colors.grey))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsapp(String number) async {
    final n = number.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$n');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE3E7ED)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2F3B4A)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDef {
  final String key;
  final String label;
  const _CategoryDef(this.key, this.label);
}

const List<_CategoryDef> _CATEGORIES = [
  _CategoryDef('urgences', 'Urgences'),
  _CategoryDef('psychologique', 'Psychologique'),
  _CategoryDef('medical', 'Médical'),
  _CategoryDef('juridique', 'Juridique'),
  _CategoryDef('hebergement', 'Hébergement'),
  _CategoryDef('enfant', 'Enfant'),
  _CategoryDef('police', 'Police/Gendarmerie'),
  _CategoryDef('ong', 'ONG/Associations'),
];

class _AidResource {
  final String name;
  final List<String> categories;
  final List<String> tags;
  final String? description;
  final String? city;
  final String? region;
  final String? phone;
  final String? whatsapp;
  final String? website;
  final String? hours;
  final String? notes;
  final IconData icon;

  const _AidResource({
    required this.name,
    required this.categories,
    required this.tags,
    this.description,
    this.city,
    this.region,
    this.phone,
    this.whatsapp,
    this.website,
    this.hours,
    this.notes,
    required this.icon,
  });
}

// Exemple de contenu (à adapter/personaliser par pays et région)
const List<_AidResource> _RESOURCES = [
  _AidResource(
    name: 'Numéro d\'urgence - Police',
    categories: ['urgences', 'police'],
    tags: ['24/7', 'Gratuit'],
    description: 'Pour danger immédiat. Demandez une intervention rapide et sécurisée.',
    phone: '117',
    hours: '24h/24 - 7j/7',
    icon: Icons.local_police_outlined,
    notes: 'Si vous ne pouvez pas parler, essayez de laisser le téléphone ouvert ou d\'utiliser un mot clé préparé.',
  ),
  _AidResource(
    name: 'Ambulance / Urgences Médicales',
    categories: ['urgences', 'medical'],
    tags: ['24/7', 'Urgence vitale'],
    description: 'En cas de blessures graves ou d\'agression nécessitant des soins immédiats.',
    phone: '118',
    hours: '24h/24 - 7j/7',
    icon: Icons.emergency_outlined,
  ),
  _AidResource(
    name: 'Ligne VBG – Numéro Vert',
    categories: ['psychologique', 'juridique', 'ong'],
    tags: ['Écoute', 'Orientation', 'Gratuit'],
    description:
        'Écoute, conseils, et orientation des victimes de violences basées sur le genre. Exemple: 3919 (France) – adaptez selon votre pays.',
    phone: '3919',
    hours: '7j/7 (heures variables selon pays)',
    icon: Icons.support_agent,
    notes: 'Appelez en mode discret si nécessaire. Votre appel peut n\'apparaître qu\'en numéro générique sur la facture selon opérateur.',
  ),
  _AidResource(
    name: 'Service Psychologique – Association locale',
    categories: ['psychologique', 'ong'],
    tags: ['Écoute', 'Soutien', 'Orientation'],
    description: 'Entretiens psychologiques, groupes de parole, orientation post-traumatique.',
    phone: '+243 999 000 111',
    whatsapp: '+243 999 000 111',
    city: 'Kinshasa',
    region: 'RDC',
    hours: 'Lun–Sam 08:00–19:00',
    icon: Icons.psychology_alt_outlined,
  ),
  _AidResource(
    name: 'Centre de santé partenaire – VBG',
    categories: ['medical'],
    tags: ['Soins', 'Certificat médical'],
    description:
        'Prise en charge médicale initiale, traitement post-exposition, certificat médical et orientation vers examens.',
    phone: '+243 999 123 456',
    city: 'Goma',
    region: 'Nord-Kivu',
    hours: '24h/24 Urgences',
    icon: Icons.local_hospital_outlined,
  ),
  _AidResource(
    name: 'Clinique juridique – Droits des victimes',
    categories: ['juridique', 'ong'],
    tags: ['Conseil', 'Dépôt de plainte'],
    description:
        'Information juridique, assistance au dépôt de plainte, orientation vers un avocat. Gratuit pour les victimes éligibles.',
    phone: '+243 820 000 222',
    website: 'https://example.org/clinique-juridique',
    city: 'Bukavu',
    region: 'Sud-Kivu',
    hours: 'Lun–Ven 09:00–17:00',
    icon: Icons.balance_outlined,
  ),
  _AidResource(
    name: 'Hébergement d\'urgence – Partenaire',
    categories: ['hebergement', 'ong'],
    tags: ['Sécurisé', 'Femmes & enfants'],
    description: 'Accueil temporaire sécurisé, accompagnement social et orientation.',
    phone: '+243 821 111 333',
    city: 'Lubumbashi',
    region: 'Haut-Katanga',
    hours: 'Appel préalable requis',
    icon: Icons.home_work_outlined,
    notes: 'Adresse communiquée après évaluation de sécurité.',
  ),
  _AidResource(
    name: 'Protection des enfants – Ligne 116',
    categories: ['enfant', 'urgences'],
    tags: ['Gratuit', '24/7'],
    description: 'Aide et protection pour les enfants en danger. Exemple: 116 (helpline internationale).',
    phone: '116',
    hours: '24h/24 - 7j/7',
    icon: Icons.child_care_outlined,
  ),
];
