import React from 'react';
import { useParams } from 'react-router-dom';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { OperatorNavigation } from '@/pages/Dashboard/OperatorDashboard';

const OperatorCaseView: React.FC = () => {
  const { id } = useParams<{ id: string }>();

  return (
    <DashboardLayout
      title={`Dossier #${id || ''}`}
      subtitle="Consultation du signalement"
      navigationItems={OperatorNavigation}
      userRole="operateur"
    >
      <div className="mb-0">
        <p className="text-sm text-gray-600 dark:text-gray-300">Vue de détail du dossier. (À brancher à l'API de consultation)</p>
      </div>
      <div className="mt-4 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-6">
        <p className="text-gray-700 dark:text-gray-200">Contenu du dossier #{id}</p>
      </div>
    </DashboardLayout>
  );
};

export default OperatorCaseView;
