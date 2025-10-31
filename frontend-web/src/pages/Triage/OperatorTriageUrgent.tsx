import React, { useEffect, useState } from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { CasesTable } from '@/components/Triage/CasesTable';
import { CaseOverview } from '@/types/dashboard';
import { reportsService } from '@/services/reportsService';
import { OperatorNavigation } from '@/pages/Dashboard/OperatorDashboard';
import { AlertTriangle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

// Données réelles chargées depuis l'API

export const OperatorTriageUrgent: React.FC = () => {
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
        const data = await reportsService.listUnprocessedUrgent(25);
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
      ) : error ? (
        <div className="bg-white dark:bg-gray-800 rounded-lg border border-red-200 p-6 text-red-600">
          {error}
        </div>
      ) : (
        <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <AlertTriangle className="w-4 h-4" />
            <h3 className="text-sm font-semibold">Urgents</h3>
          </div>
          <CasesTable
            cases={cases}
            onVoir={handleVoir}
            onTraitement={handleTraitement}
          />
        </section>
      )}
    </DashboardLayout>
  );
};

export default OperatorTriageUrgent;
