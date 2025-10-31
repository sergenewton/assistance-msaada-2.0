import React, { useEffect, useState } from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { RecentCases } from '@/components/Dashboard/RecentCases';
import { CaseOverview } from '@/types/dashboard';
import { OperatorNavigation } from '@/pages/Dashboard/OperatorDashboard';

const mockUrgentCases: CaseOverview[] = [
  {
    id: 'g1',
    trackingNumber: 'MSA20241031-010',
    urgency: 'critical',
    status: 'new',
    type: 'Violence physique',
    createdAt: new Date().toISOString(),
    lastUpdate: new Date().toISOString(),
  },
  {
    id: 'g2',
    trackingNumber: 'MSA20241031-011',
    urgency: 'high',
    status: 'in-progress',
    type: 'Violence sexuelle',
    createdAt: new Date(Date.now() - 1000 * 60 * 55).toISOString(),
    lastUpdate: new Date(Date.now() - 1000 * 60 * 30).toISOString(),
    assignedTo: 'APS – Marie D.'
  },
  {
    id: 'g3',
    trackingNumber: 'MSA20241030-099',
    urgency: 'high',
    status: 'pending',
    type: 'Violence psychologique',
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24).toISOString(),
    lastUpdate: new Date(Date.now() - 1000 * 60 * 60 * 12).toISOString(),
  }
];

export const OperatorTriageUrgent: React.FC = () => {
  const [cases, setCases] = useState<CaseOverview[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // TODO: Remplacer par un appel API /triage?urgency=high|critical
    setLoading(true);
    const timer = setTimeout(() => {
      setCases(mockUrgentCases);
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
      subtitle="Urgents"
      navigationItems={OperatorNavigation}
      userRole="operateur"
    >
      <div className="mb-6">
        <p className="text-sm text-gray-600 dark:text-gray-300">
          Liste des signalements à forte criticité nécessitant une intervention immédiate.
        </p>
      </div>

      {loading ? (
        <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-6 text-gray-500">
          Chargement...
        </div>
      ) : (
        <RecentCases
          cases={cases}
          title="Urgents"
          onViewAll={() => console.log('Voir tous')}
          onCaseClick={handleCaseClick}
        />
      )}
    </DashboardLayout>
  );
};

export default OperatorTriageUrgent;
