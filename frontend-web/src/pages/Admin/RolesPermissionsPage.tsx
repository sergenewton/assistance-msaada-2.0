import React from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { NavigationItem } from '@/types/dashboard';
import { Shield, Plus, Edit3 } from 'lucide-react';

const AdminNavigation: NavigationItem[] = [
  {
    id: 'dashboard',
    label: 'Tableau de bord',
    icon: 'fas fa-tachometer-alt',
    path: '/dashboard/admin',
    permissions: ['dashboard.view'],
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
        permissions: ['users.manage'],
      },
      {
        id: 'users-roles',
        label: 'Rôles et permissions',
        icon: 'fas fa-user-shield',
        path: '/admin/users/roles',
        permissions: ['users.manage'],
      },
    ],
  },
];

interface RoleItem {
  id: string;
  name: string;
  description?: string;
  permissions: string[];
}

const mockRoles: RoleItem[] = [
  {
    id: 'admin',
    name: 'Administrateur',
    description: "Accès complet à toutes les fonctionnalités.",
    permissions: [
      'users.manage',
      'system.configure',
      'organizations.manage',
      'audit.logs.view',
      'backups.manage',
    ],
  },
  {
    id: 'operateur',
    name: 'Opérateur',
    description: "Gère les appels et le triage des cas.",
    permissions: [
      'cases.view.all',
      'cases.triage',
      'cases.assign',
    ],
  },
];

export const RolesPermissionsPage: React.FC = () => {
  return (
    <DashboardLayout
      title="Rôles & Permissions"
      subtitle="Configurer les rôles et les droits d'accès"
      navigationItems={AdminNavigation}
      userRole="admin"
    >
      {/* Header actions */}
      <div className="mb-6 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Shield className="w-5 h-5 text-green-600" />
          <span className="text-gray-700">Gestion centralisée des rôles</span>
        </div>
        <button className="inline-flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
          <Plus className="w-4 h-4 mr-2" />
          Nouveau rôle
        </button>
      </div>

      {/* Roles list */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {mockRoles.map((role) => (
          <div key={role.id} className="bg-white rounded-lg border border-gray-200 p-4">
            <div className="flex items-start justify-between">
              <div>
                <h3 className="text-base font-semibold text-gray-900">{role.name}</h3>
                {role.description && (
                  <p className="text-sm text-gray-600 mt-1">{role.description}</p>
                )}
              </div>
              <button className="text-gray-500 hover:text-gray-700">
                <Edit3 className="w-4 h-4" />
              </button>
            </div>
            <div className="mt-3">
              <p className="text-xs font-medium text-gray-500 mb-2">Permissions</p>
              <div className="flex flex-wrap gap-2">
                {role.permissions.map((perm) => (
                  <span key={perm} className="inline-flex items-center px-2 py-1 rounded-md text-xs bg-gray-100 text-gray-800">
                    {perm}
                  </span>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-4 text-xs text-gray-500">
        Démonstration. L'intégration API (GET /api/v1/admin/roles) sera ajoutée ultérieurement.
      </div>
    </DashboardLayout>
  );
};

export default RolesPermissionsPage;
