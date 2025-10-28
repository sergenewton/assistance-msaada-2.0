import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'Français';
  double _textScale = 1.0;
  bool _voiceOnly = false;
  bool _appLock = false;
  bool _emergencyAlerts = true;
  bool _newStories = true;
  bool _guidesUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Paramètres')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'Apparence et Accessibilité',
              children: [
                _TitledRow(
                  title: 'Mode d’affichage',
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.light, label: Text('Clair')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Sombre')),
                      ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
                    ],
                    selected: {_themeMode},
                    onSelectionChanged: (s) => setState(() => _themeMode = s.first),
                  ),
                ),
                const SizedBox(height: 12),
                _TitledRow(
                  title: "Langue de l’application",
                  child: DropdownButton<String>(
                    value: _language,
                    items: const [
                      DropdownMenuItem(value: 'Français', child: Text('🇫🇷 Français')),
                      DropdownMenuItem(value: 'English', child: Text('🇬🇧 English')),
                      DropdownMenuItem(value: 'Kiswahili', child: Text('🇰🇪 Kiswahili')),
                      DropdownMenuItem(value: 'Kirundi', child: Text('🇧🇮 Kirundi')),
                      DropdownMenuItem(value: 'Kinyarwanda', child: Text('Kinyarwanda')),
                      DropdownMenuItem(value: 'Lingala', child: Text('Lingala')),
                    ],
                    onChanged: (v) => setState(() => _language = v ?? _language),
                  ),
                ),
                const SizedBox(height: 12),
                _TitledRow(
                  title: 'Taille du texte',
                  child: Row(
                    children: [
                      const Icon(Icons.text_decrease),
                      Expanded(
                        child: Slider(
                          value: _textScale,
                          min: 0.9,
                          max: 1.4,
                          divisions: 5,
                          onChanged: (v) => setState(() => _textScale = v),
                        ),
                      ),
                      const Icon(Icons.text_increase),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: const Text('Mode “voix uniquement”'),
                  subtitle: const Text('Navigation vocale et lecture audio des textes'),
                  value: _voiceOnly,
                  onChanged: (v) => setState(() => _voiceOnly = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Sécurité et Confidentialité',
              children: [
                SwitchListTile(
                  title: const Text("Verrouillage de l’application"),
                  subtitle: const Text('Code PIN ou empreinte digitale'),
                  value: _appLock,
                  onChanged: (v) => setState(() => _appLock = v),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Mentions légales et confidentialité'),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Notifications et alertes',
              children: [
                SwitchListTile(
                  title: const Text('Alertes d’urgence'),
                  value: _emergencyAlerts,
                  onChanged: (v) => setState(() => _emergencyAlerts = v),
                ),
                SwitchListTile(
                  title: const Text('Nouveaux témoignages'),
                  value: _newStories,
                  onChanged: (v) => setState(() => _newStories = v),
                ),
                SwitchListTile(
                  title: const Text('Mises à jour des guides'),
                  value: _guidesUpdates,
                  onChanged: (v) => setState(() => _guidesUpdates = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Assistance et support',
              children: const [
                ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('Email'),
                  subtitle: Text('sergenewton@gmail.com'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'À propos de l’application',
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('2.0.1'),
                ),
                ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Développé par'),
                  subtitle: Text('CHENKCONSULTING – COCAFEM/GL'),
                ),
                ListTile(
                  leading: Icon(Icons.favorite_outline),
                  title: Text('Mission'),
                  subtitle: Text('Informer – Protéger – Soutenir.'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _TitledRow extends StatelessWidget {
  final String title;
  final Widget child;
  const _TitledRow({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
