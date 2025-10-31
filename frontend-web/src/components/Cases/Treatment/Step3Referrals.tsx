import React from 'react';
import { ClipboardCheck, Bell, Share2 } from 'lucide-react';
import { OrganizationProfile, ReferralsState, ReferralItem, ReferralPriority } from '@/types/cases';
import Button from '@/components/UI/Button';

interface Step3ReferralsProps {
  availableOrgs: OrganizationProfile[];
  state: ReferralsState;
  onChange: (patch: Partial<ReferralsState>) => void;
}

const priorityLabel: Record<ReferralPriority, string> = {
  urgent_24h: 'URGENTE (24h)',
  high_48h: 'Haute (48h)',
  normal_7d: 'Normale (7j)',
  low_14d: 'Faible (14j)'
};

export const Step3Referrals: React.FC<Step3ReferralsProps> = ({ availableOrgs, state, onChange }) => {
  const updateItem = (id: string, patch: Partial<ReferralItem>) => {
    onChange({ items: state.items.map(it => it.id === id ? { ...it, ...patch } : it) });
  };
  const addItem = () => {
    const newItem: ReferralItem = { id: Math.random().toString(36).slice(2), serviceType: 'Service', priority: 'normal_7d' };
    onChange({ items: [...state.items, newItem] });
  };
  const removeItem = (id: string) => {
    onChange({ items: state.items.filter(it => it.id !== id) });
  };

  return (
    <div className="space-y-6">
      {/* Confirmation APS + besoins */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
          <ClipboardCheck className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Besoins identifiés</h3>
        </div>
        <div className="text-sm text-gray-600">Configurer un référencement par besoin requis.</div>
      </section>

      {/* Référencements */}
      {state.items.map((it, idx) => (
        <section key={it.id} className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="flex items-center justify-between mb-2">
            <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
              <Share2 className="w-4 h-4" />
              <h4 className="text-sm font-semibold">RÉFÉRENCEMENT {idx+1}/{state.items.length} : {it.serviceType}</h4>
            </div>
            <Button variant="outline" size="sm" onClick={() => removeItem(it.id)}>Supprimer</Button>
          </div>

          {/* Config */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <div className="text-xs text-gray-600 mb-1">Service requis</div>
              <input className="w-full border rounded-md p-2 text-sm" value={it.serviceType} onChange={(e)=>updateItem(it.id, { serviceType: e.target.value })} />
              <div className="text-xs text-gray-600 mt-3 mb-1">Précisions supplémentaires</div>
              <input className="w-full border rounded-md p-2 text-sm" placeholder="Précisions" value={it.notes || ''} onChange={(e)=>updateItem(it.id, { notes: e.target.value })} />
            </div>
            <div>
              <div className="text-xs text-gray-600 mb-1">Priorité</div>
              <div className="grid grid-cols-2 gap-2 text-sm">
                {(['urgent_24h','high_48h','normal_7d','low_14d'] as ReferralPriority[]).map(p => (
                  <label key={p} className="inline-flex items-center gap-2">
                    <input type="radio" name={`prio-${it.id}`} checked={it.priority === p} onChange={()=>updateItem(it.id, { priority: p })} />
                    <span>{priorityLabel[p]}</span>
                  </label>
                ))}
              </div>
            </div>
          </div>

          {/* Sélection organisation */}
          <div className="mt-4">
            <div className="text-xs text-gray-600 mb-1">Sélection de l'organisation</div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {availableOrgs.map(org => (
                <label key={org.id} className="border rounded-md p-3 flex gap-3 cursor-pointer hover:bg-gray-50">
                  <input type="radio" name={`org-${it.id}`} checked={it.orgId === org.id} onChange={()=>updateItem(it.id, { orgId: org.id })} />
                  <div className="text-sm">
                    <div className="font-medium">{org.name}</div>
                    <div className="text-gray-600 text-xs">{org.kind} • {org.distanceKm ?? '?'} km • {org.satisfaction ?? '?'}★ • {org.responseTime ?? '-'} • {org.cost ?? ''}</div>
                    <div className="flex flex-wrap gap-1 mt-1 text-xs">
                      {(org.services || []).map(s => <span key={s} className="px-2 py-0.5 rounded border">{s}</span>)}
                    </div>
                  </div>
                </label>
              ))}
            </div>
          </div>
        </section>
      ))}

      {/* Add button */}
      <div>
        <Button variant="success" size="sm" className="rounded-full" onClick={addItem}>+ Ajouter un autre référencement</Button>
      </div>

      {/* Notifications */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <Bell className="w-4 h-4" />
            <h3 className="text-sm font-semibold">Notifications</h3>
          </div>
        <div className="flex gap-4 text-sm">
          <label className="inline-flex items-center gap-2"><input type="checkbox" checked={state.notifyAps} onChange={(e)=>onChange({ notifyAps: e.target.checked })}/> <span>Notifier l'APS</span></label>
          <label className="inline-flex items-center gap-2"><input type="checkbox" checked={state.smsVictim} onChange={(e)=>onChange({ smsVictim: e.target.checked })}/> <span>Envoyer SMS à la victime</span></label>
          <label className="inline-flex items-center gap-2"><input type="checkbox" checked={!!state.callOrgBefore} onChange={(e)=>onChange({ callOrgBefore: e.target.checked })}/> <span>Appeler l'organisation avant envoi (si très urgent)</span></label>
        </div>
      </section>

      <div className="text-xs text-gray-500">Configurez au moins un référencement si des besoins sont requis.</div>
    </div>
  );
};

export default Step3Referrals;
