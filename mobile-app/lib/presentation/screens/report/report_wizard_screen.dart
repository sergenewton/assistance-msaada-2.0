import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/route_constants.dart';
import 'report_models.dart';
import '../../../features/reports/wizard/report_submission_service.dart';
import '../../../core/error/exceptions.dart';

class ReportWizardScreen extends StatefulWidget {
  const ReportWizardScreen({super.key});

  @override
  State<ReportWizardScreen> createState() => _ReportWizardScreenState();
}

class _ReportWizardScreenState extends State<ReportWizardScreen> {
  int _step = 0; // 0..4
  ReportFormData _data = const ReportFormData(
    anonymous: false,
    reporterRole: ReporterRole.witness,
    urgency: Urgency.moderate,
    violenceTypes: {ViolenceType.sexualAssault},
    victimAgeGroup: AgeGroup.a13_17,
    victimSex: Sex.female,
    isSafeNow: true,
    childrenAtRisk: false,
    deathThreats: false,
    needs: {NeedType.psychological},
    contactPrefs: {ContactPref.sms, ContactPref.call},
    timePref: TimePref.morning,
  );
  bool _submitting = false;

  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());

  void _safeExit() {
    if (mounted) context.go(RouteConstants.home);
  }

  void _next() {
    final error = _validateStepData(_step, _data);
    _formKeys[_step].currentState?.validate();
    if (error != null) {
      _showStepError(error);
      return;
    }
    setState(() => _step = (_step + 1).clamp(0, 4));
  }

  void _back() => setState(() => _step = (_step - 1).clamp(0, 4));

  Future<void> _submit() async {
    for (int i = 0; i < 4; i++) {
      final err = _validateStepData(i, _data);
      if (err != null) {
        setState(() => _step = i);
        _formKeys[i].currentState?.validate();
        _showStepError(err);
        return;
      }
    }
    setState(() => _submitting = true);
    try {
      final tracking = await submitWizardReport(_data);
      if (!mounted) return;
      context.go('${RouteConstants.reportSuccess}?tracking=$tracking');
    } on AuthenticationException catch (e) {
      _showStepError(e.message);
    } on ValidationException catch (e) {
      _showStepError(e.message);
    } on ServerException catch (e) {
      _showStepError(e.message);
    } on NetworkException catch (e) {
      _showStepError(e.message);
    } catch (_) {
      _showStepError('Une erreur est survenue lors de la soumission. Veuillez réessayer.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showStepError(String message) {
    final sb = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(sb);
  }

  // Règles de validation par étape
  String? _validateStepData(int step, ReportFormData d) {
    switch (step) {
      case 0:
        if (d.anonymous == null) return 'Veuillez choisir Anonyme ou Nominal.';
        if (d.reporterRole == null) return 'Veuillez indiquer votre rôle.';
        if (d.violenceTypes.isEmpty) return 'Veuillez sélectionner au moins un type de violence.';
        return null;
      case 1:
        if (d.victimAgeGroup == null) return 'Veuillez indiquer l’âge de la victime.';
        if (d.victimSex == null) return 'Veuillez indiquer le sexe de la victime.';
        if (d.needsUrgentMedical == null) return 'Veuillez préciser si la victime a besoin d’une urgence médicale.';

        return null;
      case 2:
        if (d.addressLine == null || d.addressLine!.trim().isEmpty) {
          return 'Veuillez saisir l’adresse de l’incident.';
        }
        if (d.contactNumber == null || d.contactNumber!.trim().isEmpty) {
          return 'Veuillez fournir un numéro de contact.';
        }
        if (d.contactPrefs.isEmpty) return 'Veuillez choisir au moins une préférence de contact.';
        if (d.timePref == null) return 'Veuillez choisir un horaire préféré.';
        return null;
      case 3:
        return null;
      default:
        return null;
    }
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
            final idx = (i - 1) ~/ 2;
            final active = idx < current;
            return Expanded(
              child: Container(
                height: 4,
                color: active ? green.withValues(alpha: 0.7) : Colors.grey.shade300,
              ),
            );
          } else {
            final stepIndex = i ~/ 2; // 0..total-1
            final isActive = stepIndex == current;
            final isDone = stepIndex < current;
            final bg = isActive ? green : (isDone ? green.withValues(alpha: 0.5) : Colors.white);
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
          const SizedBox(height: 12),
          const Text('Type(s) de violence (multi-sélection)'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kAllowedViolenceTypes.map((t) {
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
        ViolenceType.rape => 'Viol',
        ViolenceType.sexualAssault => 'Agression sexuelle',
        ViolenceType.sexualHarassment => 'Harcèlement sexuel',
        ViolenceType.sexualExploitation => 'Exploitation sexuelle',
        ViolenceType.forcedMarriage => 'Mariage forcé',
        ViolenceType.femaleGenitalMutilation => 'Mutilations génitales',
        ViolenceType.incest => 'Inceste',
        ViolenceType.sextortion => 'Chantage sexuel',
        ViolenceType.physicalAssault => 'Agression physique',
        ViolenceType.denialResources => 'Déni de ressources',
        ViolenceType.psychologicalViolence => 'Violence psychologique',
        ViolenceType.sexualSlavery => 'L’esclavage sexuel',
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

  bool _knowsVictimName = false;

  @override
  void initState() {
    super.initState();
    _reporterCtrl.text = widget.data.reporterName ?? '';
    _victimCtrl.text = widget.data.victimName ?? '';
    _knowsVictimName =
        (widget.data.victimName != null && widget.data.victimName!.trim().isNotEmpty);
  }

  @override
  void dispose() {
    _reporterCtrl.dispose();
    _victimCtrl.dispose();
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
            if (d.reporterRole == ReporterRole.victim) ...[
              TextFormField(
                controller: _reporterCtrl,
                decoration: const InputDecoration(
                  labelText: 'Votre nom complet',
                  hintText: 'ex: Furaha Kamara',
                ),
                onChanged: (v) {
                  final value = v.isEmpty ? null : v;
                  widget.onChanged(d.copyWith(reporterName: value, victimName: value));
                  if (_victimCtrl.text != v) _victimCtrl.text = v;
                },
              ),
              const SizedBox(height: 12),
            ] else ...[
              TextFormField(
                controller: _reporterCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom du dénonciateur',
                  hintText: 'ex: Barna Diakité',
                ),
                onChanged: (v) => widget.onChanged(d.copyWith(reporterName: v.isEmpty ? null : v)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _victimCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom de la victime',
                  hintText: 'ex: Marie Durant',
                ),
                onChanged: (v) => widget.onChanged(d.copyWith(victimName: v.isEmpty ? null : v)),
              ),
              const SizedBox(height: 12),
            ],
          ] else ...[
            if (d.reporterRole == ReporterRole.victim) ...[
              const SizedBox.shrink(),
            ] else ...[
              const Text('Connaissez-vous le nom de la victime ?'),
              const SizedBox(height: 6),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Oui'),
                    selected: _knowsVictimName,
                    onSelected: (_) => setState(() => _knowsVictimName = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Non'),
                    selected: !_knowsVictimName,
                    onSelected: (_) {
                      setState(() => _knowsVictimName = false);
                      widget.onChanged(d.copyWith(victimName: null));
                      if (_victimCtrl.text.isNotEmpty) _victimCtrl.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_knowsVictimName) ...[
                TextFormField(
                  controller: _victimCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la victime',
                    hintText: 'ex: Marie Durant',
                  ),
                  onChanged: (v) => widget.onChanged(d.copyWith(victimName: v.isEmpty ? null : v)),
                ),
                const SizedBox(height: 12),
              ],
            ],
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

          const Text('Indicateurs de sécurité'),
          const SizedBox(height: 6),
          const Text('La situation est-elle sûre maintenant ?'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _SelectTile(
                  label: 'Oui',
                  selected: d.isSafeNow == true,
                  onTap: () => widget.onChanged(d.copyWith(isSafeNow: true)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectTile(
                  label: 'Non',
                  selected: d.isSafeNow == false,
                  onTap: () => widget.onChanged(d.copyWith(isSafeNow: false)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Des enfants sont-ils en danger ?'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _SelectTile(
                  label: 'Oui',
                  selected: d.childrenAtRisk == true,
                  onTap: () => widget.onChanged(d.copyWith(childrenAtRisk: true)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectTile(
                  label: 'Non',
                  selected: d.childrenAtRisk == false,
                  onTap: () => widget.onChanged(d.copyWith(childrenAtRisk: false)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Y a-t-il des menaces de mort ?'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _SelectTile(
                  label: 'Oui',
                  selected: d.deathThreats == true,
                  onTap: () => widget.onChanged(d.copyWith(deathThreats: true)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectTile(
                  label: 'Non',
                  selected: d.deathThreats == false,
                  onTap: () => widget.onChanged(d.copyWith(deathThreats: false)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('La victime a-t-elle besoin d’une urgence médicale ?'),
const SizedBox(height: 6),
Row(
  children: [
    Expanded(
      child: _SelectTile(
        label: 'Oui',
        selected: d.needsUrgentMedical == true,
        onTap: () => widget.onChanged(d.copyWith(needsUrgentMedical: true)),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _SelectTile(
        label: 'Non',
        selected: d.needsUrgentMedical == false,
        onTap: () => widget.onChanged(d.copyWith(needsUrgentMedical: false)),
      ),
    ),
  ],
),
const SizedBox(height: 12),


          const Text('Lien avec l’auteur'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Relation.familyMember,
              Relation.employer,
              Relation.colleague,
              Relation.teacher,
              Relation.authority,
              Relation.religiousLeader,
              Relation.neighbor,
              Relation.stranger,
              Relation.partner,
              Relation.parent,
            ].map((rel) {
              final selected = d.relation == rel;
              return _PillOption(
                label: _relLabel(rel),
                selected: selected,
                onTap: () => widget.onChanged(d.copyWith(relation: rel)),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
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

  static String _relLabel(Relation r) => switch (r) {
        Relation.familyMember => 'Membre de la famille',
        Relation.employer => 'Employeur',
        Relation.colleague => 'Collègue',
        Relation.teacher => 'Enseignant',
        Relation.authority => 'Autorité publique',
        Relation.religiousLeader => 'Chef religieux',
        Relation.neighbor => 'Voisin',
        Relation.stranger => 'Inconnu',
        Relation.partner => 'Partenaire intime',
        Relation.parent => 'Parent',
        Relation.unknown => 'Non précisé',
        Relation.other => 'Autre',
      };
}

// ------------------- Step 3 -------------------
class _Step3Needs extends StatefulWidget {
  final ReportFormData data;
  final ValueChanged<ReportFormData> onChanged;
  const _Step3Needs({required this.data, required this.onChanged});
  static String _nLabel(NeedType n) => switch (n) {
        NeedType.psychological => 'Écoute et soutien psychologique',
        NeedType.medical => 'Soins médicaux',
        NeedType.legal => 'Assistance juridique',
        NeedType.shelter => 'Hébergement d’urgence',
        NeedType.economic => 'Aide économique ou alimentaire',
        NeedType.policeProtection => 'Protection policière',
        NeedType.other => 'Autre',
      };
  @override
  State<_Step3Needs> createState() => _Step3NeedsState();
}

class _Step3NeedsState extends State<_Step3Needs> {
  final _addressCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _communeCtrl = TextEditingController();
  final _quartierCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _gpsSuccess = false;
  String? _gpsErrorMessage;

  @override
  void initState() {
    super.initState();
    _addressCtrl.text = widget.data.addressLine ?? '';
    _provinceCtrl.text = widget.data.locationProvince ?? '';
    _communeCtrl.text = widget.data.locationCommune ?? '';
    _quartierCtrl.text = widget.data.locationQuartier ?? '';
    _phoneCtrl.text = widget.data.contactNumber ?? '';
    _codeCtrl.text = widget.data.securityCode ?? '';
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _provinceCtrl.dispose();
    _communeCtrl.dispose();
    _quartierCtrl.dispose();
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
          const Text('Étape 3 : Localisation et Contacts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          const Text('Informations de localisation', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              labelText: 'Adresse de l’incident',
              hintText: 'ex: 123 Rue Principale, avenue des Fleurs, Ville',
            ),
            onChanged: (v) => widget.onChanged(d.copyWith(addressLine: v.isEmpty ? null : v)),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _provinceCtrl,
            decoration: const InputDecoration(labelText: 'Province'),
            onChanged: (v) => widget.onChanged(d.copyWith(locationProvince: v.isEmpty ? null : v)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _communeCtrl,
            decoration: const InputDecoration(labelText: 'Commune'),
            onChanged: (v) => widget.onChanged(d.copyWith(locationCommune: v.isEmpty ? null : v)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _quartierCtrl,
            decoration: const InputDecoration(labelText: 'Quartier'),
            onChanged: (v) => widget.onChanged(d.copyWith(locationQuartier: v.isEmpty ? null : v)),
          ),
          const SizedBox(height: 16),
          const Text('Localisation GPS', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _onSendMyLocation,
            icon: const Icon(Icons.my_location_outlined),
            label: const Text('Récupérer ma position'),
          ),
          if (_gpsErrorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _gpsErrorMessage!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          if (_gpsSuccess && widget.data.latitude != null && widget.data.longitude != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 18),
                  SizedBox(width: 6, child: Container()),
                  Text(
                    'Coordonnées récupérées: Lat ${widget.data.latitude!.toStringAsFixed(5)}, Lng ${widget.data.longitude!.toStringAsFixed(5)}',
                    style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Text('Contacts', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Numéro de contact',
              hintText: 'Ex: +243 99 123 45 67',
            ),
            onChanged: (v) => widget.onChanged(d.copyWith(contactNumber: v)),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Mot de code de sécurité', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              _optionalBadge(),
            ],
          ),
          TextFormField(
            controller: _codeCtrl,
            onChanged: (v) => widget.onChanged(d.copyWith(securityCode: v.isEmpty ? null : v)),
            decoration: const InputDecoration(hintText: 'Ex: Soleil'),
          ),
          const SizedBox(height: 12),
          const Text('Préférences de contact (multi-sélection)'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ContactPref.values.map((c) {
              final selected = d.contactPrefs.contains(c);
              return _PillOption(
                label: _Step4EvidenceAndContactState._cLabel(c),
                selected: selected,
                onTap: () {
                  final set = {...d.contactPrefs};
                  selected ? set.remove(c) : set.add(c);
                  widget.onChanged(d.copyWith(contactPrefs: set));
                },
                multi: true,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text('Horaires préférés'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: TimePref.values
                .map((t) => _PillOption(
                      label: _Step4EvidenceAndContactState._tLabel(t),
                      selected: d.timePref == t,
                      onTap: () => widget.onChanged(d.copyWith(timePref: t)),
                    ))
                .toList(),
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

  Future<void> _onSendMyLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _gpsSuccess = false;
          _gpsErrorMessage = 'Service de localisation désactivé. Veuillez l’activer dans les réglages.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _gpsSuccess = false;
            _gpsErrorMessage = 'Permission de localisation refusée.';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _gpsSuccess = false;
          _gpsErrorMessage =
              'Permission refusée définitivement. Autorisez la localisation dans les réglages du système.';
        });
        return;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }
      if (pos == null) {
        setState(() {
          _gpsSuccess = false;
          _gpsErrorMessage = 'Impossible d’obtenir la position (délai dépassé ou aucune position connue).';
        });
        return;
      }
      if (!mounted) return;
      final updated = widget.data.copyWith(latitude: pos.latitude, longitude: pos.longitude);
      widget.onChanged(updated);
      setState(() {
        _gpsSuccess = true;
        _gpsErrorMessage = null;
      });
    } catch (_) {
      setState(() {
        _gpsSuccess = false;
        _gpsErrorMessage = 'Une erreur est survenue lors de la récupération de la position.';
      });
    }
  }
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
  final ImagePicker _picker = ImagePicker();
  final _descriptionCtrl = TextEditingController();

  // Audio description (optional): record + play
  final AudioRecorder _recorder = AudioRecorder();
  bool _recorderReady = false;
  bool _isRecording = false;
  int _secondsLeft = 0;
  Timer? _timer;

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _playerReady = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _descriptionCtrl.text = widget.data.descriptionText ?? '';
    _initRecorder();
    _initPlayer();
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _recorder.dispose();
    if (_playerReady) {
      _player.closePlayer();
    }
    _timer?.cancel();
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
          const Text('Étape 4 : Description et Preuves (Optionnel)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                      label: _Step1Identification._uLabel(u),
                      selected: d.urgency == u,
                      onTap: () => widget.onChanged(d.copyWith(urgency: u)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Description de l’incident'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _descriptionCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Décrivez brièvement ce qui s’est passé',
            ),
            onChanged: (v) => widget.onChanged(d.copyWith(descriptionText: v.isEmpty ? null : v)),
          ),
          const SizedBox(height: 8),
          _buildAudioControls(d),
          const SizedBox(height: 6),
          if (kIsWeb)
            const Text(
              'ℹ️ L’enregistrement audio natif n’est pas activé sur le web dans cette version. Utilisez le texte.',
              style: TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 12),
          const Text('Besoin d’aide'),
          const SizedBox(height: 6),
          Text(
            d.reporterRole == ReporterRole.victim
                ? 'Quels types d’assistance souhaitez-vous recevoir ?'
                : 'Quels types d’assistance pensez-vous que la victime a besoin de recevoir ?',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: NeedType.values.map((n) {
              final selected = d.needs.contains(n);
              return _PillOption(
                label: _Step3Needs._nLabel(n),
                selected: selected,
                onTap: () {
                  final set = {...d.needs};
                  selected ? set.remove(n) : set.add(n);
                  widget.onChanged(d.copyWith(needs: set));
                },
                multi: true,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Preuves', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              _optionalBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  await _showPhotoSourcePicker(context, d);
                },
                icon: const Icon(Icons.image_outlined),
                label: Text('Photos (${d.photoPaths.length}/5)'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  if (d.audioPath != null) return; // single audio max
                  final res = await FilePicker.platform.pickFiles(
                    type: FileType.audio,
                    allowMultiple: false,
                  );
                  if (res == null || res.files.isEmpty) return;
                  final path = res.files.single.path ?? res.files.single.name;
                  widget.onChanged(d.copyWith(audioPath: path));
                },
                icon: const Icon(Icons.mic_none),
                label: Text(d.audioPath == null ? 'Ou Importer un audio' : 'Audio attaché'),
              ),
            ],
          ),
          if (d.photoPaths.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Photos sélectionnées'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: d.photoPaths.asMap().entries.map((e) {
                return _PhotoThumb(
                  path: e.value,
                  onRemove: () {
                    final list = [...d.photoPaths];
                    list.removeAt(e.key);
                    widget.onChanged(d.copyWith(photoPaths: list));
                  },
                );
              }).toList(),
            ),
          ],
          if (d.audioPath != null) ...[
            const SizedBox(height: 8),
            const Text('Audio attaché'),
            const SizedBox(height: 4),
            _fileRow(_pathBaseName(d.audioPath!),
                onRemove: () => widget.onChanged(d.copyWith(audioPath: null))),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _initRecorder() async {
    try {
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        setState(() => _recorderReady = false);
        return;
      }
      setState(() => _recorderReady = true);
    } catch (_) {
      setState(() => _recorderReady = false);
    }
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

  Future<void> _initPlayer() async {
    try {
      await _player.openPlayer();
      setState(() => _playerReady = true);
    } catch (_) {
      setState(() => _playerReady = false);
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 180);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_secondsLeft <= 1) {
        t.cancel();
        await _stopRecording(save: true);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(1, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  Future<String> _getTempFilePath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/desc_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  Future<void> _startRecording() async {
    if (!_recorderReady) return;
    try {
      final path = await _getTempFilePath();
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      setState(() => _isRecording = true);
      _startCountdown();
    } catch (_) {
      setState(() => _isRecording = false);
    }
  }

  Future<void> _stopRecording({bool save = true}) async {
    if (!_recorderReady) return;
    try {
      final path = await _recorder.stop();
      _timer?.cancel();
      setState(() => _isRecording = false);
      if (save && path != null && mounted) {
        widget.onChanged(widget.data.copyWith(descriptionAudioPath: path));
      }
    } catch (_) {
      setState(() => _isRecording = false);
    }
  }

  Future<void> _togglePlay() async {
    if (!_playerReady) return;
    if (_isPlaying) {
      await _player.stopPlayer();
      setState(() => _isPlaying = false);
      return;
    }
    final path = widget.data.descriptionAudioPath;
    if (path == null) return;
    await _player.startPlayer(fromURI: path, whenFinished: () {
      if (mounted) setState(() => _isPlaying = false);
    });
    setState(() => _isPlaying = true);
  }

  void _deleteAudio() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _secondsLeft = 0;
      _isPlaying = false;
    });
    widget.onChanged(widget.data.copyWith(descriptionAudioPath: null));
  }

  Widget _buildAudioControls(ReportFormData d) {
    final hasAudio = d.descriptionAudioPath != null;
    return Row(
      children: [
        InkWell(
          onTap: () async {
            if (_isRecording) {
              await _stopRecording(save: true);
            } else {
              await _startRecording();
            }
          },
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _isRecording ? Colors.orange : Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                if (_isRecording)
                  const BoxShadow(color: Colors.orangeAccent, blurRadius: 8, spreadRadius: 2),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isRecording
                    ? 'Enregistrement en cours…'
                    : (hasAudio
                        ? 'Un message audio est enregistré'
                        : 'Ou enregistrer la description sous forme de message audio ?'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (_isRecording)
                Text(
                  _fmt(_secondsLeft),
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (hasAudio)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _togglePlay,
                icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                tooltip: _isPlaying ? 'Stop' : 'Lire',
              ),
              IconButton(
                onPressed: _deleteAudio,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Supprimer',
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _showPhotoSourcePicker(BuildContext context, ReportFormData d) async {
    final remaining = 5 - d.photoPaths.length;
    if (remaining <= 0) return;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Appareil photo'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final XFile? shot = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (shot != null) {
                    final list = [...d.photoPaths, shot.path];
                    widget.onChanged(d.copyWith(photoPaths: list.take(5).toList()));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 85);
                  if (picked.isEmpty) return;
                  final add = picked.take(remaining).map((x) => x.path).toList();
                  widget.onChanged(d.copyWith(photoPaths: [...d.photoPaths, ...add]));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String _cLabel(ContactPref c) => switch (c) {
        ContactPref.sms => 'SMS',
        ContactPref.call => 'Appel',
        ContactPref.whatsapp => 'WhatsApp',
        ContactPref.inApp => 'In-app',
        ContactPref.none => 'Aucun contact',
      };
  static String _tLabel(TimePref t) => switch (t) {
        TimePref.morning => 'Matin',
        TimePref.afternoon => 'Après-midi',
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
        _reviewTile('Signalement', _vOrNone(data.anonymous == true ? 'Anonyme' : 'Nominal')),
        _reviewTile('Rôle', _vOrNone(_roleToText(data.reporterRole))),
        _reviewTile('Urgence', _vOrNone(_urgToText(data.urgency))),
        _reviewTile('Violences',
            data.violenceTypes.isEmpty ? _none() : data.violenceTypes.map(_violToText).join(', ')),
        const Divider(),
        _reviewTile('Nom du déclarant', _vOrNone(data.reporterName)),
        _reviewTile('Nom de la victime', _vOrNone(data.victimName)),
        _reviewTile('Âge', _vOrNone(_ageToText(data.victimAgeGroup))),
        _reviewTile('Sexe', _vOrNone(_sexToText(data.victimSex))),
        _reviewTile('Date de l’incident', _vOrNone(_fmtDate(data.incidentDate))),
        _reviewTile('Adresse', _vOrNone(data.addressLine)),
        _reviewTile('Province', _vOrNone(data.locationProvince)),
        _reviewTile('Commune', _vOrNone(data.locationCommune)),
        _reviewTile('Quartier', _vOrNone(data.locationQuartier)),
        _reviewTile(
          'Position GPS',
          (data.latitude != null && data.longitude != null)
              ? 'Lat ${data.latitude!.toStringAsFixed(5)}, Lng ${data.longitude!.toStringAsFixed(5)}'
              : _none(),
        ),
        _reviewTile('Fréquence', _vOrNone(_freqToText(data.frequency))),
        _reviewTile('Relation', _vOrNone(_relToText(data.relation))),
        _reviewTile('Sûr maintenant', _vOrNone(_boolToOuiNon(data.isSafeNow))),
        _reviewTile('Enfants en danger', _vOrNone(_boolToOuiNon(data.childrenAtRisk))),
        _reviewTile('Menaces de mort', _vOrNone(_boolToOuiNon(data.deathThreats))),
        _reviewTile('Description (texte)', _vOrNone(data.descriptionText)),
        _reviewTile('Message audio (description)', data.descriptionAudioPath != null ? 'Ajouté' : _none()),
        const Divider(),
        _reviewTile('Besoins', data.needs.isEmpty ? _none() : data.needs.map(_needToText).join(', ')),
        _reviewTile('Besoin d’urgence médicale', _vOrNone(_boolToOuiNon(data.needsUrgentMedical))),
        const Divider(),
        _reviewTile('Contact', _vOrNone(data.contactNumber)),
        _reviewTile(
          'Préférences',
          data.contactPrefs.isEmpty ? _none() : data.contactPrefs.map(_contactToText).join(', '),
        ),
        _reviewTile('Horaire', _vOrNone(_timeToText(data.timePref))),
        _reviewTile('Mot de code', _vOrNone(data.securityCode)),
        const Divider(),
        _reviewTile(
          'Photos',
          data.photoPaths.isEmpty
              ? _none()
              : '${data.photoPaths.length} sélectionnée(s)\n${data.photoPaths.map(_basename).join('\n')}',
        ),
        if (data.photoPaths.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.photoPaths.map((p) => _PhotoThumb(path: p)).toList(),
          ),
        ],
        _reviewTile('Audio attaché (preuve)', data.audioPath != null ? _basename(data.audioPath!) : _none()),
        if (data.documentPaths.isNotEmpty)
          _reviewTile('Documents', data.documentPaths.map(_basename).join('\n')),
        if (data.screenshotPaths.isNotEmpty)
          _reviewTile('Captures', data.screenshotPaths.map(_basename).join('\n')),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Important', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 6),
              Text(
                'Je confirme que les informations fournies sont exactes et je suis prêt(e) à envoyer ce signalement.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewTile(String title, String value) => ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value.isEmpty ? _none() : value),
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
  String _freqToText(Frequency? f) => switch (f) {
        Frequency.first => 'Première fois',
        Frequency.repeated => 'Répétée',
        Frequency.chronic => 'Chronique',
        null => '—',
      };
  String _relToText(Relation? r) => switch (r) {
        Relation.familyMember => 'Membre de la famille',
        Relation.employer => 'Employeur',
        Relation.colleague => 'Collègue',
        Relation.teacher => 'Enseignant',
        Relation.authority => 'Autorité publique',
        Relation.religiousLeader => 'Chef religieux',
        Relation.neighbor => 'Voisin',
        Relation.stranger => 'Inconnu',
        Relation.partner => 'Partenaire intime',
        Relation.parent => 'Parent',
        Relation.unknown => 'Non précisé',
        Relation.other => 'Autre',
        null => '—',
      };
  String _boolToOuiNon(bool? v) => v == null ? '—' : (v ? 'Oui' : 'Non');
  String _fmtDate(DateTime? d) =>
      d == null ? '—' : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  String _basename(String p) {
    final parts = p.split(RegExp(r'[\\/]'));
    return parts.isNotEmpty ? parts.last : p;
  }
  String _none() => 'Aucun élément saisi';
  String _vOrNone(String? v) => (v == null || v.trim().isEmpty || v == '—') ? _none() : v;
}

// Row helper
Widget _fileRow(String name, {VoidCallback? onRemove}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        const Icon(Icons.insert_drive_file_outlined, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
        if (onRemove != null)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Retirer',
            onPressed: onRemove,
          ),
      ],
    ),
  );
}

String _pathBaseName(String p) {
  final parts = p.split(RegExp(r'[\\/]'));
  return parts.isNotEmpty ? parts.last : p;
}

Widget _optionalBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: const Text(
      '(optionnel)',
      style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
    ),
  );
}

class _PhotoThumb extends StatelessWidget {
  final String path;
  final VoidCallback? onRemove;
  const _PhotoThumb({required this.path, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FutureBuilder<Uint8List>(
              future: XFile(path).readAsBytes(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                if (!snap.hasData || snap.hasError) {
                  return const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey));
                }
                return Image.memory(snap.data!, fit: BoxFit.cover);
              },
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: -6,
            right: -6,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
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
              child: selected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- Success screen -------------------
class SubmissionSuccessScreen extends StatelessWidget {
  final String trackingNumber;
  final VoidCallback onExit;
  const SubmissionSuccessScreen({super.key, required this.trackingNumber, required this.onExit});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: const Text('Confirmation'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(color: Color(0xFFE8F5E8), shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 54, color: green),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Merci pour votre courage',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: green),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB9E4BA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Numéro de suivi'),
                  const SizedBox(height: 6),
                  Text(
                    trackingNumber,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: green,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Conservez-le pour tout suivi ultérieur'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _successRow(Icons.shield_outlined, 'Votre dossier a été enregistré avec succès',
                'Toutes vos informations sont sécurisées et confidentielles'),
            _successRow(Icons.groups_2_outlined, 'Une équipe dédiée vous contactera',
                'Selon vos préférences, en toute confidentialité'),
            _successRow(Icons.favorite_border, "Vous n'êtes pas seul(e)",
                'Nous sommes là pour vous accompagner dans cette épreuve'),
            const Divider(height: 32),
            const Text(
              "Si vous êtes en danger immédiat, contactez les services d'urgence",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onExit,
              style: FilledButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
              child: const Text('Quitter en sécurité'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _successRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
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
