import React from 'react';
import { Lock, LogIn, Shield, AlertTriangle, LogOut } from 'lucide-react';
import { useAuth } from '@/store/authStore';
import { APSDashboard } from './APSDashboard';
import { OperatorDashboard } from './OperatorDashboard';
import { OrganizationDashboard } from './OrganizationDashboard';
import { AdminDashboard } from './AdminDashboard';
import { SupervisorDashboard } from './SupervisorDashboard';
import { UserRole } from '@/types/dashboard';

/**
 * Composant intelligent qui affiche le bon dashboard selon le rôle de l'utilisateur
 */
export const RoleDashboard: React.FC = () => {
  const { user, isAuthenticated, isLoading } = useAuth();

  // Loading state
  if (isLoading || !user) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Chargement de votre espace de travail...</p>
        </div>
      </div>
    );
  }

  // Not authenticated
  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <Lock className="w-10 h-10 text-gray-400 mb-4 inline-block" />
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Accès non autorisé</h2>
          <p className="text-gray-600 mb-4">Veuillez vous connecter pour accéder à votre tableau de bord.</p>
          <a 
            href="/login" 
            className="inline-flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            <LogIn className="w-4 h-4 mr-2" />
            Se connecter
          </a>
        </div>
      </div>
    );
  }

  const userRole = user.role as UserRole;

  // Route vers le dashboard approprié selon le rôle
  switch (userRole) {
    case 'aps':
      return <APSDashboard />;
    
    case 'operateur':
      return <OperatorDashboard />;
    
    case 'organisation':
      return <OrganizationDashboard />;
    
    case 'admin':
      return <AdminDashboard />;
    
    case 'superviseur':
      return <SupervisorDashboard />;
    
    case 'survivante':
      // Pour le moment, rediriger vers un dashboard simple
      return (
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <Shield className="w-10 h-10 text-green-600 mb-4 inline-block" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Espace Survivante</h2>
            <p className="text-gray-600 mb-4">Interface en cours de développement.</p>
            <p className="text-sm text-gray-500">Contactez le support pour plus d'informations.</p>
          </div>
        </div>
      );
    
    default:
      return (
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <AlertTriangle className="w-10 h-10 text-yellow-500 mb-4 inline-block" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Rôle non reconnu</h2>
            <p className="text-gray-600 mb-4">
              Le rôle "{userRole}" n'est pas configuré dans le système.
            </p>
            <p className="text-sm text-gray-500 mb-4">
              Contactez l'administrateur système pour résoudre ce problème.
            </p>
            <button 
              onClick={() => window.location.href = '/logout'}
              className="inline-flex items-center px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
            >
              <LogOut className="w-4 h-4 mr-2" />
              Se déconnecter
            </button>
          </div>
        </div>
      );
  }
};

/**
 * HOC pour protéger les routes selon le rôle
 */
interface RoleProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles: UserRole[];
  fallbackRoute?: string;
}

export const RoleProtectedRoute: React.FC<RoleProtectedRouteProps> = ({
  children,
  allowedRoles,
  fallbackRoute = '/dashboard'
}) => {
  const { user, isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600"></div>
      </div>
    );
  }

  if (!isAuthenticated || !user) {
    window.location.href = '/login';
    return null;
  }

  const userRole = user.role as UserRole;
  
  // Vérifier si l'utilisateur a le bon rôle
  if (!allowedRoles.includes(userRole)) {
    window.location.href = fallbackRoute;
    return null;
  }

  return <>{children}</>;
};