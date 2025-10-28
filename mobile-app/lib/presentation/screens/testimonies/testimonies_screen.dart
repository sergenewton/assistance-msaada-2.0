import 'package:flutter/material.dart';

class TestimoniesScreen extends StatefulWidget {
  const TestimoniesScreen({super.key});

  @override
  State<TestimoniesScreen> createState() => _TestimoniesScreenState();
}

class _TestimoniesScreenState extends State<TestimoniesScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _storyController = TextEditingController();
  bool _anonymous = true;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  void _submitStory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Merci pour votre témoignage. Il sera examiné avant publication.')),
    );
    setState(() {
      _anonymous = true;
      _nameController.clear();
      _ageController.clear();
      _storyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Témoignages et Histoires')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(
                title: 'Expériences de survie et de guérison',
                subtitle:
                    "Les histoires partagées ici sont des voix de courage, de résilience et d’espoir. Elles rappellent que la guérison est possible, et que chaque pas vers la paix intérieure est une victoire.\n\nVous pouvez lire ces récits en toute confidentialité, ou partager le vôtre si vous le souhaitez.",
              ),
              const SizedBox(height: 16),
              _StoriesSection(),
              const SizedBox(height: 16),
              _HealingThemesSection(),
              const SizedBox(height: 16),
              _MapSection(),
              const SizedBox(height: 16),
              _ShareYourStorySection(
                nameController: _nameController,
                ageController: _ageController,
                storyController: _storyController,
                anonymous: _anonymous,
                onAnonymousChanged: (v) => setState(() => _anonymous = v),
                onSubmit: _submitStory,
              ),
              const SizedBox(height: 16),
              _EncouragementCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _HeaderCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.favorite_outline, color: Color(0xFF9C27B0)),
              SizedBox(width: 8),
              Text('Témoignages et Histoires', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _StoriesSection extends StatelessWidget {
  final List<_Story> stories = const [
    _Story(
      author: 'Aline – “Recommencer à vivre”',
      text:
          '“Pendant des années, j’ai gardé le silence.\nGrâce au soutien du centre d’écoute de mon quartier, j’ai trouvé la force de parler.\nAujourd’hui, je travaille avec d’autres femmes pour sensibiliser nos filles à leurs droits.”\n\n— Aline, 32 ans, survivante de violences conjugales',
    ),
    _Story(
      author: 'Jeanette – “La parole m’a libérée”',
      text:
          '“Je pensais que tout était fini.\nMais quand j’ai raconté mon histoire au groupe de femmes, j’ai compris que je n’étais pas seule.\nPartager, c’est guérir.”\n\n— Jeanette, 25 ans, victime de mariage forcé',
    ),
    _Story(
      author: 'Annonciata – “L’éducation m’a sauvée”',
      text:
          '“J’ai repris mes études après avoir été chassée de chez moi.\nAujourd’hui, je veux être enseignante pour dire à chaque fille qu’elle a le droit d’apprendre et de rêver.”\n\n— Annonciata, 18 ans, bénéficiaire du programme d’éducation pour les filles réfugiées',
    ),
  ];

  const _StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('1. Histoires inspirantes', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...stories.map((s) => _StoryTile(story: s)).toList(),
        ],
      ),
    );
  }
}

class _Story {
  final String author;
  final String text;
  const _Story({required this.author, required this.text});
}

class _StoryTile extends StatelessWidget {
  final _Story story;
  const _StoryTile({required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(story.author, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(story.text),
          ],
        ),
      ),
    );
  }
}

class _HealingThemesSection extends StatelessWidget {
  const _HealingThemesSection();

  @override
  Widget build(BuildContext context) {
    final themes = [
      ('🌿 Guérison émotionnelle', 'Trouver la paix intérieure grâce au soutien et à la parole.'),
      ('👭 Solidarité entre femmes', 'Rejoindre des groupes de parole et d’entraide.'),
      ('📖 Éducation et autonomie', 'Retrouver sa dignité grâce à la formation et à l’emploi.'),
      ('🧘 Spiritualité et foi', 'Retrouver confiance et sens à la vie.'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('2. Thèmes de guérison', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...themes.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.$1.split(' ').first),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(t.$2, style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('3. Carte des récits', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Center(
              child: Text('🗺️ Carte à venir'),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('La carte interactive arrive bientôt.')),
              ),
              icon: const Icon(Icons.map_outlined),
              label: const Text('Afficher la carte des témoignages'),
            ),
          )
        ],
      ),
    );
  }
}

class _ShareYourStorySection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController storyController;
  final bool anonymous;
  final ValueChanged<bool> onAnonymousChanged;
  final VoidCallback onSubmit;
  const _ShareYourStorySection({
    required this.nameController,
    required this.ageController,
    required this.storyController,
    required this.anonymous,
    required this.onAnonymousChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('4. Partagez votre histoire', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Prénom ou pseudonyme (optionnel)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Âge (optionnel)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: storyController,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Votre témoignage',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ajout d\'image à venir')), 
                ),
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Ajouter une image (optionnel)'),
              ),
              const Spacer(),
              Row(
                children: [
                  const Text('Publier anonymement'),
                  const SizedBox(width: 8),
                  Switch(value: anonymous, onChanged: onAnonymousChanged),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Envoyer mon témoignage'),
            ),
          )
        ],
      ),
    );
  }
}

class _EncouragementCard extends StatelessWidget {
  const _EncouragementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: const Text(
        '“Chaque histoire de survie est une lumière dans l’obscurité.\nVous êtes fort(e). Vous n’êtes pas seul(e).\nEt votre voix mérite d’être entendue.”',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
