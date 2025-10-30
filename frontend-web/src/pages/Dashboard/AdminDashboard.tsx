import React, { useState, useEffect } from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { StatsCard } from '@/components/Dashboard/StatsCard';
import { ModuleCard } from '@/components/Dashboard/ModuleCard';
import { NavigationItem, Module, DashboardStats } from '@/types/dashboard';

const AdminNavigation: NavigationItem[] = [
  {
    id: 'dashboard',
    label: 'Tableau de bord',
    icon: 'fas fa-tachometer-alt',
    path: '/admin/dashboard',
    permissions: ['dashboard.view'],
    isActive: true
  },
  {
    id: 'users',
    label: 'Gestion des utilisateurs',
    icon: 'fas fa-users',
    path: '/admin/users',
    permissions: ['users.manage'],
    children: [
      {
        id: 'users-list',
        label: 'Liste des utilisateurs',
        icon: 'fas fa-list',
        path: '/admin/users/list',
        permissions: ['users.manage']
      },
      {
        id: 'users-roles',
        label: 'Rôles et permissions',
        icon: 'fas fa-user-shield',
        path: '/admin/users/roles',
        permissions: ['users.manage']
      },
      {
        id: 'users-inactive',
        label: 'Comptes inactifs',
        icon: 'fas fa-user-slash',
        path: '/admin/users/inactive',
        permissions: ['users.manage'],
        badge: 3
      }
    ]
  },
  {
    id: 'organizations',
    label: 'Organisations partenaires',
    icon: 'fas fa-building',
    path: '/admin/organizations',
    permissions: ['organizations.manage'],
    children: [
      {
        id: 'organizations-list',
        label: 'Liste des organisations',
        icon: 'fas fa-list',
        path: '/admin/organizations/list',
        permissions: ['organizations.manage']
      },
      {
        id: 'organizations-pending',
        label: 'Demandes d\'adhésion',
        icon: 'fas fa-hourglass-half',
        path: '/admin/organizations/pending',
        permissions: ['organizations.manage'],
        badge: 2
      }
    ]
  },
  {
    id: 'system',
    label: 'Configuration système',
    icon: 'fas fa-cog',
    path: '/admin/system',
    permissions: ['system.configure'],
    children: [
      {
        id: 'system-settings',
        label: 'Paramètres généraux',
        icon: 'fas fa-sliders-h',
        path: '/admin/system/settings',
        permissions: ['system.configure']
      },
      {
        id: 'system-notifications',
        label: 'Notifications',
        icon: 'fas fa-bell',
        path: '/admin/system/notifications',
        permissions: ['alerts.configure']
      },
      {
        id: 'system-maintenance',
        label: 'Maintenance',
        icon: 'fas fa-tools',
        path: '/admin/system/maintenance',
        permissions: ['system.configure']
      }
    ]
  },
  {
    id: 'security',
    label: 'Sécurité et audit',
    icon: 'fas fa-shield-alt',
    path: '/admin/security',
    permissions: ['audit.logs.view'],
    children: [
      {
        id: 'security-logs',
        label: 'Logs d\'audit',
        icon: 'fas fa-clipboard-list',
        path: '/admin/security/logs',
        permissions: ['audit.logs.view']
      },
      {
        id: 'security-threats',
        label: 'Menaces détectées',
        icon: 'fas fa-exclamation-triangle',
        path: '/admin/security/threats',
        permissions: ['security.threats.view'],
        badge: 1
      },
      {
        id: 'security-backup',
        label: 'Sauvegardes',
        icon: 'fas fa-database',
        path: '/admin/security/backup',
        permissions: ['backups.manage']
      }
    ]
  },
  {
    id: 'content',
    label: 'Contenu sensibilisation',
    icon: 'fas fa-graduation-cap',
    path: '/admin/content',
    permissions: ['content.awareness.manage'],
    children: [
      {
        id: 'content-articles',
        label: 'Articles',
        icon: 'fas fa-newspaper',
        path: '/admin/content/articles',
        permissions: ['content.awareness.manage']
      },
      {
        id: 'content-resources',
        label: 'Ressources',
        icon: 'fas fa-file-alt',
        path: '/admin/content/resources',
        permissions: ['content.awareness.manage']
      }
    ]
  },
  {
    id: 'analytics',
    label: 'Analyses et rapports',
    icon: 'fas fa-chart-line',
    path: '/admin/analytics',
    permissions: ['data.export.anonymized'],
    children: [
      {
        id: 'analytics-global',
        label: 'Vue globale',
        icon: 'fas fa-globe',
        path: '/admin/analytics/global',
        permissions: ['data.export.anonymized']
      },
      {
        id: 'analytics-export',
        label: 'Export de données',
        icon: 'fas fa-download',
        path: '/admin/analytics/export',
        permissions: ['data.export.anonymized']
      }
    ]
  }
];

const AdminModules: Module[] = [
  {
    id: 'auth-security',
    name: 'Authentification & Sécurité',
    description: 'Gérer les utilisateurs, rôles, permissions et paramètres de sécurité avancée.',
    icon: 'fas fa-lock',
    color: '#DC2626',
    permissions: ['users.manage'],
    isActive: true
  },
  {
    id: 'case-management',
    name: 'Gestion des Cas',
    description: 'Vue d\'ensemble de tous les cas, supervision globale et intervention d\'urgence.',
    icon: 'fas fa-tasks',
    color: '#3B82F6',
    permissions: ['cases.view.all'],
    isActive: true
  },
  {
    id: 'awareness',
    name: 'Sensibilisation',
    description: 'Créer et gérer les contenus éducatifs, campagnes de sensibilisation.',
    icon: 'fas fa-graduation-cap',
    color: '#059669',
    permissions: ['content.awareness.manage'],
    isActive: true
  },
  {
    id: 'secure-communication',
    name: 'Communication Sécurisée',
    description: 'Superviser les communications, configurer les canaux sécurisés.',
    icon: 'fas fa-shield-alt',
    color: '#10B981',
    permissions: ['communication.monitor'],
    isActive: true
  },
  {
    id: 'alerts-notifications',
    name: 'Alertes et Notifications',
    description: 'Configurer les alertes système, notifications automatiques et escalades.',
    icon: 'fas fa-bell',
    color: '#F59E0B',
    permissions: ['alerts.configure'],
    isActive: true
  },
  {
    id: 'reports-statistics',
    name: 'Rapports et Statistiques',
    description: 'Accès complet aux analytics, génération de rapports stratégiques.',
    icon: 'fas fa-chart-bar',
    color: '#8B5CF6',
    permissions: ['reports.admin.access'],
    isActive: true
  },
  {
    id: 'feedback-evaluation',
    name: 'Feedback et Évaluation',
    description: 'Analyser les retours utilisateurs, évaluer la performance du système.',
    icon: 'fas fa-star',
    color: '#EC4899',
    permissions: ['feedback.analyze'],
    isActive: false
  },
  {
    id: 'advanced-security',
    name: 'Sécurité Avancée',
    description: 'Audit complet, détection d\'intrusions, gestion des incidents de sécurité.',
    icon: 'fas fa-user-shield',
    color: '#6B7280',
    permissions: ['security.advanced.manage'],
    isActive: true
  }
];

interface SystemHealth {
  status: 'healthy' | 'warning' | 'critical';
  uptime: number;
  activeUsers: number;
  systemLoad: number;
  diskUsage: number;
  memoryUsage: number;
  lastBackup: string;
}

// Mock data
const mockStats: DashboardStats = {
  totalCases: 1245,
  activeCases: 186,
  urgentCases: 23,
  completedCases: 1036,
  pendingActions: 15,
  responseTime: 2.4
};

const mockSystemHealth: SystemHealth = {
  status: 'healthy',
  uptime: 99.8,
  activeUsers: 45,
  systemLoad: 67,
  diskUsage: 78,
  memoryUsage: 65,
  lastBackup: '2024-10-30T02:00:00Z'
};

export const AdminDashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats>(mockStats);
  const [systemHealth, setSystemHealth] = useState<SystemHealth>(mockSystemHealth);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    setIsLoading(true);
    setTimeout(() => {
      setStats(mockStats);
      setSystemHealth(mockSystemHealth);
      setIsLoading(false);
    }, 1000);
  }, []);

  const handleModuleClick = (moduleId: string) => {
    console.log(`Naviguer vers le module: ${moduleId}`);
  };

  const formatUptime = (uptime: number) => {
    return `${uptime}%`;
  };

  const formatLastBackup = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'healthy': return 'text-green-600 bg-green-100';
      case 'warning': return 'text-yellow-600 bg-yellow-100';
      case 'critical': return 'text-red-600 bg-red-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'healthy': return 'Système sain';
      case 'warning': return 'Attention requise';
      case 'critical': return 'Intervention urgente';
      default: return 'Statut inconnu';
    }
  };

  if (isLoading) {
    return (
      <DashboardLayout
        title="Administration Système"
        subtitle="Administrateur"
        navigationItems={AdminNavigation}
        userRole="admin"
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
      title="Administration Système"
      subtitle="Panneau de contrôle principal - Accès administrateur complet"
      navigationItems={AdminNavigation}
      userRole="admin"
    >
      {/* État du système */}
      <div className="bg-gradient-to-r from-gray-50 to-blue-50 border border-gray-200 rounded-lg p-6 mb-8">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-900">État du système</h3>
          <span className={`px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(systemHealth.status)}`}>
            <i className="fas fa-circle mr-2"></i>
            {getStatusLabel(systemHealth.status)}
          </span>
        </div>
        
        <div className="grid grid-cols-2 md:grid-cols-6 gap-4">
          <div className="text-center">
            <p className="text-2xl font-bold text-green-600">{formatUptime(systemHealth.uptime)}</p>
            <p className="text-sm text-gray-600">Disponibilité</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-blue-600">{systemHealth.activeUsers}</p>
            <p className="text-sm text-gray-600">Utilisateurs actifs</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-purple-600">{systemHealth.systemLoad}%</p>
            <p className="text-sm text-gray-600">Charge système</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-orange-600">{systemHealth.diskUsage}%</p>
            <p className="text-sm text-gray-600">Disque utilisé</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-red-600">{systemHealth.memoryUsage}%</p>
            <p className="text-sm text-gray-600">Mémoire</p>
          </div>
          <div className="text-center">
            <p className="text-xs font-medium text-gray-900">{formatLastBackup(systemHealth.lastBackup)}</p>
            <p className="text-sm text-gray-600">Dernière sauvegarde</p>
          </div>
        </div>
      </div>

      {/* Statistiques globales */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-4 sm:gap-6 mb-8 transition-all duration-300 ease-in-out">
        <StatsCard
          title="Total des cas"
          value={stats.totalCases}
          icon="fas fa-database"
          color="blue"
          trend={{ value: 12, isPositive: true }}
        />
        <StatsCard
          title="Cas actifs"
          value={stats.activeCases}
          icon="fas fa-clock"
          color="purple"
        />
        <StatsCard
          title="Cas urgents"
          value={stats.urgentCases}
          icon="fas fa-exclamation-triangle"
          color="red"
        />
        <StatsCard
          title="Utilisateurs actifs"
          value={systemHealth.activeUsers}
          icon="fas fa-users"
          color="green"
        />
        <StatsCard
          title="Alertes système"
          value={5}
          icon="fas fa-bell"
          color="yellow"
        />
        <StatsCard
          title="Performances"
          value="Excellent"
          icon="fas fa-tachometer-alt"
          color="indigo"
        />
      </div>

      {/* Alertes administratives */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6 mb-8 transition-all duration-300 ease-in-out">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            <i className="fas fa-exclamation-triangle text-red-500 mr-2"></i>
            Alertes critiques
          </h3>
          <div className="space-y-3">
            <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
              <p className="font-medium text-red-900">Tentative d'intrusion détectée</p>
              <p className="text-sm text-red-700">IP: 192.168.1.100 - il y a 2h</p>
            </div>
            <div className="p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
              <p className="font-medium text-yellow-900">Espace disque faible</p>
              <p className="text-sm text-yellow-700">Serveur principal - 78% utilisé</p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            <i className="fas fa-tasks text-blue-500 mr-2"></i>
            Actions en attente
          </h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between p-3 bg-blue-50 border border-blue-200 rounded-lg">
              <div>
                <p className="font-medium text-blue-900">Demandes d'organisation</p>
                <p className="text-sm text-blue-700">2 nouvelles demandes</p>
              </div>
              <span className="bg-blue-600 text-white text-xs px-2 py-1 rounded-full">2</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-gray-50 border border-gray-200 rounded-lg">
              <div>
                <p className="font-medium text-gray-900">Comptes à valider</p>
                <p className="text-sm text-gray-700">3 comptes inactifs</p>
              </div>
              <span className="bg-gray-600 text-white text-xs px-2 py-1 rounded-full">3</span>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            <i className="fas fa-chart-line text-green-500 mr-2"></i>
            Métriques de performance
          </h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Temps de réponse API</span>
              <span className="text-sm font-medium text-green-600">125ms</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Disponibilité</span>
              <span className="text-sm font-medium text-green-600">99.8%</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Satisfaction utilisateur</span>
              <span className="text-sm font-medium text-green-600">4.7/5</span>
            </div>
          </div>
        </div>
      </div>

      {/* Actions rapides d'administration */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">
          Actions rapides d'administration
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 xl:grid-cols-6 gap-4 sm:gap-6 transition-all duration-300 ease-in-out">
          <button className="p-4 text-left bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors">
            <i className="fas fa-user-plus text-blue-600 text-2xl mb-2"></i>
            <p className="font-medium text-blue-900">Créer un utilisateur</p>
            <p className="text-sm text-blue-600">Ajouter un nouvel utilisateur</p>
          </button>
          
          <button className="p-4 text-left bg-green-50 hover:bg-green-100 rounded-lg transition-colors">
            <i className="fas fa-building text-green-600 text-2xl mb-2"></i>
            <p className="font-medium text-green-900">Nouvelle organisation</p>
            <p className="text-sm text-green-600">Enregistrer une organisation</p>
          </button>
          
          <button className="p-4 text-left bg-purple-50 hover:bg-purple-100 rounded-lg transition-colors">
            <i className="fas fa-database text-purple-600 text-2xl mb-2"></i>
            <p className="font-medium text-purple-900">Sauvegarde manuelle</p>
            <p className="text-sm text-purple-600">Lancer une sauvegarde</p>
          </button>
          
          <button className="p-4 text-left bg-orange-50 hover:bg-orange-100 rounded-lg transition-colors">
            <i className="fas fa-chart-bar text-orange-600 text-2xl mb-2"></i>
            <p className="font-medium text-orange-900">Rapport global</p>
            <p className="text-sm text-orange-600">Générer un rapport</p>
          </button>
        </div>
      </div>

      {/* Modules administratifs */}
      <div className="mb-8">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-6">
          Modules d'administration
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {AdminModules.map((module) => (
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