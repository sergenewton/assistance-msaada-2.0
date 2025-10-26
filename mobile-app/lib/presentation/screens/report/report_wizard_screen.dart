import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import 'report_models.dart';

class ReportWizardScreen extends StatefulWidget {
  const ReportWizardScreen({super.key});

  @override
  State<ReportWizardScreen> createState() => _ReportWizardScreenState();
}

class _ReportWizardScreenState extends State<ReportWizardScreen> {
  int _step = 0; // 0..4
  ReportFormData _data = const ReportFormData();
  bool _submitting = false;

  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());

  void _safeExit() {
    // Quitter en sécurité: revenir à l'accueil immédiatement
    if (mounted) context.go(RouteConstants.home);
  }

  void _next() {
    if (_formKeys[_step].currentState?.validate() ?? true) {
      setState(() => _step = (_step + 1).clamp(0, 4));
    }
  }

  void _back() => setState(() => _step = (_step - 1).clamp(0, 4));

  Future<void> _submit() async {
    final valid = _formKeys[_step].currentState?.validate() ?? true;
    if (!valid) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _submitting = false);
    final n1 = (Random().nextInt(9000) + 1000).toString();
    final n2 = (Random().nextInt(9000) + 1000).toString();
    final tracking = 'VBG-$n1-$n2';

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Signalement envoyé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Merci pour votre courage. Votre dossier a été enregistré avec succès.',
            ),
            const SizedBox(height: 12),
            Text(
              'Numéro de suivi : #$tracking',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Conservez-le pour tout suivi ultérieur. Une équipe dédiée vous contactera en toute confidentialité selon vos préférences.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _safeExit,
            child: const Text('Quitter en sécurité'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(RouteConstants.home);
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        title: const Text('Formulaire de Signalement'),
        actions: [
          TextButton.icon(
            onPressed: _safeExit,
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            label: const Text('Quitter en sécurité', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _HeaderSubtitle(),
            _StepIndicator(current: _step, total: 5),
            const SizedBox(height: 8),
            Expanded(
              child: Form(
                key: _formKeys[_step],
                child: _buildStep(context),
              ),
            ),
            _BottomNav(
              step: _step,
              onBack: _back,
              onNext: _next,
              onSubmit: _submit,
              submitting: _submitting,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0:
        return _Step1Identification(
          data: _data,
          onChanged: (d) => setState(() => _data = d),
        );
      case 1:
        return _Step2PersonsAndIncident(
          data: _data,
          onChanged: (d) => setState(() => _data = d),
        );
      case 2:
        return _Step3Needs(
          data: _data,
          onChanged: (d) => setState(() => _data = d),
        );
      case 3:
        return _Step4EvidenceAndContact(
          data: _data,
          onChanged: (d) => setState(() => _data = d),
        );
      case 4:
        return _Step5Review(data: _data);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _HeaderSubtitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE8F5E8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('“Informer – Protéger – Soutenir”',
              style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF2E7D32))),
          SizedBox(height: 4),
          Text(
            'Toutes les informations sont traitées de manière strictement confidentielle et sécurisée.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= current;
          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF4CAF50) : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int step;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final Future<void> Function() onSubmit;
  final bool submitting;
  const _BottomNav({
    required this.step,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
    required this.submitting,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.white,
      child: Row(
        children: [
          if (step > 0)
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left),
              label: const Text('Retour'),
            ),
          const Spacer(),
          if (step < 4)
            FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
              label: const Text('Suivant'),
            )
          else
            FilledButton(
              onPressed: submitting ? null : onSubmit,
              child: submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Soumettre le signalement'),
            ),
        ],
      ),
    );
  }
}

// ------------------- Step 1 -------------------
class _Step1Identification extends StatelessWidget {
  final ReportFormData data;
  final ValueChanged<ReportFormData> onChanged;
  const _Step1Identification({required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Étape 1 : Identification du signalement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          const Text('Type de signalement'),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: RadioListTile<bool>(
                value: true,
                groupValue: data.anonymous,
                onChanged: (v) => onChanged(data.copyWith(anonymous: v)),
                title: const Text('Anonyme'),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                value: false,
                groupValue: data.anonymous,
                onChanged: (v) => onChanged(data.copyWith(anonymous: v)),
                title: const Text('Nominal'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          const Text('Votre rôle dans cette situation'),
          ...ReporterRole.values.map((r) => RadioListTile<ReporterRole>(
                value: r,
                groupValue: data.reporterRole,
                onChanged: (v) => onChanged(data.copyWith(reporterRole: v)),
                title: Text(_rLabel(r)),
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Text('Niveau d’urgence')),
              IconButton(
                tooltip: 'Aide',
                onPressed: () => _showUrgencyHelp(context),
                icon: const Icon(Icons.info_outline),
              )
            ],
          ),
          Wrap(
            spacing: 8,
            children: Urgency.values
                .map((u) => ChoiceChip(
                      label: Text(_uLabel(u)),
                      selected: data.urgency == u,
                      onSelected: (_) => onChanged(data.copyWith(urgency: u)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Type(s) de violence (multi-sélection)'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ViolenceType.values.map((t) {
              final selected = data.violenceTypes.contains(t);
              return FilterChip(
                label: Text(_vLabel(t)),
                selected: selected,
                onSelected: (_) {
                  final set = {...data.violenceTypes};
                  selected ? set.remove(t) : set.add(t);
                  onChanged(data.copyWith(violenceTypes: set));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showUrgencyHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            _HelpTile(title: 'Risque critique', body: 'Menaces de mort récentes, blessures graves, arme impliquée.'),
            _HelpTile(title: 'Risque élevé', body: 'Viol, enfants en danger, victime isolée sans soutien.'),
            _HelpTile(title: 'Risque modéré', body: 'Violence répétée/chronique, dépendance économique, auteur ayant accès au domicile.'),
            _HelpTile(title: 'Risque faible', body: 'Situation non urgente mais préoccupante.'),
          ],
        ),
      ),
    );
  }

  static String _rLabel(ReporterRole r) => switch (r) {
        ReporterRole.victim => 'Je suis la victime',
        ReporterRole.witness => 'Je suis témoin',
        ReporterRole.concerned => 'Je m’inquiète pour quelqu’un d’autre',
      };
  static String _uLabel(Urgency u) => switch (u) {
        Urgency.critical => 'Critique',
        Urgency.high => 'Élevé',
        Urgency.moderate => 'Modéré',
        Urgency.low => 'Faible',
      };
  static String _vLabel(ViolenceType t) => switch (t) {
        ViolenceType.physical => 'Physique',
        ViolenceType.sexual => 'Sexuelle',
        ViolenceType.psychological => 'Psychologique / morale',
        ViolenceType.economic => 'Économique',
        ViolenceType.forcedMarriage => 'Mariage forcé',
        ViolenceType.mgf => 'MGF',
        ViolenceType.other => 'Autre',
      };
}

class _HelpTile extends StatelessWidget {
  final String title;
  final String body;
  const _HelpTile({required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(body),
    );
  }
}

// ------------------- Step 2 -------------------
class _Step2PersonsAndIncident extends StatefulWidget {
  final ReportFormData data;
  final ValueChanged<ReportFormData> onChanged;
  const _Step2PersonsAndIncident({required this.data, required this.onChanged});
  @override
  State<_Step2PersonsAndIncident> createState() => _Step2PersonsAndIncidentState();
}

class _Step2PersonsAndIncidentState extends State<_Step2PersonsAndIncident> {
  final _reporterCtrl = TextEditingController();
  final _victimCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _communeCtrl = TextEditingController();
  final _quartierCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reporterCtrl.text = widget.data.reporterName ?? '';
    _victimCtrl.text = widget.data.victimName ?? '';
    _nationalityCtrl.text = widget.data.nationality ?? '';
    _provinceCtrl.text = widget.data.province ?? '';
    _communeCtrl.text = widget.data.commune ?? '';
    _quartierCtrl.text = widget.data.quartier ?? '';
    _descriptionCtrl.text = widget.data.descriptionText ?? '';
  }

  @override
  void dispose() {
    _reporterCtrl.dispose();
    _victimCtrl.dispose();
    _nationalityCtrl.dispose();
    _provinceCtrl.dispose();
    _communeCtrl.dispose();
    _quartierCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Étape 2 : Informations sur les personnes et l’incident',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (d.anonymous == false) ...[
            const Text('Votre nom complet'),
            TextFormField(
              controller: _reporterCtrl,
              decoration: const InputDecoration(hintText: 'Nom et prénom'),
              onChanged: (v) => widget.onChanged(d.copyWith(reporterName: v)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
          ],
          if (d.reporterRole != ReporterRole.victim) ...[
            const Text('Nom de la victime (si connu)'),
            TextFormField(
              controller: _victimCtrl,
              decoration: const InputDecoration(hintText: 'Nom de la victime (facultatif)'),
              onChanged: (v) => widget.onChanged(d.copyWith(victimName: v.isEmpty ? null : v)),
            ),
            const SizedBox(height: 12),
          ] else if (d.anonymous == false) ...[
            const Text('Votre nom (victime)'),
            TextFormField(
              controller: _victimCtrl,
              decoration: const InputDecoration(hintText: 'Nom et prénom'),
              onChanged: (v) => widget.onChanged(d.copyWith(victimName: v)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
          ],
          const Text('Âge de la victime'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: AgeGroup.values
                .map((a) => ChoiceChip(
                      label: Text(_ageLabel(a)),
                      selected: d.victimAgeGroup == a,
                      onSelected: (_) => widget.onChanged(d.copyWith(victimAgeGroup: a)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Sexe de la victime'),
          Row(children: [
            Expanded(child: RadioListTile<Sex>(value: Sex.female, groupValue: d.victimSex, onChanged: (v) => widget.onChanged(d.copyWith(victimSex: v)), title: const Text('Féminin'))),
            Expanded(child: RadioListTile<Sex>(value: Sex.male, groupValue: d.victimSex, onChanged: (v) => widget.onChanged(d.copyWith(victimSex: v)), title: const Text('Masculin'))),
          ]),
          const SizedBox(height: 12),
          const Text('Nationalité (facultatif)'),
          TextFormField(
            controller: _nationalityCtrl,
            onChanged: (v) => widget.onChanged(d.copyWith(nationality: v.isEmpty ? null : v)),
            decoration: const InputDecoration(hintText: 'Ex: RD Congo'),
          ),
          const SizedBox(height: 16),
          const Text('Informations sur l’incident'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: IncidentPlace.values
                .map((p) => ChoiceChip(
                      label: Text(_placeLabel(p)),
                      selected: d.incidentPlace == p,
                      onSelected: (_) => widget.onChanged(d.copyWith(incidentPlace: p)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _provinceCtrl,
                decoration: const InputDecoration(labelText: 'Province'),
                onChanged: (v) => widget.onChanged(d.copyWith(province: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _communeCtrl,
                decoration: const InputDecoration(labelText: 'Commune'),
                onChanged: (v) => widget.onChanged(d.copyWith(commune: v)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _quartierCtrl,
            decoration: const InputDecoration(labelText: 'Quartier'),
            onChanged: (v) => widget.onChanged(d.copyWith(quartier: v)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Description libre (écrite)',
              alignLabelWithHint: true,
            ),
            onChanged: (v) => widget.onChanged(d.copyWith(descriptionText: v)),
          ),
          const SizedBox(height: 8),
          Text(
            '💡 Vous pouvez enregistrer un message vocal si vous préférez ne pas écrire.' + (kIsWeb ? ' (enregistrement vocal non disponible sur le web dans cette version)' : ''),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  static String _ageLabel(AgeGroup a) => switch (a) {
        AgeGroup.a0_5 => '0–5',
        AgeGroup.a6_12 => '6–12',
        AgeGroup.a13_17 => '13–17',
        AgeGroup.a18_25 => '18–25',
        AgeGroup.a26_35 => '26–35',
        AgeGroup.a36_50 => '36–50',
        AgeGroup.a50plus => '50+',
      };
  static String _placeLabel(IncidentPlace p) => switch (p) {
        IncidentPlace.home => 'Domicile',
        IncidentPlace.work => 'Travail',
        IncidentPlace.publicSpace => 'Espace public',
        IncidentPlace.other => 'Autre',
      };
}

// ------------------- Step 3 -------------------
class _Step3Needs extends StatelessWidget {
  final ReportFormData data;
  final ValueChanged<ReportFormData> onChanged;
  const _Step3Needs({required this.data, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Étape 3 : Besoins exprimés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            data.reporterRole == ReporterRole.victim
                ? 'Quels types d’aide souhaitez-vous recevoir ?'
                : 'Quels types d’aide pensez-vous que la victime a besoin de recevoir ?',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NeedType.values.map((n) {
              final selected = data.needs.contains(n);
              return FilterChip(
                label: Text(_nLabel(n)),
                selected: selected,
                onSelected: (_) {
                  final set = {...data.needs};
                  selected ? set.remove(n) : set.add(n);
                  onChanged(data.copyWith(needs: set));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static String _nLabel(NeedType n) => switch (n) {
        NeedType.psychological => 'Écoute et soutien psychologique',
        NeedType.medical => 'Soins médicaux',
        NeedType.legal => 'Assistance juridique',
        NeedType.shelter => 'Hébergement d’urgence',
        NeedType.economic => 'Aide économique ou alimentaire',
        NeedType.policeProtection => 'Protection policière',
        NeedType.other => 'Autre',
      };
}

// ------------------- Step 4 -------------------
class _Step4EvidenceAndContact extends StatefulWidget {
  final ReportFormData data;
  final ValueChanged<ReportFormData> onChanged;
  const _Step4EvidenceAndContact({required this.data, required this.onChanged});
  @override
  State<_Step4EvidenceAndContact> createState() => _Step4EvidenceAndContactState();
}

class _Step4EvidenceAndContactState extends State<_Step4EvidenceAndContact> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.data.contactNumber ?? '';
    _codeCtrl.text = widget.data.securityCode ?? '';
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Étape 4 : Preuves et contact sécurisé',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          const Text('Preuves (optionnel)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  // TODO: Integrate FilePicker for photos (max 5)
                  final list = [...d.photoPaths];
                  if (list.length < 5) list.add('photo_${list.length + 1}.jpg');
                  widget.onChanged(d.copyWith(photoPaths: list));
                },
                icon: const Icon(Icons.image_outlined),
                label: Text('Photos (${d.photoPaths.length}/5)'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  // TODO: Integrate audio recording / picker (max 2 min)
                  widget.onChanged(d.copyWith(audioPath: d.audioPath ?? 'audio_note.m4a'));
                },
                icon: const Icon(Icons.mic_none),
                label: Text(d.audioPath == null ? 'Audio (optionnel)' : 'Audio ajouté'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final list = [...d.documentPaths];
                  list.add('document_${list.length + 1}.pdf');
                  widget.onChanged(d.copyWith(documentPaths: list));
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text('Documents (${d.documentPaths.length})'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final list = [...d.screenshotPaths];
                  list.add('capture_${list.length + 1}.png');
                  widget.onChanged(d.copyWith(screenshotPaths: list));
                },
                icon: const Icon(Icons.screenshot_monitor_outlined),
                label: Text('Captures (${d.screenshotPaths.length})'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Modalités de contact'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Numéro de contact'),
            onChanged: (v) => widget.onChanged(d.copyWith(contactNumber: v)),
          ),
          const SizedBox(height: 12),
          const Text('Préférence de contact'),
          Wrap(
            spacing: 8,
            children: ContactPref.values
                .map((c) => ChoiceChip(
                      label: Text(_cLabel(c)),
                      selected: d.contactPref == c,
                      onSelected: (_) => widget.onChanged(d.copyWith(contactPref: c)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Horaires préférés'),
          Wrap(
            spacing: 8,
            children: TimePref.values
                .map((t) => ChoiceChip(
                      label: Text(_tLabel(t)),
                      selected: d.timePref == t,
                      onSelected: (_) => widget.onChanged(d.copyWith(timePref: t)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Mot de code de sécurité (optionnel)'),
          TextFormField(
            controller: _codeCtrl,
            onChanged: (v) => widget.onChanged(d.copyWith(securityCode: v.isEmpty ? null : v)),
            decoration: const InputDecoration(hintText: 'Ex: Soleil'),
          ),
          const SizedBox(height: 8),
          const Text(
            '💡 Vous pouvez choisir de ne pas être contacté en sélectionnant “In-app” ou “Aucun”.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  static String _cLabel(ContactPref c) => switch (c) {
        ContactPref.sms => 'SMS',
        ContactPref.call => 'Appel',
        ContactPref.whatsapp => 'WhatsApp',
        ContactPref.inApp => 'In‑app',
        ContactPref.none => 'Aucun contact',
      };
  static String _tLabel(TimePref t) => switch (t) {
        TimePref.morning => 'Matin',
        TimePref.afternoon => 'Après‑midi',
        TimePref.evening => 'Soir',
      };
}

// ------------------- Step 5 -------------------
class _Step5Review extends StatelessWidget {
  final ReportFormData data;
  const _Step5Review({required this.data});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Étape 5 : Validation et soumission',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Vérifiez les informations (vous pouvez revenir aux étapes précédentes).'),
        const SizedBox(height: 16),
        _reviewTile('Signalement', data.anonymous == true ? 'Anonyme' : 'Nominal'),
        _reviewTile('Rôle', _roleToText(data.reporterRole)),
        _reviewTile('Urgence', _urgToText(data.urgency)),
        _reviewTile('Violences', data.violenceTypes.map(_violToText).join(', ')),
        const Divider(),
        _reviewTile('Victime', data.victimName ?? '—'),
        _reviewTile('Âge', _ageToText(data.victimAgeGroup)),
        _reviewTile('Sexe', _sexToText(data.victimSex)),
        _reviewTile('Nationalité', data.nationality ?? '—'),
        _reviewTile('Lieu', _placeToText(data.incidentPlace)),
        _reviewTile('Adresse', [data.province, data.commune, data.quartier].where((e) => (e ?? '').isNotEmpty).join(', ')),
        const Divider(),
        _reviewTile('Besoins', data.needs.isEmpty ? '—' : data.needs.map(_needToText).join(', ')),
        const Divider(),
        _reviewTile('Contact', data.contactNumber ?? '—'),
        _reviewTile('Préférence', _contactToText(data.contactPref)),
        _reviewTile('Horaire', _timeToText(data.timePref)),
      ],
    );
  }

  Widget _reviewTile(String title, String value) => ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value.isEmpty ? '—' : value),
      );

  String _roleToText(ReporterRole? r) => switch (r) {
        ReporterRole.victim => 'Victime',
        ReporterRole.witness => 'Témoin',
        ReporterRole.concerned => 'Personne inquiète',
        null => '—',
      };
  String _urgToText(Urgency? u) => switch (u) {
        Urgency.critical => 'Critique',
        Urgency.high => 'Élevé',
        Urgency.moderate => 'Modéré',
        Urgency.low => 'Faible',
        null => '—',
      };
  String _violToText(ViolenceType v) => _Step1Identification._vLabel(v);
  String _ageToText(AgeGroup? a) => _Step2PersonsAndIncidentState._ageLabel(a ?? AgeGroup.a18_25);
  String _sexToText(Sex? s) => switch (s) { Sex.female => 'Féminin', Sex.male => 'Masculin', null => '—' };
  String _placeToText(IncidentPlace? p) => _Step2PersonsAndIncidentState._placeLabel(p ?? IncidentPlace.home);
  String _needToText(NeedType n) => _Step3Needs._nLabel(n);
  String _contactToText(ContactPref c) => _Step4EvidenceAndContactState._cLabel(c);
  String _timeToText(TimePref? t) => t == null ? '—' : _Step4EvidenceAndContactState._tLabel(t);
}
