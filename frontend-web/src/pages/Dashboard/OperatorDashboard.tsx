import React, { useState, useEffect } from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { StatsCard } from '@/components/Dashboard/StatsCard';
import { ModuleCard } from '@/components/Dashboard/ModuleCard';
import { RecentCases } from '@/components/Dashboard/RecentCases';
import { NavigationItem, Module, DashboardStats, CaseOverview } from '@/types/dashboard';

const OperatorNavigation: NavigationItem[] = [
  {
    id: 'dashboard',
    label: 'Tableau de bord',
    icon: 'fas fa-tachometer-alt',
    path: '/operator/dashboard',
    permissions: ['dashboard.view'],
    isActive: true
  },
  {
    id: 'triage',
    label: 'Triage',
    icon: 'fas fa-sort-amount-up',
    path: '/operator/triage',
    permissions: ['cases.triage'],
    badge: 12,
    children: [
      {
        id: 'triage-new',
        label: 'Nouveaux signalements',
        icon: 'fas fa-inbox',
        path: '/operator/triage/new',
        permissions: ['cases.triage'],
        badge: 8
      },
      {
        id: 'triage-urgent',
        label: 'Urgents',
        icon: 'fas fa-exclamation-triangle',
        path: '/operator/triage/urgent',
        permissions: ['urgency.evaluate'],
        badge: 4
      }
    ]
  },
  {
    id: 'cases',
    label: 'Gestion des cas',
    icon: 'fas fa-folder-open',
    path: '/operator/cases',
    permissions: ['cases.view.all'],
    children: [
      {
        id: 'cases-active',
        label: 'Cas actifs',
        icon: 'fas fa-clock',
        path: '/operator/cases/active',
        permissions: ['cases.view.all'],
        badge: 25
      },
      {
        id: 'cases-assignment',
        label: 'Attribution APS',
        icon: 'fas fa-user-plus',
        path: '/operator/cases/assignment',
        permissions: ['cases.assign']
      },
      {
        id: 'cases-follow-up',
        label: 'Suivi',
        icon: 'fas fa-eye',
        path: '/operator/cases/follow-up',
        permissions: ['cases.view.all']
      }
    ]
  },
  {
    id: 'referrals',
    label: 'Référencements',
    icon: 'fas fa-share-alt',
    path: '/operator/referrals',
    permissions: ['referrals.manage'],
    children: [
      {
        id: 'referrals-pending',
        label: 'En attente',
        icon: 'fas fa-hourglass-half',
        path: '/operator/referrals/pending',
        permissions: ['referrals.manage'],
        badge: 6
      },
      {
        id: 'referrals-organizations',
        label: 'Organisations',
        icon: 'fas fa-building',
        path: '/operator/referrals/organizations',
        permissions: ['organizations.contact']
      }
    ]
  },
  {
    id: 'monitoring',
    label: 'Surveillance',
    icon: 'fas fa-chart-line',
    path: '/operator/monitoring',
    permissions: ['cases.view.all'],
    children: [
      {
        id: 'monitoring-delays',
        label: 'Retards',
        icon: 'fas fa-clock',
        path: '/operator/monitoring/delays',
        permissions: ['cases.view.all'],
        badge: 3
      },
      {
        id: 'monitoring-validation',
        label: 'Validation clôture',
        icon: 'fas fa-check-circle',
        path: '/operator/monitoring/validation',
        permissions: ['cases.validate.closure']
      }
    ]
  },
  {
    id: 'alerts',
    label: 'Alertes',
    icon: 'fas fa-bell',
    path: '/operator/alerts',
    permissions: ['alerts.view'],
    badge: 7
  }
];

const OperatorModules: Module[] = [
  {
    id: 'case-management',
    name: 'Gestion des Cas',
    description: 'Trier, évaluer et assigner les signalements. Suivre l\'évolution de tous les cas.',
    icon: 'fas fa-tasks',
    color: '#3B82F6',
    permissions: ['cases.view.all'],
    isActive: true
  },
  {
    id: 'alerts-notifications',
    name: 'Alertes et Notifications',
    description: 'Recevoir et gérer les alertes en temps réel. Configurer les notifications.',
    icon: 'fas fa-bell',
    color: '#EF4444',
    permissions: ['alerts.manage'],
    isActive: true
  },
  {
    id: 'secure-communication',
    name: 'Communication Sécurisée',
    description: 'Communiquer avec les APS, organisations et survivantes de manière sécurisée.',
    icon: 'fas fa-shield-alt',
    color: '#10B981',
    permissions: ['communication.secure'],
    isActive: true
  },
  {
    id: 'reports-statistics',
    name: 'Rapports et Statistiques',
    description: 'Générer des rapports d\'activité et consulter les statistiques globales.',
    icon: 'fas fa-chart-bar',
    color: '#8B5CF6',
    permissions: ['reports.generate'],
    isActive: true
  },
  {
    id: 'advanced-security',
    name: 'Sécurité Avancée',
    description: 'Surveiller les accès, détecter les anomalies et gérer les incidents de sécurité.',
    icon: 'fas fa-lock',
    color: '#F59E0B',
    permissions: ['security.advanced'],
    isActive: false
  }
];

// Mock data
const mockStats: DashboardStats = {
  totalCases: 156,
  activeCases: 45,
  urgentCases: 8,
  completedCases: 103,
  pendingActions: 12,
  responseTime: 2.1
};

const mockRecentCases: CaseOverview[] = [
  {
    id: '1',
    trackingNumber: 'MSA2024025',
    urgency: 'critical',
    status: 'new',
    type: 'Violence physique',
    createdAt: '2024-10-30T15:30:00Z',
    lastUpdate: '2024-10-30T15:30:00Z'
  },
  {
    id: '2',
    trackingNumber: 'MSA2024024',
    urgency: 'high',
    status: 'in-progress',
    type: 'Violence sexuelle',
    createdAt: '2024-10-30T12:15:00Z',
    lastUpdate: '2024-10-30T14:20:00Z',
    assignedTo: 'Marie Dubois (APS)'
  },
  {
    id: '3',
    trackingNumber: 'MSA2024023',
    urgency: 'moderate',
    status: 'pending',
    type: 'Violence psychologique',
    createdAt: '2024-10-30T09:45:00Z',
    lastUpdate: '2024-10-30T11:00:00Z',
    organization: 'Centre Lisanga'
  }
];

export const OperatorDashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats>(mockStats);
  const [recentCases, setRecentCases] = useState<CaseOverview[]>(mockRecentCases);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    setIsLoading(true);
    setTimeout(() => {
      setStats(mockStats);
      setRecentCases(mockRecentCases);
      setIsLoading(false);
    }, 1000);
  }, []);

  const handleModuleClick = (moduleId: string) => {
    console.log(`Naviguer vers le module: ${moduleId}`);
  };

  const handleCaseClick = (caseId: string) => {
    console.log(`Ouvrir le cas: ${caseId}`);
  };

  const handleTriageClick = () => {
    console.log('Aller au triage');
  };

  if (isLoading) {
    return (
      <DashboardLayout
        title="Centre d'Écoute"
        subtitle="Opérateur"
        navigationItems={OperatorNavigation}
        userRole="operateur"
      >
        <div className="flex items-center justify-center min-h-64">
          <div className="text-center">
            <i className="fas fa-spinner fa-spin text-4xl text-gray-400 mb-4"></i>
            <p className="text-gray-500">Chargement des données...</p>
          </div>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout
      title="Centre d'Écoute"
      subtitle="Plateforme de triage et de coordination des signalements"
      navigationItems={OperatorNavigation}
      userRole="operateur"
    >
      {/* Alertes urgentes */}
      <div className="mb-6">
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="flex items-center">
            <i className="fas fa-exclamation-triangle text-red-600 text-xl mr-3"></i>
            <div className="flex-1">
              <p className="font-medium text-red-900">8 cas urgents nécessitent votre attention immédiate</p>
              <p className="text-sm text-red-700">Dernière mise à jour : il y a 5 minutes</p>
            </div>
            <button 
              onClick={handleTriageClick}
              className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors"
            >
              Voir le triage
            </button>
          </div>
        </div>
      </div>

      {/* Statistiques principales */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-6 mb-8">
        <StatsCard
          title="Total des cas"
          value={stats.totalCases}
          icon="fas fa-folder"
          color="blue"
          trend={{ value: 8, isPositive: true }}
        />
        <StatsCard
          title="Cas actifs"
          value={stats.activeCases}
          icon="fas fa-clock"
          color="purple"
          onClick={() => handleModuleClick('case-management')}
        />
        <StatsCard
          title="Urgents"
          value={stats.urgentCases}
          icon="fas fa-exclamation-triangle"
          color="red"
          onClick={handleTriageClick}
        />
        <StatsCard
          title="Terminés"
          value={stats.completedCases}
          icon="fas fa-check-circle"
          color="green"
        />
        <StatsCard
          title="Actions en attente"
          value={stats.pendingActions}
          icon="fas fa-hourglass-half"
          color="yellow"
        />
        <StatsCard
          title="Temps de réponse"
          value={`${stats.responseTime}h`}
          icon="fas fa-tachometer-alt"
          color="indigo"
          trend={{ value: 15, isPositive: false }}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
        {/* Activité en temps réel */}
        <div className="lg:col-span-2">
          <RecentCases
            cases={recentCases}
            title="Signalements récents"
            onViewAll={() => console.log('Voir tous les signalements')}
            onCaseClick={handleCaseClick}
          />
        </div>

        {/* Actions urgentes */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">
            Actions urgentes
          </h3>
          <div className="space-y-4">
            <div className="border border-red-200 bg-red-50 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <h4 className="font-medium text-red-900">Triage en attente</h4>
                <span className="bg-red-600 text-white text-xs px-2 py-1 rounded-full">8</span>
              </div>
              <p className="text-sm text-red-700 mb-3">Nouveaux signalements à évaluer</p>
              <button className="w-full bg-red-600 text-white py-2 rounded-lg hover:bg-red-700 transition-colors">
                Traiter maintenant
              </button>
            </div>

            <div className="border border-yellow-200 bg-yellow-50 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <h4 className="font-medium text-yellow-900">Retards détectés</h4>
                <span className="bg-yellow-600 text-white text-xs px-2 py-1 rounded-full">3</span>
              </div>
              <p className="text-sm text-yellow-700 mb-3">Organisations en retard de réponse</p>
              <button className="w-full bg-yellow-600 text-white py-2 rounded-lg hover:bg-yellow-700 transition-colors">
                Relancer
              </button>
            </div>

            <div className="border border-blue-200 bg-blue-50 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <h4 className="font-medium text-blue-900">Validation clôture</h4>
                <span className="bg-blue-600 text-white text-xs px-2 py-1 rounded-full">2</span>
              </div>
              <p className="text-sm text-blue-700 mb-3">Cas à valider pour clôture</p>
              <button className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition-colors">
                Examiner
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Graphiques et métriques */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Évolution des signalements (7 derniers jours)
          </h3>
          <div className="h-64 flex items-center justify-center text-gray-500">
            <div className="text-center">
              <i className="fas fa-chart-line text-4xl mb-4"></i>
              <p>Graphique des tendances</p>
              <p className="text-sm">(À implémenter avec Chart.js)</p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Répartition par type de violence
          </h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Violence physique</span>
              <div className="flex items-center">
                <div className="w-24 h-2 bg-gray-200 rounded-full mr-3">
                  <div className="w-16 h-2 bg-red-500 rounded-full"></div>
                </div>
                <span className="text-sm font-medium">67%</span>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Violence sexuelle</span>
              <div className="flex items-center">
                <div className="w-24 h-2 bg-gray-200 rounded-full mr-3">
                  <div className="w-12 h-2 bg-orange-500 rounded-full"></div>
                </div>
                <span className="text-sm font-medium">50%</span>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Violence psychologique</span>
              <div className="flex items-center">
                <div className="w-24 h-2 bg-gray-200 rounded-full mr-3">
                  <div className="w-8 h-2 bg-blue-500 rounded-full"></div>
                </div>
                <span className="text-sm font-medium">33%</span>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Violence économique</span>
              <div className="flex items-center">
                <div className="w-24 h-2 bg-gray-200 rounded-full mr-3">
                  <div className="w-6 h-2 bg-green-500 rounded-full"></div>
                </div>
                <span className="text-sm font-medium">25%</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Modules disponibles */}
      <div className="mb-8">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">
          Modules de travail
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">
          {OperatorModules.map((module) => (
            <ModuleCard
              key={module.id}
              module={module}
              onClick={() => handleModuleClick(module.id)}
            />
          ))}
        </div>
      </div>
    </DashboardLayout>
  );
};