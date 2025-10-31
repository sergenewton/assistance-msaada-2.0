import React, { useEffect, useState } from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { CasesTable } from '@/components/Triage/CasesTable';
import { CaseOverview } from '@/types/dashboard';
import { reportsService } from '@/services/reportsService';
import { OperatorNavigation } from '@/pages/Dashboard/OperatorDashboard';
import { useNavigate } from 'react-router-dom';

// Données réelles chargées depuis l'API

export const OperatorTriageUnprocessed: React.FC = () => {
  const [cases, setCases] = useState<CaseOverview[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        setError(null);
        setLoading(true);
        // Utilise l'endpoint dédié
        const data = await reportsService.listUnprocessed(25);
        if (!cancelled) setCases(data);
      } catch (e: any) {
        if (!cancelled) setError(e.message || 'Erreur lors du chargement des cas.');
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => { cancelled = true };
  }, []);

  const handleVoir = (id: string) => {
    navigate(`/operator/cases/${encodeURIComponent(id)}`);
  };
  const handleTraitement = (id: string) => {
    navigate(`/operator/cases/${encodeURIComponent(id)}/traitement`);
  };

  return (
    <DashboardLayout
      title="NOUVEAUX CAS (NON TRAITÉS)"
      subtitle="Triage des cas"
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
      ) : error ? (
        <div className="bg-white dark:bg-gray-800 rounded-lg border border-red-200 p-6 text-red-600">
          {error}
        </div>
      ) : (
        <CasesTable
          cases={cases}
          onVoir={handleVoir}
          onTraitement={handleTraitement}
        />
      )}
    </DashboardLayout>
  );
};

export default OperatorTriageUnprocessed;
