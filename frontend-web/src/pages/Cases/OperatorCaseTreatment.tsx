import React from 'react';
import { useParams } from 'react-router-dom';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { OperatorNavigation } from '@/pages/Dashboard/OperatorDashboard';
import Button from '@/components/UI/Button';

const OperatorCaseTreatment: React.FC = () => {
  const { id } = useParams<{ id: string }>();

  const handleStart = () => {
    // TODO: Hook into treatment workflow
    console.log('Start treatment for', id);
  };

  return (
    <DashboardLayout
      title={`Traitement du dossier #${id || ''}`}
      subtitle="Première évaluation et actions"
      navigationItems={OperatorNavigation}
      userRole="operateur"
    >
      <div className="mb-0">
        <p className="text-sm text-gray-600 dark:text-gray-300">Définir les étapes de triage (évaluation d'urgence, attribution APS, etc.).</p>
      </div>

      <div className="mt-4 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-6 space-y-4">
        <p className="text-gray-700 dark:text-gray-200">Espace de travail pour le traitement du dossier #{id}.</p>
        <div className="flex gap-2">
          <Button variant="success" size="sm" className="rounded-full" onClick={handleStart}>Commencer</Button>
          <Button variant="successOutline" size="sm" className="rounded-full">Enregistrer le brouillon</Button>
        </div>
      </div>
    </DashboardLayout>
  );
};

export default OperatorCaseTreatment;
