import React, { useState, useEffect } from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { StatsCard } from '@/components/Dashboard/StatsCard';
import { ModuleCard } from '@/components/Dashboard/ModuleCard';
import { RecentCases } from '@/components/Dashboard/RecentCases';
import { NavigationItem, Module, DashboardStats, CaseOverview } from '@/types/dashboard';

const OrganizationNavigation: NavigationItem[] = [
  {
    id: 'dashboard',
    label: 'Tableau de bord',
    icon: 'fas fa-tachometer-alt',
    path: '/organization/dashboard',
    permissions: ['dashboard.view'],
    isActive: true
  },
  {
    id: 'referrals',
    label: 'Cas référencés',
    icon: 'fas fa-inbox',
    path: '/organization/referrals',
    permissions: ['cases.view.referred'],
    badge: 7,
    children: [
      {
        id: 'referrals-pending',
        label: 'En attente',
        icon: 'fas fa-hourglass-half',
        path: '/organization/referrals/pending',
        permissions: ['cases.accept.decline'],
        badge: 4
      },
      {
        id: 'referrals-accepted',
        label: 'Acceptés',
        icon: 'fas fa-check-circle',
        path: '/organization/referrals/accepted',
        permissions: ['cases.view.referred'],
        badge: 3
      }
    ]
  },
  {
    id: 'cases',
    label: 'Mes cas actifs',
    icon: 'fas fa-folder-open',
    path: '/organization/cases',
    permissions: ['cases.view.referred'],
    children: [
      {
        id: 'cases-in-progress',
        label: 'En cours',
        icon: 'fas fa-spinner',
        path: '/organization/cases/in-progress',
        permissions: ['cases.update.progress']
      },
      {
        id: 'cases-completed',
        label: 'Terminés',
        icon: 'fas fa-check',
        path: '/organization/cases/completed',
        permissions: ['cases.view.referred']
      }
    ]
  },
  {
    id: 'documents',
    label: 'Documents',
    icon: 'fas fa-file-upload',
    path: '/organization/documents',
    permissions: ['documents.upload'],
    children: [
      {
        id: 'documents-upload',
        label: 'Télécharger',
        icon: 'fas fa-cloud-upload-alt',
        path: '/organization/documents/upload',
        permissions: ['documents.upload']
      },
      {
        id: 'documents-history',
        label: 'Historique',
        icon: 'fas fa-history',
        path: '/organization/documents/history',
        permissions: ['documents.view']
      }
    ]
  },
  {
    id: 'cross-referrals',
    label: 'Référencements croisés',
    icon: 'fas fa-share-alt',
    path: '/organization/cross-referrals',
    permissions: ['referrals.cross.propose']
  },
  {
    id: 'reports',
    label: 'Rapports',
    icon: 'fas fa-chart-bar',
    path: '/organization/reports',
    permissions: ['reports.view'],
    children: [
      {
        id: 'reports-activity',
        label: 'Activité',
        icon: 'fas fa-chart-line',
        path: '/organization/reports/activity',
        permissions: ['reports.view']
      },
      {
        id: 'reports-cases',
        label: 'Historique des cas',
        icon: 'fas fa-history',
        path: '/organization/reports/cases',
        permissions: ['cases.history.view']
      }
    ]
  }
];

const OrganizationModules: Module[] = [
  {
    id: 'case-management',
    name: 'Gestion des Cas',
    description: 'Recevoir, accepter/décliner et gérer les cas référencés vers votre organisation.',
    icon: 'fas fa-tasks',
    color: '#3B82F6',
    permissions: ['cases.view.referred'],
    isActive: true
  },
  {
    id: 'secure-communication',
    name: 'Communication Sécurisée',
    description: 'Communiquer de manière sécurisée avec le centre d\'écoute et les autres intervenants.',
    icon: 'fas fa-shield-alt',
    color: '#10B981',
    permissions: ['communication.secure'],
    isActive: true
  },
  {
    id: 'reports-statistics',
    name: 'Rapports et Statistiques',
    description: 'Consulter l\'historique de vos interventions et générer des rapports d\'activité.',
    icon: 'fas fa-chart-bar',
    color: '#8B5CF6',
    permissions: ['reports.view'],
    isActive: true
  },
  {
    id: 'feedback-evaluation',
    name: 'Feedback et Évaluation',
    description: 'Évaluer la qualité des référencements et fournir des retours sur les cas.',
    icon: 'fas fa-star',
    color: '#F59E0B',
    permissions: ['feedback.provide'],
    isActive: false
  }
];

// Mock data
const mockStats: DashboardStats = {
  totalCases: 34,
  activeCases: 8,
  urgentCases: 2,
  completedCases: 26,
  pendingActions: 4,
  responseTime: 1.8
};

const mockRecentCases: CaseOverview[] = [
  {
    id: '1',
    trackingNumber: 'MSA2024020',
    urgency: 'high',
    status: 'new',
    type: 'Aide juridique - Violence conjugale',
    createdAt: '2024-10-30T10:30:00Z',
    lastUpdate: '2024-10-30T10:30:00Z',
    assignedTo: 'Centre Juridique Lisanga'
  },
  {
    id: '2',
    trackingNumber: 'MSA2024018',
    urgency: 'moderate',
    status: 'in-progress',
    type: 'Soins médicaux - Certificat médical',
    createdAt: '2024-10-29T14:15:00Z',
    lastUpdate: '2024-10-30T09:20:00Z',
    assignedTo: 'Hôpital Général'
  },
  {
    id: '3',
    trackingNumber: 'MSA2024016',
    urgency: 'low',
    status: 'pending',
    type: 'Hébergement d\'urgence',
    createdAt: '2024-10-28T16:45:00Z',
    lastUpdate: '2024-10-29T11:30:00Z',
    assignedTo: 'Foyer d\'Accueil Tumaini'
  }
];

export const OrganizationDashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats>(mockStats);
  const [recentCases, setRecentCases] = useState<CaseOverview[]>(mockRecentCases);
  const [isLoading, setIsLoading] = useState(false);
  const [organizationInfo] = useState({
    name: 'Centre Juridique Lisanga',
    type: 'ONG - Assistance juridique',
    specialties: ['Droit de la famille', 'Violence conjugale', 'Aide juridictionnelle'],
    responseTime: 1.8,
    acceptanceRate: 95
  });

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

  const handleAcceptCase = (caseId: string) => {
    console.log(`Accepter le cas: ${caseId}`);
  };

  const handleDeclineCase = (caseId: string) => {
    console.log(`Décliner le cas: ${caseId}`);
  };

  if (isLoading) {
    return (
      <DashboardLayout
        title="Portail Partenaire"
        subtitle="Organisation"
        navigationItems={OrganizationNavigation}
        userRole="organisation"
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
      title="Portail Partenaire"
      subtitle={`${organizationInfo.name} - ${organizationInfo.type}`}
      navigationItems={OrganizationNavigation}
      userRole="organisation"
    >
      {/* Informations organisation */}
      <div className="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200 rounded-lg p-6 mb-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div className="md:col-span-2">
            <h3 className="text-lg font-semibold text-blue-900 mb-2">
              {organizationInfo.name}
            </h3>
            <p className="text-blue-700 mb-3">{organizationInfo.type}</p>
            <div className="flex flex-wrap gap-2">
              {organizationInfo.specialties.map((specialty, index) => (
                <span 
                  key={index}
                  className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm"
                >
                  {specialty}
                </span>
              ))}
            </div>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-blue-900">{organizationInfo.responseTime}h</p>
            <p className="text-sm text-blue-600">Temps de réponse moyen</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-blue-900">{organizationInfo.acceptanceRate}%</p>
            <p className="text-sm text-blue-600">Taux d'acceptation</p>
          </div>
        </div>
      </div>

      {/* Statistiques principales */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6 mb-8">
        <StatsCard
          title="Cas référencés"
          value={stats.totalCases}
          icon="fas fa-inbox"
          color="blue"
          trend={{ value: 15, isPositive: true }}
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
        />
        <StatsCard
          title="Terminés"
          value={stats.completedCases}
          icon="fas fa-check-circle"
          color="green"
        />
        <StatsCard
          title="En attente"
          value={stats.pendingActions}
          icon="fas fa-hourglass-half"
          color="yellow"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
        {/* Nouveaux référencements */}
        <div className="lg:col-span-2">
          <RecentCases
            cases={recentCases}
            title="Nouveaux référencements"
            onViewAll={() => console.log('Voir tous les référencements')}
            onCaseClick={handleCaseClick}
          />
        </div>

        {/* Actions rapides */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">
            Actions rapides
          </h3>
          <div className="space-y-4">
            <button className="w-full flex items-center justify-between p-4 text-left bg-green-50 hover:bg-green-100 rounded-lg transition-colors">
              <div className="flex items-center">
                <i className="fas fa-check-circle text-green-600 text-xl mr-3"></i>
                <div>
                  <p className="font-medium text-green-900">Accepter un référencement</p>
                  <p className="text-sm text-green-600">Confirmer la prise en charge</p>
                </div>
              </div>
              <i className="fas fa-chevron-right text-green-600"></i>
            </button>

            <button className="w-full flex items-center justify-between p-4 text-left bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors">
              <div className="flex items-center">
                <i className="fas fa-upload text-blue-600 text-xl mr-3"></i>
                <div>
                  <p className="font-medium text-blue-900">Télécharger un document</p>
                  <p className="text-sm text-blue-600">Certificat, rapport, PV...</p>
                </div>
              </div>
              <i className="fas fa-chevron-right text-blue-600"></i>
            </button>

            <button className="w-full flex items-center justify-between p-4 text-left bg-purple-50 hover:bg-purple-100 rounded-lg transition-colors">
              <div className="flex items-center">
                <i className="fas fa-edit text-purple-600 text-xl mr-3"></i>
                <div>
                  <p className="font-medium text-purple-900">Mettre à jour un cas</p>
                  <p className="text-sm text-purple-600">Statut, progression, notes...</p>
                </div>
              </div>
              <i className="fas fa-chevron-right text-purple-600"></i>
            </button>

            <button className="w-full flex items-center justify-between p-4 text-left bg-orange-50 hover:bg-orange-100 rounded-lg transition-colors">
              <div className="flex items-center">
                <i className="fas fa-share-alt text-orange-600 text-xl mr-3"></i>
                <div>
                  <p className="font-medium text-orange-900">Référencement croisé</p>
                  <p className="text-sm text-orange-600">Proposer à une autre organisation</p>
                </div>
              </div>
              <i className="fas fa-chevron-right text-orange-600"></i>
            </button>
          </div>
        </div>
      </div>

      {/* Référencements en attente de réponse */}
      {stats.pendingActions > 0 && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 mb-8">
          <div className="flex items-start justify-between">
            <div className="flex items-start">
              <i className="fas fa-hourglass-half text-yellow-600 text-xl mr-3 mt-1"></i>
              <div>
                <h3 className="font-semibold text-yellow-900 mb-2">
                  {stats.pendingActions} référencements en attente de votre réponse
                </h3>
                <p className="text-yellow-700 mb-4">
                  Ces cas nécessitent votre acceptation ou déclinaison avec justification.
                </p>
                <div className="space-y-2">
                  {recentCases.filter(c => c.status === 'new').map((caseItem) => (
                    <div key={caseItem.id} className="bg-white rounded-lg p-4 border border-yellow-200">
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="font-medium">#{caseItem.trackingNumber}</p>
                          <p className="text-sm text-gray-600">{caseItem.type}</p>
                        </div>
                        <div className="flex space-x-2">
                          <button 
                            onClick={() => handleAcceptCase(caseItem.id)}
                            className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors"
                          >
                            Accepter
                          </button>
                          <button 
                            onClick={() => handleDeclineCase(caseItem.id)}
                            className="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700 transition-colors"
                          >
                            Décliner
                          </button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modules disponibles */}
      <div className="mb-8">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">
          Modules disponibles
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {OrganizationModules.map((module) => (
            <ModuleCard
              key={module.id}
              module={module}
              onClick={() => handleModuleClick(module.id)}
            />
          ))}
        </div>
      </div>

      {/* Performances et métriques */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Évolution mensuelle
          </h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Cas traités</span>
              <div className="flex items-center">
                <div className="w-32 h-2 bg-gray-200 rounded-full mr-3">
                  <div className="w-24 h-2 bg-blue-500 rounded-full"></div>
                </div>
                <span className="text-sm font-medium">26/34</span>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Taux d'acceptation</span>
              <div className="flex items-center">
                <div className="w-32 h-2 bg-gray-200 rounded-full mr-3">
                  <div className="w-30 h-2 bg-green-500 rounded-full"></div>
                </div>
                <span className="text-sm font-medium">95%</span>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Temps de réponse</span>
              <div className="flex items-center">
                <div className="w-32 h-2 bg-gray-200 rounded-full mr-3">
                  <div className="w-20 h-2 bg-yellow-500 rounded-full"></div>
                </div>
                <span className="text-sm font-medium">1.8h</span>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Rappels et notifications
          </h3>
          <div className="space-y-3">
            <div className="flex items-center p-3 bg-blue-50 border border-blue-200 rounded-lg">
              <i className="fas fa-info-circle text-blue-600 mr-3"></i>
              <div>
                <p className="font-medium text-blue-900">Mise à jour requise</p>
                <p className="text-sm text-blue-700">Cas #MSA2024018 - Statut à mettre à jour</p>
              </div>
            </div>
            <div className="flex items-center p-3 bg-green-50 border border-green-200 rounded-lg">
              <i className="fas fa-check-circle text-green-600 mr-3"></i>
              <div>
                <p className="font-medium text-green-900">Document reçu</p>
                <p className="text-sm text-green-700">Certificat médical uploadé avec succès</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
};