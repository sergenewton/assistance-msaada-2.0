import React, { useMemo, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { OperatorNavigation } from '@/pages/Dashboard/OperatorDashboard';
import Button from '@/components/UI/Button';
import { TreatmentStepper } from '@/components/Cases/Treatment/TreatmentStepper';
import Step1Analysis from '@/components/Cases/Treatment/Step1Analysis';
import Step2AssignAPS from '@/components/Cases/Treatment/Step2AssignAPS';
import Step3Referrals from '@/components/Cases/Treatment/Step3Referrals';
import Step4Validation from '@/components/Cases/Treatment/Step4Validation';
import { APSProfile, CaseDetail, TreatmentState } from '@/types/cases';

const OperatorCaseTreatment: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();

  // Mock case data (to be replaced with API fetch)
  const caseData: CaseDetail = useMemo(() => ({
    id: id || 'unknown',
    trackingNumber: id || 'N/A',
    createdAt: new Date().toISOString(),
    elapsedMinutes: 42,
    autoUrgencyScore: 68,
    urgency: 'high',
    violenceType: 'physical',
    victim: { ageRange: '18-24', gender: 'f', province: 'Kinshasa', commune: 'Gombe', quartier: 'Quartier 1' },
    incident: { place: 'domicile', narrativeEncrypted: true },
    location: { address: 'Av. Exemple 123, Kinshasa', latitude: -4.32, longitude: 15.31 },
    attachments: { photos: [], audio: [] },
    dangerIndicators: { safeNow: false, urgentCareNeeded: true, childrenAtRisk: false, recentDeathThreats: false, perpetratorHasHomeAccess: true },
    needs: { psycho: true, medical: true, legal: false, shelter: false, economic: false, police: true },
  }), [id]);

  const apsCandidates: APSProfile[] = useMemo(() => ([
    { id: 'aps-1', fullName: 'A. Mbala', title: 'Psychologue', yearsExp: 6, relevanceScore: 92, specialties: ['violence physique','urgence'], languages: ['fr','ln'], location: 'Kinshasa / Gombe', workload: 8, satisfaction: 4.6, casesHandled: 120, avgResponseHours: 2, availability: 'now' },
    { id: 'aps-2', fullName: 'B. Kabila', title: 'Assistant social', yearsExp: 4, relevanceScore: 83, specialties: ['écoute','accompagnement'], languages: ['fr','sw'], location: 'Kinshasa / Limete', workload: 10, satisfaction: 4.3, casesHandled: 80, avgResponseHours: 6, availability: 'in-hours' },
  ]), []);

  const orgs = useMemo(() => ([
    { id: 'org-1', name: 'Hôpital Général', kind: 'Hôpital', distanceKm: 2.1, satisfaction: 4.2, responseTime: '2h', cost: 'gratuit', capacity: 5, availability: 'green', openingHours: '24/7', services: ['Urgences','Chirurgie'] },
    { id: 'org-2', name: 'ONG Aide Juridique', kind: 'ONG', distanceKm: 3.8, satisfaction: 4.5, responseTime: '24h', cost: 'gratuit', capacity: 10, availability: 'yellow', openingHours: '08:00-17:00', services: ['Conseil juridique','Assistance en dépôt de plainte'] },
  ]), []);

  const [step, setStep] = useState<1|2|3|4>(1);
  const [state, setState] = useState<TreatmentState>({
    evaluation: { confirmedUrgency: caseData.urgency, imminentDanger: false, immediateActions: '' },
    assignAps: { selectedApsId: undefined, message: '', notifySms: true, notifyPush: true, notifyEmail: true },
    referrals: { items: [], notifyAps: true, smsVictim: true, callOrgBefore: false },
    validation: { infoChecked: false, orgsSelected: false, messagesRespectful: false, priorityUnderstood: false },
  });

  const onNext = () => setStep((s) => (s < 4 ? ((s + 1) as 1|2|3|4) : s));
  const onPrev = () => setStep((s) => (s > 1 ? ((s - 1) as 1|2|3|4) : s));
  const onCancel = () => navigate('/operator/triage/unprocessed');

  return (
    <DashboardLayout
      title={`Traitement du dossier #${id || ''}`}
      subtitle="Première évaluation et actions"
      navigationItems={OperatorNavigation}
      userRole="operateur"
    >
      <div className="mb-4">
        <TreatmentStepper step={step} />
      </div>

      {step === 1 && (
        <Step1Analysis
          data={caseData}
          evaluation={state.evaluation}
          onChange={(patch) => setState((prev) => ({ ...prev, evaluation: { ...prev.evaluation, ...patch } }))}
          onDecryptNarrative={() => console.log('Decrypt narrative requested')}
        />
      )}
      {step === 2 && (
        <Step2AssignAPS
          data={caseData}
          candidates={apsCandidates}
          state={state.assignAps}
          onChange={(patch) => setState((prev) => ({ ...prev, assignAps: { ...prev.assignAps, ...patch } }))}
        />
      )}
      {step === 3 && (
        <Step3Referrals
          availableOrgs={orgs as any}
          state={state.referrals}
          onChange={(patch) => setState((prev) => ({ ...prev, referrals: { ...prev.referrals, ...patch } }))}
        />
      )}
      {step === 4 && (
        <Step4Validation
          data={caseData}
          evaluation={state.evaluation}
          assignAps={state.assignAps}
          referrals={state.referrals}
          checklist={state.validation}
          onChecklistChange={(patch) => setState((prev) => ({ ...prev, validation: { ...prev.validation, ...patch } }))}
          onValidate={() => console.log('Finalize workflow', { id, state })}
        />
      )}

      <div className="mt-6 flex items-center justify-between">
        <div className="flex gap-2">
          <Button variant="outline" size="sm" className="rounded-full" onClick={onCancel}>Annuler</Button>
        </div>
        <div className="flex gap-2">
          {step > 1 && (
            <Button variant="successOutline" size="sm" className="rounded-full" onClick={onPrev}>← Retour</Button>
          )}
          {step < 4 && (
            <Button variant="success" size="sm" className="rounded-full" onClick={onNext}>
              {step === 1 ? 'Suivant : Assigner APS →' : step === 2 ? 'Suivant : Référencements →' : 'Suivant : Validation →'}
            </Button>
          )}
        </div>
      </div>
    </DashboardLayout>
  );
};

export default OperatorCaseTreatment;
