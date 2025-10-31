import React, { useEffect, useState } from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { RecentCases } from '@/components/Dashboard/RecentCases';
import { CaseOverview } from '@/types/dashboard';
import { OperatorNavigation } from '@/pages/Dashboard/OperatorDashboard';

const mockUnprocessedCases: CaseOverview[] = [
  {
    id: 'u1',
    trackingNumber: 'MSA20241031-001',
    urgency: 'moderate',
    status: 'new',
    type: 'Violence psychologique',
    createdAt: new Date().toISOString(),
    lastUpdate: new Date().toISOString(),
  },
  {
    id: 'u2',
    trackingNumber: 'MSA20241031-002',
    urgency: 'low',
    status: 'new',
    type: 'Violence économique',
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString(),
    lastUpdate: new Date(Date.now() - 1000 * 60 * 60).toISOString(),
  },
  {
    id: 'u3',
    trackingNumber: 'MSA20241030-015',
    urgency: 'high',
    status: 'pending',
    type: 'Violence physique',
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 26).toISOString(),
    lastUpdate: new Date(Date.now() - 1000 * 60 * 60 * 20).toISOString(),
  }
];

export const OperatorTriageUnprocessed: React.FC = () => {
  const [cases, setCases] = useState<CaseOverview[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // TODO: Remplacer par un appel API /triage?status=unprocessed
    setLoading(true);
    const timer = setTimeout(() => {
      setCases(mockUnprocessedCases);
      setLoading(false);
    }, 400);
    return () => clearTimeout(timer);
  }, []);

  const handleCaseClick = (id: string) => {
    console.log('Open case', id);
  };

  return (
    <DashboardLayout
      title="Triage"
      subtitle="Non traités"
      navigationItems={OperatorNavigation}
      userRole="operateur"
    >
      <div className="mb-6">
        <p className="text-sm text-gray-600 dark:text-gray-300">
          Liste des signalements en attente de première action (aucune évaluation effectuée).
        </p>
      </div>

      {loading ? (
        <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-6 text-gray-500">
          Chargement...
        </div>
      ) : (
        <RecentCases
          cases={cases}
          title="Non traités"
          onViewAll={() => console.log('Voir tous')}
          onCaseClick={handleCaseClick}
        />
      )}
    </DashboardLayout>
  );
};

export default OperatorTriageUnprocessed;
