import React, { useMemo, useState } from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { NavigationItem } from '@/types/dashboard';
import { Search, Filter, UserPlus, MoreVertical } from 'lucide-react';

// Minimal admin navigation focused on Users section
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

// Temporary mock data until API integration
interface UserRow {
  id: string;
  name: string;
  email: string;
  role: string;
  status: 'active' | 'inactive' | 'pending';
}

const mockUsers: UserRow[] = [
  { id: '1', name: 'Admin Système', email: 'admin@msaada.cd', role: 'admin', status: 'active' },
  { id: '2', name: 'Opérateur 1', email: 'operateur1@msaada.cd', role: 'operateur', status: 'active' },
  { id: '3', name: 'Superviseur 1', email: 'superviseur@msaada.cd', role: 'superviseur', status: 'inactive' },
];

export const UsersListPage: React.FC = () => {
  const [query, setQuery] = useState('');
  const [status, setStatus] = useState<'all' | 'active' | 'inactive' | 'pending'>('all');

  const filtered = useMemo(() => {
    return mockUsers.filter((u) => {
      const matchQuery = `${u.name} ${u.email} ${u.role}`.toLowerCase().includes(query.toLowerCase());
      const matchStatus = status === 'all' ? true : u.status === status;
      return matchQuery && matchStatus;
    });
  }, [query, status]);

  return (
    <DashboardLayout
      title="Utilisateurs"
      subtitle="Liste des utilisateurs et gestion de l'accès"
      navigationItems={AdminNavigation}
      userRole="admin"
    >
      {/* Actions bar */}
      <div className="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        <div className="flex items-center gap-2 w-full sm:w-auto">
          <div className="relative w-full sm:w-72">
            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Rechercher par nom, email, rôle..."
              className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
          <div className="relative">
            <select
              className="pl-3 pr-8 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 appearance-none"
              value={status}
              onChange={(e) => setStatus(e.target.value as any)}
            >
              <option value="all">Tous les statuts</option>
              <option value="active">Actifs</option>
              <option value="inactive">Inactifs</option>
              <option value="pending">En attente</option>
            </select>
            <Filter className="w-4 h-4 text-gray-400 absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none" />
          </div>
        </div>
        <button className="inline-flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
          <UserPlus className="w-4 h-4 mr-2" />
          Nouvel utilisateur
        </button>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nom</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rôle</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Statut</th>
              <th className="px-6 py-3" />
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {filtered.map((u) => (
              <tr key={u.id} className="hover:bg-gray-50">
                <td className="px-6 py-3 text-sm text-gray-900 font-medium">{u.name}</td>
                <td className="px-6 py-3 text-sm text-gray-600">{u.email}</td>
                <td className="px-6 py-3 text-sm">
                  <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                    {u.role}
                  </span>
                </td>
                <td className="px-6 py-3 text-sm">
                  {u.status === 'active' && (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">Actif</span>
                  )}
                  {u.status === 'inactive' && (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">Inactif</span>
                  )}
                  {u.status === 'pending' && (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">En attente</span>
                  )}
                </td>
                <td className="px-6 py-3 text-right">
                  <button className="p-2 text-gray-500 hover:text-gray-700">
                    <MoreVertical className="w-4 h-4" />
                  </button>
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <td colSpan={5} className="px-6 py-8 text-center text-gray-500">
                  Aucun utilisateur ne correspond à votre recherche.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Footer */}
      <div className="mt-4 text-xs text-gray-500">
        Vue de démonstration. L'intégration API (GET /api/v1/admin/users) viendra ensuite.
      </div>
    </DashboardLayout>
  );
};

export default UsersListPage;
