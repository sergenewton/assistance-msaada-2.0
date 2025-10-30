import React, { useState, useEffect } from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { StatsCard } from '@/components/Dashboard/StatsCard';
import { ModuleCard } from '@/components/Dashboard/ModuleCard';
import { RecentCases } from '@/components/Dashboard/RecentCases';
import { NavigationItem, Module, DashboardStats, CaseOverview } from '@/types/dashboard';

const SupervisorNavigation: NavigationItem[] = [
  {
    id: 'dashboard',
    label: 'Vue d\'ensemble',
    icon: 'fas fa-tachometer-alt',
    path: '/supervisor/dashboard',
    permissions: ['dashboard.consolidated.view'],
    isActive: true
  },
  {
    id: 'cases-overview',
    label: 'Supervision des cas',
    icon: 'fas fa-eye',
    path: '/supervisor/cases',
    permissions: ['cases.view.all'],
    children: [
      {
        id: 'cases-all',
        label: 'Tous les cas',
        icon: 'fas fa-folder-open',
        path: '/supervisor/cases/all',
        permissions: ['cases.view.all']
      },
      {
        id: 'cases-critical',
        label: 'Cas critiques',
        icon: 'fas fa-exclamation-triangle',
        path: '/supervisor/cases/critical',
        permissions: ['cases.view.all'],
        badge: 8
      },
      {
        id: 'cases-reassign',
        label: 'Réaffectation',
        icon: 'fas fa-exchange-alt',
        path: '/supervisor/cases/reassign',
        permissions: ['cases.reassign']
      }
    ]
  },
  {
    id: 'performance',
    label: 'Monitoring performance',
    icon: 'fas fa-chart-line',
    path: '/supervisor/performance',
    permissions: ['performance.monitor'],
    children: [
      {
        id: 'performance-response-times',
        label: 'Temps de réponse',
        icon: 'fas fa-stopwatch',
        path: '/supervisor/performance/response-times',
        permissions: ['performance.monitor']
      },
      {
        id: 'performance-aps',
        label: 'Performance APS',
        icon: 'fas fa-user-check',
        path: '/supervisor/performance/aps',
        permissions: ['performance.monitor']
      },
      {
        id: 'performance-organizations',
        label: 'Organisations',
        icon: 'fas fa-building',
        path: '/supervisor/performance/organizations',
        permissions: ['performance.monitor']
      }
    ]
  },
  {
    id: 'strategic-reports',
    label: 'Rapports stratégiques',
    icon: 'fas fa-file-alt',
    path: '/supervisor/reports',
    permissions: ['reports.strategic.generate'],
    children: [
      {
        id: 'reports-monthly',
        label: 'Rapports mensuels',
        icon: 'fas fa-calendar-alt',
        path: '/supervisor/reports/monthly',
        permissions: ['reports.strategic.generate']
      },
      {
        id: 'reports-trends',
        label: 'Analyse des tendances',
        icon: 'fas fa-trending-up',
        path: '/supervisor/reports/trends',
        permissions: ['reports.strategic.generate']
      },
      {
        id: 'reports-impact',
        label: 'Mesure d\'impact',
        icon: 'fas fa-bullseye',
        path: '/supervisor/reports/impact',
        permissions: ['reports.strategic.generate']
      }
    ]
  },
  {
    id: 'analytics',
    label: 'Analytics avancées',
    icon: 'fas fa-chart-pie',
    path: '/supervisor/analytics',
    permissions: ['analytics.full.access'],
    children: [
      {
        id: 'analytics-dashboard',
        label: 'Tableaux de bord',
        icon: 'fas fa-tachometer-alt',
        path: '/supervisor/analytics/dashboards',
        permissions: ['analytics.full.access']
      },
      {
        id: 'analytics-predictive',
        label: 'Analyses prédictives',
        icon: 'fas fa-crystal-ball',
        path: '/supervisor/analytics/predictive',
        permissions: ['analytics.full.access']
      }
    ]
  },
  {
    id: 'export',
    label: 'Export de données',
    icon: 'fas fa-download',
    path: '/supervisor/export',
    permissions: ['data.export.statistics']
  },
  {
    id: 'quality-control',
    label: 'Contrôle qualité',
    icon: 'fas fa-check-double',
    path: '/supervisor/quality',
    permissions: ['quality.control'],
    children: [
      {
        id: 'quality-audits',
        label: 'Audits qualité',
        icon: 'fas fa-search',
        path: '/supervisor/quality/audits',
        permissions: ['quality.control']
      },
      {
        id: 'quality-standards',
        label: 'Standards',
        icon: 'fas fa-medal',
        path: '/supervisor/quality/standards',
        permissions: ['quality.control']
      }
    ]
  }
];

const SupervisorModules: Module[] = [
  {
    id: 'case-management',
    name: 'Supervision des Cas',
    description: 'Vue d\'ensemble complète de tous les cas, supervision en temps réel et intervention d\'urgence.',
    icon: 'fas fa-eye',
    color: '#3B82F6',
    permissions: ['cases.view.all'],
    isActive: true
  },
  {
    id: 'awareness',
    name: 'Sensibilisation Stratégique',
    description: 'Planifier et superviser les campagnes de sensibilisation, mesurer leur impact.',
    icon: 'fas fa-graduation-cap',
    color: '#059669',
    permissions: ['awareness.strategic'],
    isActive: true
  },
  {
    id: 'secure-communication',
    name: 'Communication Stratégique',
    description: 'Coordination des communications entre tous les acteurs, messages institutionnels.',
    icon: 'fas fa-broadcast-tower',
    color: '#10B981',
    permissions: ['communication.strategic'],
    isActive: true
  },
  {
    id: 'alerts-notifications',
    name: 'Alertes Stratégiques',
    description: 'Surveillance des indicateurs clés, alertes de performance et escalades automatiques.',
    icon: 'fas fa-bell',
    color: '#F59E0B',
    permissions: ['alerts.strategic'],
    isActive: true
  },
  {
    id: 'reports-statistics',
    name: 'Analytics Avancées',
    description: 'Analyses approfondies, rapports stratégiques et métriques de performance globale.',
    icon: 'fas fa-chart-line',
    color: '#8B5CF6',
    permissions: ['analytics.full.access'],
    isActive: true
  },
  {
    id: 'feedback-evaluation',
    name: 'Évaluation Performance',
    description: 'Évaluation continue de la performance, satisfaction des bénéficiaires et amélioration continue.',
    icon: 'fas fa-star',
    color: '#EC4899',
    permissions: ['evaluation.performance'],
    isActive: true
  },
  {
    id: 'advanced-security',
    name: 'Sécurité Opérationnelle',
    description: 'Surveillance de la conformité sécuritaire, analyse des risques opérationnels.',
    icon: 'fas fa-shield-alt',
    color: '#6B7280',
    permissions: ['security.operational'],
    isActive: true
  }
];

interface KPI {
  label: string;
  value: number | string;
  target: number | string;
  trend: 'up' | 'down' | 'stable';
  color: 'green' | 'red' | 'yellow' | 'blue';
}

interface TeamPerformance {
  aps: {
    active: number;
    avgResponseTime: number;
    caseLoad: number;
    satisfaction: number;
  };
  operators: {
    active: number;
    triageEfficiency: number;
    avgProcessingTime: number;
  };
  organizations: {
    active: number;
    avgAcceptanceRate: number;
    avgResponseTime: number;
  };
}

// Mock data
const mockStats: DashboardStats = {
  totalCases: 1456,
  activeCases: 234,
  urgentCases: 28,
  completedCases: 1194,
  pendingActions: 18,
  responseTime: 2.1
};

const mockKPIs: KPI[] = [
  { label: 'Taux de résolution', value: '89%', target: '90%', trend: 'up', color: 'green' },
  { label: 'Satisfaction globale', value: '4.6/5', target: '4.5/5', trend: 'up', color: 'green' },
  { label: 'Temps moyen de traitement', value: '2.1h', target: '2.0h', trend: 'down', color: 'yellow' },
  { label: 'Cas en retard', value: '3%', target: '2%', trend: 'up', color: 'red' }
];

const mockTeamPerformance: TeamPerformance = {
  aps: {
    active: 12,
    avgResponseTime: 1.8,
    caseLoad: 8.5,
    satisfaction: 4.7
  },
  operators: {
    active: 6,
    triageEfficiency: 94,
    avgProcessingTime: 0.5
  },
  organizations: {
    active: 18,
    avgAcceptanceRate: 87,
    avgResponseTime: 3.2
  }
};

const mockRecentCases: CaseOverview[] = [
  {
    id: '1',
    trackingNumber: 'MSA2024030',
    urgency: 'critical',
    status: 'new',
    type: 'Violence physique grave',
    createdAt: '2024-10-30T16:45:00Z',
    lastUpdate: '2024-10-30T16:45:00Z',
    assignedTo: 'En attente d\'attribution'
  },
  {
    id: '2',
    trackingNumber: 'MSA2024029',
    urgency: 'high',
    status: 'in-progress',
    type: 'Violence sexuelle',
    createdAt: '2024-10-30T14:20:00Z',
    lastUpdate: '2024-10-30T15:30:00Z',
    assignedTo: 'Dr. Kamina (APS)',
    organization: 'Hôpital Général'
  }
];

export const SupervisorDashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats>(mockStats);
  const [kpis, setKpis] = useState<KPI[]>(mockKPIs);
  const [teamPerformance, setTeamPerformance] = useState<TeamPerformance>(mockTeamPerformance);
  const [recentCases, setRecentCases] = useState<CaseOverview[]>(mockRecentCases);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    setIsLoading(true);
    setTimeout(() => {
      setStats(mockStats);
      setKpis(mockKPIs);
      setTeamPerformance(mockTeamPerformance);
      setRecentCases(mockRecentCases);
      setIsLoading(false);
    }, 1000);
  }, []);

  const handleModuleClick = (moduleId: string) => {
    console.log(`Naviguer vers le module: ${moduleId}`);
  };

  const handleCaseClick = (caseId: string) => {
    console.log(`Superviser le cas: ${caseId}`);
  };

  const getTrendIcon = (trend: string) => {
    switch (trend) {
      case 'up': return 'fas fa-arrow-up text-green-500';
      case 'down': return 'fas fa-arrow-down text-red-500';
      default: return 'fas fa-minus text-gray-500';
    }
  };

  if (isLoading) {
    return (
      <DashboardLayout
        title="Supervision Générale"
        subtitle="Coordinateur"
        navigationItems={SupervisorNavigation}
        userRole="superviseur"
      >
        <div className="flex items-center justify-center min-h-64">
          <div className="text-center">
            <i className="fas fa-spinner fa-spin text-4xl text-gray-400 mb-4"></i>
            <p className="text-gray-500">Chargement des données de supervision...</p>
          </div>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout
      title="Supervision Générale"
      subtitle="Vue stratégique et coordination globale de la plateforme"
      navigationItems={SupervisorNavigation}
      userRole="superviseur"
    >
      {/* KPIs principaux */}
      <div className="bg-gradient-to-r from-indigo-50 via-purple-50 to-pink-50 border border-indigo-200 rounded-lg p-6 mb-8">
        <h3 className="text-lg font-semibold text-gray-900 mb-6">Indicateurs de Performance Clés (KPI)</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {kpis.map((kpi, index) => (
            <div key={index} className="bg-white rounded-lg p-4 border border-gray-200">
              <div className="flex items-center justify-between mb-2">
                <p className="text-sm font-medium text-gray-600">{kpi.label}</p>
                <i className={getTrendIcon(kpi.trend)}></i>
              </div>
              <div className="flex items-center justify-between">
                <p className={`text-2xl font-bold text-${kpi.color}-600`}>{kpi.value}</p>
                <p className="text-sm text-gray-500">Cible: {kpi.target}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Statistiques globales */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-6 mb-8">
        <StatsCard
          title="Total des cas"
          value={stats.totalCases}
          icon="fas fa-database"
          color="blue"
          trend={{ value: 18, isPositive: true }}
        />
        <StatsCard
          title="Cas actifs"
          value={stats.activeCases}
          icon="fas fa-clock"
          color="purple"
          onClick={() => handleModuleClick('case-management')}
        />
        <StatsCard
          title="Cas critiques"
          value={stats.urgentCases}
          icon="fas fa-exclamation-triangle"
          color="red"
        />
        <StatsCard
          title="Taux de résolution"
          value="89%"
          icon="fas fa-check-circle"
          color="green"
          trend={{ value: 3, isPositive: true }}
        />
        <StatsCard
          title="Actions en retard"
          value={stats.pendingActions}
          icon="fas fa-hourglass-half"
          color="yellow"
        />
        <StatsCard
          title="Performance globale"
          value="Excellente"
          icon="fas fa-star"
          color="indigo"
        />
      </div>

      {/* Vue d'ensemble des équipes */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
        {/* Performance APS */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            <i className="fas fa-user-check text-blue-500 mr-2"></i>
            Agents Psychosociaux
          </h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Agents actifs</span>
              <span className="text-lg font-bold text-blue-600">{teamPerformance.aps.active}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Charge de travail moyenne</span>
              <span className="text-sm font-medium">{teamPerformance.aps.caseLoad} cas/agent</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Temps de réponse</span>
              <span className="text-sm font-medium">{teamPerformance.aps.avgResponseTime}h</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Satisfaction</span>
              <span className="text-sm font-medium text-green-600">{teamPerformance.aps.satisfaction}/5</span>
            </div>
          </div>
        </div>

        {/* Performance Opérateurs */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            <i className="fas fa-headset text-green-500 mr-2"></i>
            Opérateurs Centre d'Écoute
          </h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Opérateurs actifs</span>
              <span className="text-lg font-bold text-green-600">{teamPerformance.operators.active}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Efficacité triage</span>
              <span className="text-sm font-medium">{teamPerformance.operators.triageEfficiency}%</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Temps de traitement</span>
              <span className="text-sm font-medium">{teamPerformance.operators.avgProcessingTime}h</span>
            </div>
          </div>
        </div>

        {/* Performance Organisations */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            <i className="fas fa-building text-purple-500 mr-2"></i>
            Organisations Partenaires
          </h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Organisations actives</span>
              <span className="text-lg font-bold text-purple-600">{teamPerformance.organizations.active}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Taux d'acceptation</span>
              <span className="text-sm font-medium">{teamPerformance.organizations.avgAcceptanceRate}%</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Temps de réponse</span>
              <span className="text-sm font-medium">{teamPerformance.organizations.avgResponseTime}h</span>
            </div>
          </div>
        </div>
      </div>

      {/* Cas critiques et actions stratégiques */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        {/* Cas nécessitant une supervision */}
        <RecentCases
          cases={recentCases}
          title="Cas nécessitant une attention"
          onViewAll={() => console.log('Voir tous les cas critiques')}
          onCaseClick={handleCaseClick}
        />

        {/* Actions stratégiques */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">
            Actions stratégiques requises
          </h3>
          <div className="space-y-4">
            <div className="border border-red-200 bg-red-50 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <h4 className="font-medium text-red-900">Réaffectation urgente</h4>
                <span className="bg-red-600 text-white text-xs px-2 py-1 rounded-full">3</span>
              </div>
              <p className="text-sm text-red-700 mb-3">Cas dépassant les délais standard</p>
              <button className="w-full bg-red-600 text-white py-2 rounded-lg hover:bg-red-700 transition-colors">
                Intervenir maintenant
              </button>
            </div>

            <div className="border border-yellow-200 bg-yellow-50 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <h4 className="font-medium text-yellow-900">Optimisation ressources</h4>
                <span className="bg-yellow-600 text-white text-xs px-2 py-1 rounded-full">!</span>
              </div>
              <p className="text-sm text-yellow-700 mb-3">Charge de travail déséquilibrée</p>
              <button className="w-full bg-yellow-600 text-white py-2 rounded-lg hover:bg-yellow-700 transition-colors">
                Analyser et ajuster
              </button>
            </div>

            <div className="border border-blue-200 bg-blue-50 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <h4 className="font-medium text-blue-900">Rapport stratégique</h4>
                <span className="bg-blue-600 text-white text-xs px-2 py-1 rounded-full">!</span>
              </div>
              <p className="text-sm text-blue-700 mb-3">Rapport mensuel à finaliser</p>
              <button className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition-colors">
                Générer le rapport
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Modules stratégiques */}
      <div className="mb-8">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">
          Modules de supervision stratégique
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-7 gap-6">
          {SupervisorModules.map((module) => (
            <ModuleCard
              key={module.id}
              module={module}
              onClick={() => handleModuleClick(module.id)}
            />
          ))}
        </div>
      </div>

      {/* Graphiques et analytics */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Tendances des derniers 6 mois
          </h3>
          <div className="h-64 flex items-center justify-center text-gray-500">
            <div className="text-center">
              <i className="fas fa-chart-area text-4xl mb-4"></i>
              <p>Graphique des tendances évolutives</p>
              <p className="text-sm">(Charts.js - Évolution temporelle)</p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Impact et efficacité par région
          </h3>
          <div className="h-64 flex items-center justify-center text-gray-500">
            <div className="text-center">
              <i className="fas fa-map text-4xl mb-4"></i>
              <p>Cartographie des interventions</p>
              <p className="text-sm">(Carte interactive avec métriques)</p>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
};