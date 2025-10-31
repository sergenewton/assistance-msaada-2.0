import React from 'react';
import Button from '@/components/UI/Button';
import { CaseOverview } from '@/types/dashboard';

export interface CasesTableProps {
  cases: CaseOverview[];
  onVoir?: (id: string) => void;
  onTraitement?: (id: string) => void;
}

const urgencyLabel: Record<CaseOverview['urgency'], string> = {
  critical: 'Risque critique',
  high: 'Risque élevé',
  moderate: 'Risque modéré',
  low: 'Risque faible',
};

// We include semantic class tokens (badge-*) alongside Tailwind classes for styling hooks/testing.
const urgencyBadgeClass: Record<CaseOverview['urgency'], string> = {
  critical:
    'badge badge-danger inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-danger-50 text-danger-700 border border-danger-200',
  high:
    'badge badge-warning inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-warning-50 text-warning-700 border border-warning-200',
  moderate:
    'badge badge-gray inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-gray-100 text-gray-700 border border-gray-200',
  low:
    'badge badge-secondary inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-secondary-100 text-secondary-800 border border-secondary-200',
};

function formatDateFr(dateIso: string) {
  const d = new Date(dateIso);
  try {
    return d.toLocaleString('fr-FR', {
      year: '2-digit',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    });
  } catch {
    return dateIso;
  }
}

export const CasesTable: React.FC<CasesTableProps> = ({ cases, onVoir, onTraitement }) => {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 overflow-hidden">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Numéro du dossier</th>
              <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Heure/Date</th>
              <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Niveau d’urgence</th>
              <th scope="col" className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200">
            {cases.length === 0 ? (
              <tr>
                <td colSpan={4} className="px-4 py-6 text-center text-sm text-gray-500">Aucun cas à afficher</td>
              </tr>
            ) : (
              cases.map((c) => (
                <tr key={c.id} className="hover:bg-gray-50 dark:hover:bg-gray-700">
                  <td className="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">{c.trackingNumber || '—'}</td>
                  <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-700 dark:text-gray-200">{formatDateFr(c.createdAt)}</td>
                  <td className="px-4 py-3 whitespace-nowrap">
                    <span className={urgencyBadgeClass[c.urgency]}> {urgencyLabel[c.urgency]} </span>
                  </td>
                  <td className="px-4 py-3 whitespace-nowrap">
                    <div className="flex items-center justify-end gap-2">
                      <Button variant="successOutline" size="sm" className="rounded-full" onClick={() => onVoir?.(c.id)}>Voir</Button>
                      <Button variant="success" size="sm" className="rounded-full" onClick={() => onTraitement?.(c.id)}>Traitement</Button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default CasesTable;
