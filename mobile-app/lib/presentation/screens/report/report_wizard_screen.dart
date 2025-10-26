import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
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
        title: const Text('DÉNONCER', style: TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.bold)),
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
            _StepperBar(current: _step, total: 5),
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

class _StepperBar extends StatelessWidget {
  final int current; // 0-based
  final int total;
  const _StepperBar({required this.current, required this.total});
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(total * 2 - 1, (i) {
          if (i.isOdd) {
            // connector
            final idx = (i - 1) ~/ 2;
            final active = idx < current;
            return Expanded(
              child: Container(
                height: 4,
                color: active ? green.withOpacity(0.7) : Colors.grey.shade300,
              ),
            );
          } else {
            final stepIndex = i ~/ 2; // 0..total-1
            final isActive = stepIndex == current;
            final isDone = stepIndex < current;
            final bg = isActive ? green : (isDone ? green.withOpacity(0.5) : Colors.white);
            final fg = isActive ? Colors.white : (isDone ? Colors.white : Colors.grey.shade600);
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: isActive || isDone ? green : Colors.grey.shade400),
              ),
              alignment: Alignment.center,
              child: Text('${stepIndex + 1}', style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
            );
          }
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
          const Text('Type de dénonciation'),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: _SelectTile(
                label: 'Anonyme',
                selected: data.anonymous == true,
                onTap: () => onChanged(data.copyWith(anonymous: true)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SelectTile(
                label: 'Nominal',
                selected: data.anonymous == false,
                onTap: () => onChanged(data.copyWith(anonymous: false)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          const Text('Vous dénoncez en tant que :'),
          const SizedBox(height: 6),
          _SelectTile(
            label: _rLabel(ReporterRole.victim),
            selected: data.reporterRole == ReporterRole.victim,
            onTap: () => onChanged(data.copyWith(reporterRole: ReporterRole.victim)),
          ),
          const SizedBox(height: 8),
          _SelectTile(
            label: _rLabel(ReporterRole.witness),
            selected: data.reporterRole == ReporterRole.witness,
            onTap: () => onChanged(data.copyWith(reporterRole: ReporterRole.witness)),
          ),
          const SizedBox(height: 8),
          _SelectTile(
            label: _rLabel(ReporterRole.concerned),
            selected: data.reporterRole == ReporterRole.concerned,
            onTap: () => onChanged(data.copyWith(reporterRole: ReporterRole.concerned)),
          ),
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
            spacing: 10,
            runSpacing: 10,
            children: Urgency.values
                .map((u) => _PillOption(
                      label: _uLabel(u),
                      selected: data.urgency == u,
                      onTap: () => onChanged(data.copyWith(urgency: u)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Type(s) de violence (multi-sélection)'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ViolenceType.values.map((t) {
              final selected = data.violenceTypes.contains(t);
              return _PillOption(
                label: _vLabel(t),
                selected: selected,
                onTap: () {
                  final set = {...data.violenceTypes};
                  selected ? set.remove(t) : set.add(t);
                  onChanged(data.copyWith(violenceTypes: set));
                },
                multi: true,
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
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Audio description (optional)
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderReady = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _reporterCtrl.text = widget.data.reporterName ?? '';
    _victimCtrl.text = widget.data.victimName ?? '';
    _addressCtrl.text = widget.data.addressLine ?? '';
    _descriptionCtrl.text = widget.data.descriptionText ?? '';

    _initRecorder();
  }

  @override
  void dispose() {
    _reporterCtrl.dispose();
    _victimCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    // Close recorder
    if (_recorderReady) {
      _recorder.closeRecorder();
    }
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
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: _SelectTile(
                label: 'Féminin',
                selected: d.victimSex == Sex.female,
                onTap: () => widget.onChanged(d.copyWith(victimSex: Sex.female)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SelectTile(
                label: 'Masculin',
                selected: d.victimSex == Sex.male,
                onTap: () => widget.onChanged(d.copyWith(victimSex: Sex.male)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          const Text('Adresse de l’incident (une ligne)'),
          TextFormField(
            controller: _addressCtrl,
            decoration: InputDecoration(
              labelText: 'Adresse',
              hintText: 'Saisissez l’adresse (ex: Avenue X, Commune Y)'.trim(),
              suffixIcon: Tooltip(
                message: 'Envoyer ma position',
                child: IconButton(
                  icon: const Icon(Icons.my_location_outlined),
                  onPressed: _onSendMyLocation,
                ),
              ),
            ),
            onChanged: (v) => widget.onChanged(d.copyWith(addressLine: v.isEmpty ? null : v)),
          ),
          if (d.latitude != null && d.longitude != null) ...[
            const SizedBox(height: 6),
            Text(
              'Position ajoutée: (${d.latitude!.toStringAsFixed(5)}, ${d.longitude!.toStringAsFixed(5)})',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
          const SizedBox(height: 12),
          const Text('Description de l’incident'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _descriptionCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Décrivez ce qui s’est passé (facultatif si audio ajouté)',
              alignLabelWithHint: true,
            ),
            onChanged: (v) => widget.onChanged(d.copyWith(descriptionText: v.isEmpty ? null : v)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: (!_recorderReady || kIsWeb) ? null : _toggleRecord,
                icon: Icon(_isRecording ? Icons.stop_circle_outlined : Icons.mic_none),
                label: Text(_isRecording ? 'Arrêter' : 'Enregistrer un audio'),
              ),
              const SizedBox(width: 12),
              if (d.descriptionAudioPath != null)
                const Text('Audio ajouté', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          if (kIsWeb)
            const Text(
              'ℹ️ L’enregistrement audio natif n’est pas activé sur le web dans cette version. Utilisez le texte.',
              style: TextStyle(color: Colors.grey),
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

  Future<void> _initRecorder() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          setState(() => _recorderReady = false);
          return;
        }
      }
      await _recorder.openRecorder();
      setState(() => _recorderReady = true);
    } catch (_) {
      setState(() => _recorderReady = false);
    }
  }

  Future<void> _toggleRecord() async {
    if (!_recorderReady) return;
    if (_isRecording) {
      final path = await _recorder.stopRecorder();
      setState(() => _isRecording = false);
      if (path != null && mounted) {
        final d = widget.data.copyWith(descriptionAudioPath: path);
        widget.onChanged(d);
      }
      return;
    }
    // Start recording
    try {
      await _recorder.startRecorder(toFile: 'desc_${DateTime.now().millisecondsSinceEpoch}.m4a');
      setState(() => _isRecording = true);
    } catch (_) {
      setState(() => _isRecording = false);
    }
  }

  Future<void> _onSendMyLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Silently ignore if disabled to keep it "hidden"/non-intrusive
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return; // user denied
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return; // cannot request
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (!mounted) return;
      final d = widget.data.copyWith(latitude: pos.latitude, longitude: pos.longitude);
      widget.onChanged(d);
      // Optionally provide a subtle feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Position ajoutée'), duration: Duration(seconds: 2)),
        );
      }
    } catch (_) {
      // ignore silently for now
    }
  }
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
            spacing: 10,
            runSpacing: 10,
            children: NeedType.values.map((n) {
              final selected = data.needs.contains(n);
              return _PillOption(
                label: _nLabel(n),
                selected: selected,
                onTap: () {
                  final set = {...data.needs};
                  selected ? set.remove(n) : set.add(n);
                  onChanged(data.copyWith(needs: set));
                },
                multi: true,
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
            spacing: 10,
            runSpacing: 10,
            children: ContactPref.values
                .map((c) => _PillOption(
                      label: _cLabel(c),
                      selected: d.contactPref == c,
                      onTap: () => widget.onChanged(d.copyWith(contactPref: c)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Horaires préférés'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: TimePref.values
                .map((t) => _PillOption(
                      label: _tLabel(t),
                      selected: d.timePref == t,
                      onTap: () => widget.onChanged(d.copyWith(timePref: t)),
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
        _reviewTile('Adresse', data.addressLine ?? '—'),
        if (data.latitude != null && data.longitude != null)
          _reviewTile('Position GPS',
              'Lat ${data.latitude!.toStringAsFixed(5)}, Lng ${data.longitude!.toStringAsFixed(5)}'),
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
  String _needToText(NeedType n) => _Step3Needs._nLabel(n);
  String _contactToText(ContactPref c) => _Step4EvidenceAndContactState._cLabel(c);
  String _timeToText(TimePref? t) => t == null ? '—' : _Step4EvidenceAndContactState._tLabel(t);
}

// ------------------- Reusable styled widgets -------------------
class _SelectTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SelectTile({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F5E8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? green : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xFF2E7D32) : Colors.black87,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? green : Colors.transparent,
                border: Border.all(color: selected ? green : Colors.grey.shade400),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool multi;
  const _PillOption({required this.label, required this.selected, required this.onTap, this.multi = false});
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    final bg = selected ? const Color(0xFFE8F5E8) : Colors.white;
    final border = selected ? green : Colors.grey.shade300;
    final textColor = selected ? const Color(0xFF2E7D32) : Colors.black87;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (multi)
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: selected ? green : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: selected ? green : Colors.grey.shade400),
                ),
                child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
