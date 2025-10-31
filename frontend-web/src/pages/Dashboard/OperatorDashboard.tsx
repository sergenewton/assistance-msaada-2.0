import React, { useState, useEffect } from 'react';
import { Loader2, AlertTriangle, BarChart2, Circle, CheckCircle, Clock } from 'lucide-react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { StatsCard } from '@/components/Dashboard/StatsCard';
import { ModuleCard } from '@/components/Dashboard/ModuleCard';
import { RecentCases } from '@/components/Dashboard/RecentCases';
import { ResponsiveGrid } from '@/components/Dashboard/ResponsiveGrid';
import { NavigationItem, Module, DashboardStats, CaseOverview } from '@/types/dashboard';

export const OperatorNavigation: NavigationItem[] = [
  {
    id: 'dashboard',
    label: 'Tableau de bord',
    icon: 'fas fa-tachometer-alt',
    path: '/operator/dashboard',
    permissions: ['dashboard.view'],
    isActive: true
  },
  {
    id: 'triages',
    label: 'Triages',
    icon: 'fas fa-sort-amount-up',
    path: '/operator/triage',
    permissions: ['cases.triage'],
    badge: 15,
    children: [
      {
        id: 'triage-unprocessed',
        label: 'Non traités',
        icon: 'fas fa-inbox',
        path: '/operator/triage/unprocessed',
        permissions: ['cases.triage']
      },
      {
        id: 'triage-urgent',
        label: 'Urgents',
        icon: 'fas fa-exclamation-triangle',
        path: '/operator/triage/urgent',
        permissions: ['urgency.evaluate']
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
        label: 'Actifs',
        icon: 'fas fa-folder',
        path: '/operator/cases/active',
        permissions: ['cases.view.all'],
        badge: 156
      },
      {
        id: 'cases-in-progress',
        label: 'En cours',
        icon: 'fas fa-spinner',
        path: '/operator/cases/in-progress',
        permissions: ['cases.view.all']
      },
      {
        id: 'cases-closed',
        label: 'Clôturés',
        icon: 'fas fa-check-circle',
        path: '/operator/cases/closed',
        permissions: ['cases.view.all']
      }
    ]
  },
  {
    id: 'aps',
    label: 'Gestion APS',
    icon: 'fas fa-user-check',
    path: '/operator/aps',
    permissions: ['cases.assign'],
    children: [
      {
        id: 'aps-assignments',
        label: 'Assignations',
        icon: 'fas fa-user-plus',
        path: '/operator/aps/assignments',
        permissions: ['cases.assign']
      },
      {
        id: 'aps-workload',
        label: 'Charge de travail',
        icon: 'fas fa-clipboard-check',
        path: '/operator/aps/workload',
        permissions: ['cases.view.all']
      }
    ]
  },
  {
    id: 'monitoring',
    label: 'Surveillances',
    icon: 'fas fa-chart-line',
    path: '/operator/monitoring',
    permissions: ['cases.view.all'],
    badge: 8,
    children: [
      {
        id: 'monitoring-delays',
        label: 'Retards',
        icon: 'fas fa-clock',
        path: '/operator/monitoring/delays',
        permissions: ['cases.view.all']
      },
      {
        id: 'monitoring-reminders',
        label: 'Relances',
        icon: 'fas fa-bell',
        path: '/operator/monitoring/reminders',
        permissions: ['alerts.view']
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
    id: 'organizations',
    label: 'Gestion référencements',
    icon: 'fas fa-building',
    path: '/operator/organizations',
    permissions: ['organizations.contact'],
    children: [
      {
        id: 'org-referrals',
        label: 'Référencements',
        icon: 'fas fa-share-alt',
        path: '/operator/organizations/referrals',
        permissions: ['referrals.manage']
      },
      {
        id: 'org-followup',
        label: 'Suivi',
        icon: 'fas fa-eye',
        path: '/operator/organizations/follow-up',
        permissions: ['organizations.contact']
      }
    ]
  },
  // Account section custom item to preserve prior 'Alertes'
  {
    id: 'account-alerts',
    label: 'Alertes',
    icon: 'fas fa-bell',
    path: '/operator/alerts',
    permissions: ['alerts.view'],
    badge: 8
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

  // Conserved for future navigation hooks if needed
  // const handleTriageClick = () => {
  //   console.log('Aller au triage');
  // };

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
            <Loader2 className="w-10 h-10 text-gray-400 mb-4 animate-spin inline-block" />
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
      {/* Bannière alertes urgentes (conservée) */}
      <div className="mb-6">
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="flex items-center">
            <AlertTriangle className="w-5 h-5 text-red-600 mr-3" />
            <div className="flex-1">
              <p className="font-medium text-red-900">8 cas urgents nécessitent votre attention immédiate</p>
              <p className="text-sm text-red-700">Dernière mise à jour : il y a 5 minutes</p>
            </div>
            <button 
              className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors"
            >
              Voir le triage
            </button>
          </div>
        </div>
      </div>
      {/* (Alertes & Rappels sera affiché plus bas à côté de la Performance) */}

      {/* Indicateurs principaux */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-7 gap-4 sm:gap-6 mb-8 transition-all duration-300 ease-in-out">
        <StatsCard title="Nouveaux (24h)" value={15} icon="fas fa-inbox" color="blue" />
        <StatsCard title="Actions requises" value={8} icon="fas fa-exclamation-triangle" color="yellow" />
        <StatsCard title="Traités auj." value={42} icon="fas fa-check-circle" color="green" />
        <StatsCard title="Critiques" value={5} icon="fas fa-circle" color="red" />
        <StatsCard title="Cas actifs" value={stats.activeCases} icon="fas fa-folder" color="blue" />
        <StatsCard title="Temps réponse" value={`${stats.responseTime}h`} icon="fas fa-clock" color="purple" />
        <StatsCard title="APS dispo" value={`12/15`} icon="fas fa-users" color="indigo" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
        {/* Activité en temps réel */}
        <div className="lg:col-span-2">
          <RecentCases
            cases={recentCases}
            title="Nouveaux signalements"
            onViewAll={() => console.log('Voir tous les signalements')}
            onCaseClick={handleCaseClick}
          />
        </div>

        {/* Actions urgentes (à côté des nouveaux signalements) */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">Actions urgentes</h3>
          <div className="space-y-4">
            <div className="border border-red-200 bg-red-50 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <h4 className="font-medium text-red-900">Cas urgents</h4>
                <span className="bg-red-600 text-white text-xs px-2 py-1 rounded-full">8</span>
              </div>
              <p className="text-sm text-red-700 mb-3">Cas nécessitant attention immédiate</p>
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

            <div className="border border-orange-200 bg-orange-50 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <h4 className="font-medium text-orange-900">Cas en attente de référencement</h4>
                <span className="bg-orange-600 text-white text-xs px-2 py-1 rounded-full">5</span>
              </div>
              <p className="text-sm text-orange-700 mb-3">Sélectionner et référencer vers une organisation</p>
              <button className="w-full bg-orange-600 text-white py-2 rounded-lg hover:bg-orange-700 transition-colors">
                Assigner
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Ligne suivante: Performance aujourd'hui + Alertes & Rappels côte à côte */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        {/* Performance aujourd'hui */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">
            Performance aujourd'hui
          </h3>
          <div className="space-y-4 text-sm">
            <div className="flex items-start justify-between">
              <div className="inline-flex items-center text-gray-700 dark:text-gray-300">
                <Clock className="w-4 h-4 mr-2" /> Temps moyen réponse:
              </div>
              <div className="text-right">
                <div>1 h 12 min</div>
                <div className="text-xs text-gray-500">Objectif: &lt; 2h <CheckCircle className="inline w-4 h-4 text-green-600 ml-1" /></div>
              </div>
            </div>
            <div className="flex items-start justify-between">
              <span className="text-gray-700 dark:text-gray-300">Cas traités: 42</span>
              <span className="text-xs text-gray-500">Objectif: 40-50 <CheckCircle className="inline w-4 h-4 text-green-600 ml-1" /></span>
            </div>
            <div className="flex items-start justify-between">
              <span className="text-gray-700 dark:text-gray-300">APS assignés: 38</span>
              <span className="text-xs text-gray-500">Taux: 90% <CheckCircle className="inline w-4 h-4 text-green-600 ml-1" /></span>
            </div>
          </div>
        </div>

        {/* Alertes & Rappels */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6 inline-flex items-center">
            <AlertTriangle className="w-5 h-5 text-yellow-600 mr-2" />
            Alertes & Rappels
          </h3>
          <ul className="space-y-3 text-sm">
            <li className="flex items-start justify-between">
              <div className="flex items-start">
                <Circle className="w-3.5 h-3.5 text-yellow-400 mr-2 mt-1" />
                <span className="text-gray-700 dark:text-gray-300">3 cas sans mise à jour depuis 7+ jours</span>
              </div>
              <div className="text-right space-x-2">
                <button className="text-blue-600 hover:underline text-xs">Voir les cas</button>
                <button className="text-blue-600 hover:underline text-xs">Envoyer relance automatique</button>
              </div>
            </li>
            <li className="flex items-start justify-between">
              <div className="flex items-start">
                <Circle className="w-3.5 h-3.5 text-yellow-400 mr-2 mt-1" />
                <span className="text-gray-700 dark:text-gray-300">5 référencements en attente de réponse (&gt;48h)</span>
              </div>
              <div className="text-right space-x-2">
                <button className="text-blue-600 hover:underline text-xs">Voir détails</button>
                <button className="text-blue-600 hover:underline text-xs">Relancer organisations</button>
              </div>
            </li>
            <li className="flex items-start justify-between">
              <div className="flex items-start">
                <Circle className="w-3.5 h-3.5 text-orange-500 mr-2 mt-1" />
                <span className="text-gray-700 dark:text-gray-300">2 APS ont atteint 15 cas actifs (limite recommandée)</span>
              </div>
              <div className="text-right space-x-2">
                <button className="text-blue-600 hover:underline text-xs">Voir répartition</button>
                <button className="text-blue-600 hover:underline text-xs">Réassigner certains cas</button>
              </div>
            </li>
          </ul>
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
              <BarChart2 className="w-8 h-8 mb-4 inline-block" />
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
        <ResponsiveGrid variant="modules" gap="medium">
          {OperatorModules.map((module) => (
            <ModuleCard
              key={module.id}
              module={module}
              onClick={() => handleModuleClick(module.id)}
            />
          ))}
        </ResponsiveGrid>
      </div>
    </DashboardLayout>
  );
};