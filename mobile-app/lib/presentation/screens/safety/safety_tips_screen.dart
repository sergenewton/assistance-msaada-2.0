import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  Future<void> _callEmergency(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '112');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossible d'ouvrir l'application d'appel. Ouverture du formulaire de dénonciation.")),
          );
          context.push(RouteConstants.reportForm);
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la tentative d\'appel. Ouverture du formulaire.')),
        );
        context.push(RouteConstants.reportForm);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Conseils de sécurité'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(
                title: 'Protégez-vous et restez en sécurité',
                subtitle:
                    'La sécurité est une priorité. Ces conseils ont été conçus pour vous aider à prévenir les situations de danger, à réagir efficacement lorsqu’elles surviennent, et à vous protéger, vous et vos proches.',
              ),
              const SizedBox(height: 16),
              _Section(
                emoji: '⚠️',
                title: '1. Avant qu’un danger n’arrive',
                description: 'Prévenir vaut mieux que guérir. Quelques réflexes simples peuvent sauver des vies.',
                bullets: const [
                  ('🏠', 'Identifiez un lieu sûr : un ami, un parent, ou un centre d’accueil où vous pouvez aller en urgence.'),
                  ('📱', 'Ayez toujours un téléphone chargé et un contact d’urgence rapide à composer.'),
                  ('💼', 'Préparez un sac d’urgence avec vos documents importants, un peu d’argent, des clés, et des vêtements de rechange.'),
                  ('🤝', 'Informez une personne de confiance de votre situation si vous sentez une menace.'),
                  ('🔒', 'Mettez un mot de passe sur votre téléphone pour éviter l’accès non autorisé.'),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                emoji: '🚨',
                title: '2. En cas de danger immédiat',
                description: 'Si vous sentez que votre sécurité est menacée, agissez vite et avec prudence.',
                bullets: const [
                  ('🏃‍♀️', 'Éloignez-vous de la source du danger dès que possible.'),
                  ('☎️', 'Appelez un numéro d’urgence ou un proche de confiance.'),
                  ('🗣️', 'Si vous ne pouvez pas parler, envoyez un message codé ou un emoji de détresse à une personne qui connaît votre situation.'),
                  ('🚪', 'Cherchez un abri sûr : maison d’un voisin, commerce, commissariat, ou centre de santé.'),
                  ('⚡', 'Ne tentez pas de confronter directement l’agresseur si cela met votre vie en danger.'),
                ],
                trailing: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _callEmergency(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.sos),
                      label: const Text("Appeler à l’aide immédiatement"),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                emoji: '🧩',
                title: '3. Après une agression',
                description: 'Votre santé physique et mentale compte. Cherchez de l’aide le plus tôt possible.',
                bullets: const [
                  ('🏥', 'Rendez-vous dans un centre de santé pour recevoir les soins nécessaires.'),
                  ('👮', 'Signalez l’agression aux autorités ou via l’application Assistance Msaada.'),
                  ('🧾', 'Conservez les preuves (vêtements, messages, captures d’écran, photos).'),
                  ('💬', 'Parlez à un professionnel : psychologue, assistant social ou membre d’un centre d’écoute.'),
                  ('🫂', 'Ne restez pas seul(e) : demandez un accompagnement auprès d’une organisation locale.'),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                emoji: '🕊️',
                title: '4. En ligne : sécurité numérique',
                description: 'Votre téléphone et vos réseaux peuvent être utilisés contre vous. Protégez votre vie privée.',
                bullets: const [
                  ('🔐', 'Utilisez un mot de passe fort et différent pour chaque compte.'),
                  ('🚫', 'Ne partagez pas vos informations personnelles avec des inconnus en ligne.'),
                  ('📵', 'Évitez de publier votre position sur les réseaux sociaux.'),
                  ('🧹', 'Effacez l’historique des sites sensibles que vous visitez.'),
                  ('📁', 'Activez le mode discret dans l’application pour masquer vos activités sensibles.'),
                ],
              ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, color: Color(0xFF2196F3)),
              SizedBox(width: 8),
              Text('Conseils de sécurité', style: TextStyle(fontWeight: FontWeight.w700)),
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

class _Section extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final List<(String, String)> bullets;
  final Widget? trailing;
  const _Section({
    required this.emoji,
    required this.title,
    required this.description,
    required this.bullets,
    this.trailing,
    super.key,
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
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          ...bullets.map((b) => _BulletRow(emoji: b.$1, text: b.$2)).toList(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String emoji;
  final String text;
  const _BulletRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
