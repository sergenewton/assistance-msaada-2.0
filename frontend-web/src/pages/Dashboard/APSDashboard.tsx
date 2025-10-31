import React, { useState, useEffect } from 'react';
import { Loader2, CirclePlus, ChevronRight, Share2, FileText, Calendar, ClipboardCheck } from 'lucide-react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { StatsCard } from '@/components/Dashboard/StatsCard';
import { ModuleCard } from '@/components/Dashboard/ModuleCard';
import { RecentCases } from '@/components/Dashboard/RecentCases';
import { ResponsiveGrid } from '@/components/Dashboard/ResponsiveGrid';
import { NavigationItem, Module, DashboardStats, CaseOverview } from '@/types/dashboard';

const APSNavigation: NavigationItem[] = [
  {
    id: 'dashboard',
    label: 'Tableau de bord',
    icon: 'fas fa-tachometer-alt',
    path: '/aps/dashboard',
    permissions: ['dashboard.view'],
    isActive: true
  },
  {
    id: 'cases',
    label: 'Mes cas',
    icon: 'fas fa-folder-open',
    path: '/aps/cases',
    permissions: ['cases.view.assigned'],
    badge: 5,
    children: [
      {
        id: 'cases-assigned',
        label: 'Cas assignés',
        icon: 'fas fa-user-check',
        path: '/aps/cases/assigned',
        permissions: ['cases.view.assigned'],
        badge: 3
      },
      {
        id: 'cases-in-progress',
        label: 'En cours',
        icon: 'fas fa-spinner',
        path: '/aps/cases/in-progress',
        permissions: ['cases.view.assigned'],
        badge: 2
      }
    ]
  },
  {
    id: 'communication',
    label: 'Communication',
    icon: 'fas fa-comments',
    path: '/aps/communication',
    permissions: ['communication.secure.chat'],
    badge: 2
  },
  {
    id: 'sessions',
    label: 'Séances',
    icon: 'fas fa-calendar-alt',
    path: '/aps/sessions',
    permissions: ['cases.document.sessions'],
    children: [
      {
        id: 'sessions-schedule',
        label: 'Planifier',
        icon: 'fas fa-calendar-plus',
        path: '/aps/sessions/schedule',
        permissions: ['cases.document.sessions']
      },
      {
        id: 'sessions-history',
        label: 'Historique',
        icon: 'fas fa-history',
        path: '/aps/sessions/history',
        permissions: ['cases.document.sessions']
      }
    ]
  },
  {
    id: 'reports',
    label: 'Rapports',
    icon: 'fas fa-chart-line',
    path: '/aps/reports',
    permissions: ['reports.progress.generate'],
    children: [
      {
        id: 'reports-progress',
        label: 'Rapports d\'étape',
        icon: 'fas fa-file-alt',
        path: '/aps/reports/progress',
        permissions: ['reports.progress.generate']
      },
      {
        id: 'reports-referrals',
        label: 'Référencements',
        icon: 'fas fa-share-alt',
        path: '/aps/reports/referrals',
        permissions: ['referrals.request']
      }
    ]
  },
  {
    id: 'profile',
    label: 'Mon profil',
    icon: 'fas fa-user-cog',
    path: '/aps/profile',
    permissions: ['profile.manage']
  }
];

const APSModules: Module[] = [
  {
    id: 'case-management',
    name: 'Gestion des Cas',
    description: 'Suivre et gérer vos cas assignés, mettre à jour les statuts et documenter les interventions.',
    icon: 'fas fa-folder-open',
    color: '#3B82F6',
    permissions: ['cases.view.assigned'],
    isActive: true
  },
  {
    id: 'secure-communication',
    name: 'Communication Sécurisée',
    description: 'Communiquer de manière sécurisée avec les survivantes et les autres intervenants.',
    icon: 'fas fa-shield-alt',
    color: '#10B981',
    permissions: ['communication.secure.chat'],
    isActive: true
  },
  {
    id: 'reports-statistics',
    name: 'Rapports et Statistiques',
    description: 'Générer des rapports d\'étape et consulter les statistiques de vos interventions.',
    icon: 'fas fa-chart-bar',
    color: '#8B5CF6',
    permissions: ['reports.progress.generate'],
    isActive: true
  },
  {
    id: 'feedback-evaluation',
    name: 'Feedback et Évaluation',
    description: 'Recueillir les retours des survivantes et évaluer l\'efficacité des interventions.',
    icon: 'fas fa-star',
    color: '#F59E0B',
    permissions: ['feedback.collect'],
    isActive: false
  }
];

// Mock data - À remplacer par des appels API réels
const mockStats: DashboardStats = {
  totalCases: 24,
  activeCases: 8,
  urgentCases: 3,
  completedCases: 16,
  pendingActions: 5,
  responseTime: 4.2
};

const mockRecentCases: CaseOverview[] = [
  {
    id: '1',
    trackingNumber: 'MSA2024001',
    urgency: 'high',
    status: 'in-progress',
    type: 'Violence psychologique',
    createdAt: '2024-10-28T09:00:00Z',
    lastUpdate: '2024-10-30T14:30:00Z',
    assignedTo: 'Marie Dupont (APS)'
  },
  {
    id: '2',
    trackingNumber: 'MSA2024015',
    urgency: 'moderate',
    status: 'new',
    type: 'Violence économique',
    createdAt: '2024-10-29T16:20:00Z',
    lastUpdate: '2024-10-29T16:20:00Z',
    assignedTo: 'Marie Dupont (APS)'
  },
  {
    id: '3',
    trackingNumber: 'MSA2024008',
    urgency: 'critical',
    status: 'pending',
    type: 'Violence physique',
    createdAt: '2024-10-27T11:15:00Z',
    lastUpdate: '2024-10-30T10:00:00Z',
    assignedTo: 'Marie Dupont (APS)'
  }
];

export const APSDashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats>(mockStats);
  const [recentCases, setRecentCases] = useState<CaseOverview[]>(mockRecentCases);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    // Simuler le chargement des données
    setIsLoading(true);
    setTimeout(() => {
      setStats(mockStats);
      setRecentCases(mockRecentCases);
      setIsLoading(false);
    }, 1000);
  }, []);

  const handleModuleClick = (moduleId: string) => {
    // Navigation vers le module
    console.log(`Naviguer vers le module: ${moduleId}`);
  };

  const handleCaseClick = (caseId: string) => {
    // Navigation vers le détail du cas
    console.log(`Ouvrir le cas: ${caseId}`);
  };

  const handleViewAllCases = () => {
    // Navigation vers la liste complète des cas
    console.log('Voir tous les cas');
  };

  if (isLoading) {
    return (
      <DashboardLayout
        title="Tableau de bord APS"
        subtitle="Agent Psychosocial"
        navigationItems={APSNavigation}
        userRole="aps"
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
      title="Tableau de bord APS"
      subtitle="Bienvenue dans votre espace de travail d'Agent Psychosocial"
      navigationItems={APSNavigation}
      userRole="aps"
    >
      {/* Statistiques rapides */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-4 sm:gap-6 mb-8 transition-all duration-300 ease-in-out">
        <StatsCard
          title="Cas assignés"
          value={stats.activeCases}
          icon="fas fa-folder-open"
          color="blue"
          trend={{ value: 12, isPositive: true }}
          onClick={() => handleModuleClick('case-management')}
        />
        <StatsCard
          title="Cas urgents"
          value={stats.urgentCases}
          icon="fas fa-exclamation-triangle"
          color="red"
          onClick={() => handleCaseClick('urgent')}
        />
        <StatsCard
          title="Cas terminés"
          value={stats.completedCases}
          icon="fas fa-check-circle"
          color="green"
        />
        <StatsCard
          title="Actions en attente"
          value={stats.pendingActions}
          icon="fas fa-clock"
          color="yellow"
          onClick={() => handleViewAllCases()}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 sm:gap-8 mb-8 transition-all duration-300 ease-in-out">
        {/* Cas récents */}
        <RecentCases
          cases={recentCases}
          title="Mes cas récents"
          onViewAll={handleViewAllCases}
          onCaseClick={handleCaseClick}
        />

        {/* Actions rapides */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">
            Actions rapides
          </h3>
          <div className="space-y-4">
            <button className="w-full flex items-center justify-between p-4 text-left bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors">
              <div className="flex items-center">
                <CirclePlus className="w-5 h-5 text-blue-600 mr-3" />
                <div>
                  <p className="font-medium text-blue-900">Nouvelle séance</p>
                  <p className="text-sm text-blue-600">Documenter une séance d'accompagnement</p>
                </div>
              </div>
              <ChevronRight className="w-4 h-4 text-blue-600" />
            </button>

            <button className="w-full flex items-center justify-between p-4 text-left bg-green-50 hover:bg-green-100 rounded-lg transition-colors">
              <div className="flex items-center">
                <Share2 className="w-5 h-5 text-green-600 mr-3" />
                <div>
                  <p className="font-medium text-green-900">Demander un référencement</p>
                  <p className="text-sm text-green-600">Solliciter une prise en charge complémentaire</p>
                </div>
              </div>
              <ChevronRight className="w-4 h-4 text-green-600" />
            </button>

            <button className="w-full flex items-center justify-between p-4 text-left bg-purple-50 hover:bg-purple-100 rounded-lg transition-colors">
              <div className="flex items-center">
                <FileText className="w-5 h-5 text-purple-600 mr-3" />
                <div>
                  <p className="font-medium text-purple-900">Générer un rapport</p>
                  <p className="text-sm text-purple-600">Créer un rapport d'étape</p>
                </div>
              </div>
              <ChevronRight className="w-4 h-4 text-purple-600" />
            </button>
          </div>
        </div>
      </div>

      {/* Modules disponibles */}
      <div className="mb-8">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">
          Modules disponibles
        </h3>
        <ResponsiveGrid variant="modules" gap="medium">
          {APSModules.map((module) => (
            <ModuleCard
              key={module.id}
              module={module}
              onClick={() => handleModuleClick(module.id)}
            />
          ))}
        </ResponsiveGrid>
      </div>

      {/* Rappels et notifications */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Rappels du jour
        </h3>
        <div className="space-y-3">
          <div className="flex items-center p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
            <Calendar className="w-5 h-5 text-yellow-600 mr-3" />
            <div>
              <p className="font-medium text-yellow-900">Séance programmée</p>
              <p className="text-sm text-yellow-700">Rendez-vous avec Mme X à 14h00</p>
            </div>
          </div>
          <div className="flex items-center p-3 bg-blue-50 border border-blue-200 rounded-lg">
            <ClipboardCheck className="w-5 h-5 text-blue-600 mr-3" />
            <div>
              <p className="font-medium text-blue-900">Rapport en attente</p>
              <p className="text-sm text-blue-700">Rapport d'étape pour le cas #MSA2024001</p>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
};