import React from 'react';
import { CaseDetail, AssignApsState, ReferralsState, ValidationChecklist, EvaluationState } from '@/types/cases';
import Button from '@/components/UI/Button';
import { FileText, UserCheck, Share2, CheckCircle2 } from 'lucide-react';

interface Step4ValidationProps {
  data: CaseDetail;
  evaluation: EvaluationState;
  assignAps: AssignApsState;
  referrals: ReferralsState;
  checklist: ValidationChecklist;
  onChecklistChange: (patch: Partial<ValidationChecklist>) => void;
  onValidate: () => void;
}

export const Step4Validation: React.FC<Step4ValidationProps> = ({ data, evaluation, assignAps, referrals, checklist, onChecklistChange, onValidate }) => {
  const allChecked = checklist.infoChecked && checklist.orgsSelected && checklist.messagesRespectful && checklist.priorityUnderstood;

  return (
    <div className="space-y-6">
      {/* Récap cas */}
        <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <FileText className="w-4 h-4" />
            <h3 className="text-sm font-semibold">Récapitulatif du cas</h3>
          </div>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-3 text-sm">
          <div><div className="text-gray-600">Numéro</div><div>#{data.trackingNumber}</div></div>
          <div><div className="text-gray-600">Type</div><div className="capitalize">{data.violenceType}</div></div>
          <div><div className="text-gray-600">Urgence</div><div>{evaluation.confirmedUrgency}</div></div>
          <div><div className="text-gray-600">Profil</div><div>{data.victim.ageRange} • {data.location?.address}</div></div>
        </div>
      </section>

      {/* APS assigné */}
        <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <UserCheck className="w-4 h-4" />
            <h3 className="text-sm font-semibold">APS assigné</h3>
          </div>
        <div className="text-sm text-gray-700">ID sélectionné: {assignAps.selectedApsId || '—'}</div>
        <div className="text-xs text-gray-500">Notifications: {assignAps.notifySms ? 'SMS ' : ''}{assignAps.notifyPush ? 'Push ' : ''}{assignAps.notifyEmail ? 'Email' : ''}</div>
      </section>

      {/* Référencements */}
        <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <Share2 className="w-4 h-4" />
            <h3 className="text-sm font-semibold">Référencements</h3>
          </div>
        {referrals.items.length === 0 ? (
          <div className="text-sm text-gray-500">Aucun référencement configuré</div>
        ) : (
          <ul className="text-sm list-disc pl-5">
            {referrals.items.map((it, idx) => (
              <li key={it.id}>
                <span className="font-medium">{idx+1}.</span> {it.serviceType} → Org: {it.orgId || '—'} • Prio: {it.priority}
              </li>
            ))}
          </ul>
        )}
      </section>

      {/* Checklist */}
        <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4" />
            <h3 className="text-sm font-semibold">Validation finale</h3>
          </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm">
          <label className="inline-flex items-center gap-2"><input type="checkbox" checked={checklist.infoChecked} onChange={(e)=>onChecklistChange({ infoChecked: e.target.checked })}/> J'ai vérifié toutes les informations</label>
          <label className="inline-flex items-center gap-2"><input type="checkbox" checked={checklist.orgsSelected} onChange={(e)=>onChecklistChange({ orgsSelected: e.target.checked })}/> J'ai sélectionné les bonnes organisations</label>
          <label className="inline-flex items-center gap-2"><input type="checkbox" checked={checklist.messagesRespectful} onChange={(e)=>onChecklistChange({ messagesRespectful: e.target.checked })}/> Les messages sont appropriés et respectueux</label>
          <label className="inline-flex items-center gap-2"><input type="checkbox" checked={checklist.priorityUnderstood} onChange={(e)=>onChecklistChange({ priorityUnderstood: e.target.checked })}/> Je comprends la priorité définie</label>
        </div>
      </section>

      <div className="flex items-center justify-end gap-2">
        <Button variant="success" size="sm" className="rounded-full" disabled={!allChecked} onClick={onValidate}>✅ VALIDER ET ENVOYER</Button>
      </div>
    </div>
  );
};

export default Step4Validation;
