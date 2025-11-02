import React, { useMemo, useState, useEffect } from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { NavigationItem } from '@/types/dashboard';
import { Search, Filter, UserPlus, Loader2, AlertCircle, CheckCircle } from 'lucide-react';
import { adminApiService, User } from '@/services/adminApiService';
import { UserFormModal } from '@/components/Admin/UserFormModal';
import { DeleteUserModal } from '@/components/Admin/DeleteUserModal';

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

  // Modal states
  const [showFormModal, setShowFormModal] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [selectedUserEmail, setSelectedUserEmail] = useState<string | null>(null);
  const [formMode, setFormMode] = useState<'create' | 'edit'>('create');
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

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

  // CRUD Handlers
  const handleCreateUser = () => {
    setFormMode('create');
    setSelectedUserId(null);
    setShowFormModal(true);
  };

  const handleEditUser = (userId: string) => {
    setFormMode('edit');
    setSelectedUserId(userId);
    setShowFormModal(true);
  };

  const handleDeleteUser = (userId: string, userEmail: string) => {
    setSelectedUserId(userId);
    setSelectedUserEmail(userEmail);
    setShowDeleteModal(true);
  };

  const handleToggleActive = async (userId: string) => {
    try {
      const response = await adminApiService.toggleUserActive(userId);
      if (response.success) {
        setSuccessMessage('Statut utilisateur modifié avec succès');
        setTimeout(() => setSuccessMessage(null), 3000);
        loadUsers(); // Reload to refresh the list
      }
    } catch (error) {
      console.error('Error toggling user status:', error);
    }
  };

  const handleFormSuccess = () => {
    setSuccessMessage(
      formMode === 'create' 
        ? 'Utilisateur créé avec succès' 
        : 'Utilisateur modifié avec succès'
    );
    setTimeout(() => setSuccessMessage(null), 3000);
    loadUsers();
  };

  const handleDeleteSuccess = () => {
    setSuccessMessage('Utilisateur supprimé avec succès');
    setTimeout(() => setSuccessMessage(null), 3000);
    loadUsers();
  };

  return (
    <DashboardLayout
      title="Utilisateurs"
      subtitle="Liste des utilisateurs et gestion de l'accès"
      navigationItems={AdminNavigation}
      userRole="admin"
    >
      {/* Success Message */}
      {successMessage && (
        <div className="fixed top-4 right-4 bg-green-50 border border-green-200 rounded-lg p-4 shadow-lg z-50 flex items-center">
          <CheckCircle className="w-5 h-5 text-green-600 mr-2" />
          <span className="text-green-800">{successMessage}</span>
        </div>
      )}

      {/* Header with navigation buttons */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <button
              onClick={() => window.location.href = '/dashboard/admin'}
              className="inline-flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
            >
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
              </svg>
              Tableau de bord
            </button>
            <button
              className="inline-flex items-center px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
            >
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
              </svg>
              Gestion des Permissions
            </button>
            <button
              onClick={() => window.location.href = '/admin/users/roles'}
              className="inline-flex items-center px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors"
            >
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              Gestion des Rôles
            </button>
          </div>
          
          <button 
            onClick={handleCreateUser}
            className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors shadow-sm"
          >
            <UserPlus className="w-4 h-4 mr-2" />
            Ajouter un utilisateur
          </button>
        </div>

        {/* Stats and filters row */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4 text-sm">
            <div className="flex items-center gap-2">
              <svg className="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
              </svg>
              <span className="text-gray-700 font-medium">{totalUsers} utilisateurs</span>
            </div>
            <div className="flex items-center gap-2">
              <svg className="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span className="text-gray-700">{users.filter(u => u.is_active).length} actifs</span>
            </div>
          </div>

          <div className="flex items-center gap-2 w-full sm:w-auto max-w-md">
            <div className="relative flex-1">
              <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Rechercher par nom, email, rôle..."
                className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
              />
            </div>
            <div className="relative">
              <select
                className="pl-3 pr-8 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 appearance-none bg-white"
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
        </div>
      </div>

      {/* Table */}
      <div className="w-full">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200">
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
            <div className="overflow-x-auto">
              <table className="w-full min-w-[1000px] table-auto">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">NOM</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">EMAIL</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">RÔLE</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">STATUT</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">2FA</th>
                    <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">ACTIONS</th>
                  </tr>
                </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filtered.map((u) => (
                <tr key={u.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {u.full_name}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="text-sm text-gray-900">{u.email}</span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-medium ${
                      u.role === 'admin' ? 'bg-blue-100 text-blue-800' :
                      u.role === 'operateur' ? 'bg-purple-100 text-purple-800' :
                      u.role === 'superviseur' ? 'bg-green-100 text-green-800' :
                      'bg-gray-100 text-gray-800'
                    }`}>
                      {u.role_display_name || u.role}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {u.is_active ? (
                      <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        Actif
                      </span>
                    ) : (
                      <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                        Inactif
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-center">
                    <button
                      className="inline-flex items-center justify-center px-2 py-1 text-xs text-gray-500 hover:text-gray-700"
                      title={u.two_factor_enabled ? '2FA activée' : '2FA désactivée'}
                    >
                      {u.two_factor_enabled ? (
                        <svg className="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                        </svg>
                      ) : (
                        <span className="text-gray-400">Désactivée</span>
                      )}
                    </button>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-center">
                    <div className="flex items-center justify-center gap-2">
                      <button
                        onClick={() => handleEditUser(u.id)}
                        className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                        title="Voir/Modifier"
                      >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                        </svg>
                      </button>
                      <button
                        onClick={() => handleEditUser(u.id)}
                        className="p-2 text-gray-600 hover:bg-gray-50 rounded-lg transition-colors"
                        title="Éditer"
                      >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                      </button>
                      <button
                        onClick={() => handleToggleActive(u.id)}
                        className={`p-2 rounded-lg transition-colors ${
                          u.is_active 
                            ? 'text-purple-600 hover:bg-purple-50' 
                            : 'text-green-600 hover:bg-green-50'
                        }`}
                        title={u.is_active ? 'Désactiver' : 'Activer'}
                      >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                        </svg>
                      </button>
                      <button
                        onClick={() => handleDeleteUser(u.id, u.email)}
                        className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                        title="Supprimer"
                      >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                      </button>
                    </div>
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
            </div>
          )}
        </div>
      </div>

      {/* Modals */}
      <UserFormModal
        isOpen={showFormModal}
        onClose={() => setShowFormModal(false)}
        onSuccess={handleFormSuccess}
        userId={selectedUserId}
        mode={formMode}
      />

      <DeleteUserModal
        isOpen={showDeleteModal}
        onClose={() => setShowDeleteModal(false)}
        onSuccess={handleDeleteSuccess}
        userId={selectedUserId}
        userEmail={selectedUserEmail}
      />

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
