import React from 'react';
import { FileText, SlidersHorizontal, Search, Users, Mail } from 'lucide-react';
import { APSProfile, AssignApsState, CaseDetail } from '@/types/cases';

interface Step2AssignAPSProps {
  data: CaseDetail;
  candidates: APSProfile[];
  state: AssignApsState;
  onChange: (patch: Partial<AssignApsState>) => void;
}

export const Step2AssignAPS: React.FC<Step2AssignAPSProps> = ({ data, candidates, state, onChange }) => {
  return (
    <div className="space-y-6">
      {/* Résumé cas */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
          <FileText className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Résumé du cas</h3>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 text-sm">
          <div><div className="text-gray-600">Numéro du cas</div><div className="font-medium">#{data.trackingNumber}</div></div>
          <div><div className="text-gray-600">Type de violence</div><div className="capitalize">{String(data.violenceType).replace('_',' ')}</div></div>
          <div><div className="text-gray-600">Niveau d'urgence</div><div className="font-medium">{data.urgency}</div></div>
          <div><div className="text-gray-600">Localisation</div><div>{data.location?.address || '—'}</div></div>
        </div>
      </section>

      {/* Filtres auto */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
          <SlidersHorizontal className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Filtres automatiques appliqués</h3>
        </div>
        <ul className="list-disc pl-5 text-sm text-gray-700 dark:text-gray-200">
          <li>Spécialisation requise (basée sur type de violence)</li>
          <li>Localisation géographique</li>
          <li>Disponibilité immédiate</li>
          <li>Charge de travail actuelle (&lt; 15 cas)</li>
        </ul>
      </section>

      {/* Filtres manuels */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
          <Search className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Recherche et filtres</h3>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-3 text-sm">
          <input className="border rounded-md p-2" placeholder="Rechercher par nom"/>
          <select className="border rounded-md p-2"><option>Spécialisation</option></select>
          <select className="border rounded-md p-2"><option>Localisation</option></select>
          <select className="border rounded-md p-2"><option>Disponibilité</option></select>
        </div>
      </section>

      {/* Liste APS */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
          <Users className="w-4 h-4" />
          <h3 className="text-sm font-semibold">APS recommandés</h3>
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {candidates.map((aps, idx) => (
            <label key={aps.id} className="border rounded-lg p-4 flex gap-4 cursor-pointer hover:bg-gray-50">
              <input type="radio" name="aps" className="mt-1" checked={state.selectedApsId === aps.id} onChange={() => onChange({ selectedApsId: aps.id })} />
              <div className="flex-1">
                <div className="flex items-center gap-2">
                  <div className="text-sm font-semibold">{aps.fullName}</div>
                  {idx === 0 && <span className="text-xs px-2 py-0.5 bg-success-100 text-success-700 rounded-full border border-success-200">Meilleur match</span>}
                </div>
                <div className="text-xs text-gray-600">{aps.title} • {aps.yearsExp} ans d'expérience</div>
                <div className="text-xs text-gray-600">Score: {aps.relevanceScore}% • Charge: {aps.workload}/15 • Satisfaction: {aps.satisfaction}/5 • Temps réponse: {aps.avgResponseHours}h</div>
                <div className="mt-2 flex flex-wrap gap-1 text-xs">
                  {aps.specialties.map(s => <span key={s} className="px-2 py-0.5 rounded border">{s}</span>)}
                </div>
                <div className="mt-1 flex flex-wrap gap-1 text-xs">
                  {aps.languages.map(l => <span key={l} className="px-2 py-0.5 rounded bg-gray-100">{l}</span>)}
                </div>
                <div className="mt-1 text-xs text-gray-600">{aps.location}</div>
              </div>
              <div className="text-xs">
                {aps.availability === 'now' && <span className="px-2 py-1 rounded-full bg-success-100 text-success-700 border border-success-200">Disponible maintenant</span>}
                {aps.availability === 'in-hours' && <span className="px-2 py-1 rounded-full bg-warning-50 text-warning-700 border border-warning-200">Disponible dans quelques heures</span>}
                {aps.availability === 'not-available' && <span className="px-2 py-1 rounded-full bg-gray-100 text-gray-600 border border-gray-200">Non disponible</span>}
              </div>
            </label>
          ))}
        </div>
      </section>

      {/* Message et notifications */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
          <Mail className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Message d'assignation</h3>
        </div>
        <textarea
          maxLength={500}
          placeholder="Ex: Cas urgent - Danger immédiat. Prioriser contact dans l'heure..."
          className="w-full border rounded-md p-2 text-sm min-h-[96px]"
          value={state.message || ''}
          onChange={(e) => onChange({ message: e.target.value })}
        />
        <div className="mt-3 flex gap-4 text-sm">
          <label className="inline-flex items-center gap-2"><input type="checkbox" checked={!!state.notifySms} onChange={(e)=>onChange({ notifySms: e.target.checked })}/> <span>Envoyer SMS</span></label>
          <label className="inline-flex items-center gap-2"><input type="checkbox" checked={!!state.notifyPush} onChange={(e)=>onChange({ notifyPush: e.target.checked })}/> <span>Notification Push</span></label>
          <label className="inline-flex items-center gap-2"><input type="checkbox" checked={!!state.notifyEmail} onChange={(e)=>onChange({ notifyEmail: e.target.checked })}/> <span>Email</span></label>
        </div>
      </section>

      <div className="text-xs text-gray-500">Sélectionnez un APS pour continuer.</div>
    </div>
  );
};

export default Step2AssignAPS;
