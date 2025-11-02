import React, { useMemo, useState, useEffect } from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { NavigationItem } from '@/types/dashboard';
import { Search, Filter, UserPlus, MoreVertical, Loader2, AlertCircle } from 'lucide-react';
import { adminApiService, User } from '@/services/adminApiService';

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

export const UsersListPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [query, setQuery] = useState('');
  const [status, setStatus] = useState<'all' | 'active' | 'inactive'>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalUsers, setTotalUsers] = useState(0);
  const perPage = 15;

  // Load users from API
  useEffect(() => {
    loadUsers();
  }, [currentPage, status]);

  const loadUsers = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await adminApiService.getUsers({
        status: status === 'all' ? undefined : status,
        page: currentPage,
        per_page: perPage,
        sort_by: 'created_at',
        sort_order: 'desc',
      });

      if (response.success && response.data) {
        setUsers(response.data.data);
        setTotalPages(response.data.last_page);
        setTotalUsers(response.data.total);
      } else {
        setError(response.message || 'Erreur lors du chargement des utilisateurs');
      }
    } catch (err) {
      setError('Erreur de connexion au serveur');
      console.error('Error loading users:', err);
    } finally {
      setLoading(false);
    }
  };

  // Filter users by search query (client-side for now)
  const filtered = useMemo(() => {
    if (!query.trim()) return users;
    
    const lowerQuery = query.toLowerCase();
    return users.filter((u) => {
      const matchEmail = u.email?.toLowerCase().includes(lowerQuery);
      const matchRole = u.role?.toLowerCase().includes(lowerQuery);
      const matchId = u.id?.toLowerCase().includes(lowerQuery);
      return matchEmail || matchRole || matchId;
    });
  }, [users, query]);

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
        {loading && (
          <div className="flex items-center justify-center py-12">
            <Loader2 className="w-8 h-8 text-green-600 animate-spin" />
            <span className="ml-3 text-gray-600">Chargement des utilisateurs...</span>
          </div>
        )}
        
        {error && (
          <div className="flex items-center justify-center py-12 px-4">
            <AlertCircle className="w-6 h-6 text-red-600 mr-2" />
            <span className="text-red-600">{error}</span>
            <button 
              onClick={loadUsers}
              className="ml-4 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
            >
              Réessayer
            </button>
          </div>
        )}
        
        {!loading && !error && (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Téléphone</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rôle</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Statut</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Dernière connexion</th>
                <th className="px-6 py-3" />
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filtered.map((u) => (
                <tr key={u.id} className="hover:bg-gray-50">
                  <td className="px-6 py-3 text-sm text-gray-900 font-medium">{u.email}</td>
                  <td className="px-6 py-3 text-sm text-gray-600">{u.phone || '-'}</td>
                  <td className="px-6 py-3 text-sm">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                      {u.role_display_name || u.role}
                    </span>
                  </td>
                  <td className="px-6 py-3 text-sm">
                    {u.is_active ? (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        Actif
                      </span>
                    ) : (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                        Inactif
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-3 text-sm text-gray-600">
                    {u.last_login_at ? new Date(u.last_login_at).toLocaleDateString('fr-FR') : 'Jamais'}
                  </td>
                  <td className="px-6 py-3 text-right">
                    <button className="p-2 text-gray-500 hover:text-gray-700">
                      <MoreVertical className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && !loading && (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-gray-500">
                    Aucun utilisateur ne correspond à votre recherche.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        )}
      </div>

      {/* Pagination */}
      {!loading && !error && totalPages > 1 && (
        <div className="mt-4 flex items-center justify-between">
          <div className="text-sm text-gray-700">
            Affichage de {filtered.length} utilisateurs sur {totalUsers}
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
              disabled={currentPage === 1}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Précédent
            </button>
            <span className="px-4 py-2 text-sm text-gray-700">
              Page {currentPage} sur {totalPages}
            </span>
            <button
              onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
              disabled={currentPage === totalPages}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Suivant
            </button>
          </div>
        </div>
      )}

      {/* Footer */}
      <div className="mt-4 text-xs text-gray-500">
        Données chargées depuis l'API backend (GET /api/v1/admin/users)
      </div>
    </DashboardLayout>
  );
};

export default UsersListPage;
