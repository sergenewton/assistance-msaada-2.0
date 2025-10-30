import React from 'react';
import { CaseOverview } from '@/types/dashboard';

interface RecentCasesProps {
  cases: CaseOverview[];
  title?: string;
  maxItems?: number;
  onViewAll?: () => void;
  onCaseClick?: (caseId: string) => void;
}

const urgencyColors = {
  critical: 'bg-red-100 text-red-800 border-red-200',
  high: 'bg-orange-100 text-orange-800 border-orange-200',
  moderate: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  low: 'bg-green-100 text-green-800 border-green-200'
};

const statusColors = {
  new: 'bg-blue-100 text-blue-800',
  'in-progress': 'bg-purple-100 text-purple-800',
  pending: 'bg-yellow-100 text-yellow-800',
  completed: 'bg-green-100 text-green-800',
  closed: 'bg-gray-100 text-gray-800'
};

const urgencyLabels = {
  critical: 'Critique',
  high: 'Élevé',
  moderate: 'Modéré',
  low: 'Faible'
};

const statusLabels = {
  new: 'Nouveau',
  'in-progress': 'En cours',
  pending: 'En attente',
  completed: 'Terminé',
  closed: 'Clôturé'
};

export const RecentCases: React.FC<RecentCasesProps> = ({
  cases,
  title = 'Cas récents',
  maxItems = 5,
  onViewAll,
  onCaseClick
}) => {
  const displayedCases = cases.slice(0, maxItems);

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
          {title}
        </h3>
        {onViewAll && (
          <button
            onClick={onViewAll}
            className="text-green-600 hover:text-green-700 text-sm font-medium"
          >
            Voir tout
            <i className="fas fa-arrow-right ml-1"></i>
          </button>
        )}
      </div>

      {displayedCases.length === 0 ? (
        <div className="text-center py-8">
          <i className="fas fa-folder-open text-gray-400 text-3xl mb-4"></i>
          <p className="text-gray-500 dark:text-gray-400">Aucun cas à afficher</p>
        </div>
      ) : (
        <div className="space-y-4">
          {displayedCases.map((caseItem) => (
            <div
              key={caseItem.id}
              className="border border-gray-200 dark:border-gray-700 rounded-lg p-4 hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer transition-colors"
              onClick={() => onCaseClick?.(caseItem.id)}
            >
              <div className="flex items-start justify-between mb-3">
                <div>
                  <div className="flex items-center space-x-2 mb-1">
                    <span className="font-medium text-gray-900 dark:text-white">
                      #{caseItem.trackingNumber}
                    </span>
                    <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${urgencyColors[caseItem.urgency]}`}>
                      {urgencyLabels[caseItem.urgency]}
                    </span>
                  </div>
                  <p className="text-sm text-gray-600 dark:text-gray-400">
                    {caseItem.type}
                  </p>
                </div>
                
                <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${statusColors[caseItem.status]}`}>
                  {statusLabels[caseItem.status]}
                </span>
              </div>

              <div className="flex items-center justify-between text-xs text-gray-500 dark:text-gray-400">
                <div className="flex items-center space-x-4">
                  <span>
                    <i className="fas fa-calendar mr-1"></i>
                    Créé: {formatDate(caseItem.createdAt)}
                  </span>
                  <span>
                    <i className="fas fa-clock mr-1"></i>
                    Maj: {formatDate(caseItem.lastUpdate)}
                  </span>
                </div>

                {(caseItem.assignedTo || caseItem.organization) && (
                  <div className="flex items-center">
                    <i className="fas fa-user mr-1"></i>
                    <span>{caseItem.assignedTo || caseItem.organization}</span>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};