import { UserRole } from '@/types/dashboard';

/**
 * Configuration des routes par rôle
 */
export const ROLE_ROUTES: Record<UserRole, string> = {
  aps: '/dashboard/aps',
  operateur: '/dashboard/operator', 
  organisation: '/dashboard/organization',
  admin: '/dashboard/admin',
  superviseur: '/dashboard/supervisor',
  survivante: '/dashboard/survivor' // Pour future extension
};

/**
 * Routes par défaut après connexion selon le rôle
 */
export const getDefaultRouteForRole = (role: UserRole): string => {
  return ROLE_ROUTES[role] || '/dashboard';
};

/**
 * Vérifier si l'utilisateur a accès à une route spécifique
 */
export const canAccessRoute = (userRole: UserRole, targetRoute: string): boolean => {
  // L'admin peut accéder à tous les dashboards
  if (userRole === 'admin') return true;
  
  // Le superviseur peut accéder à tous les dashboards sauf admin
  if (userRole === 'superviseur') {
    return !targetRoute.includes('/dashboard/admin');
  }
  
  // Les autres rôles ne peuvent accéder qu'à leur propre dashboard
  const allowedRoute = ROLE_ROUTES[userRole];
  return targetRoute.startsWith(allowedRoute);
};

/**
 * Rediriger vers le dashboard approprié selon le rôle
 */
export const redirectToDashboard = (role: UserRole) => {
  const route = getDefaultRouteForRole(role);
  window.location.href = route;
};

/**
 * Titres des dashboards par rôle
 */
export const DASHBOARD_TITLES: Record<UserRole, string> = {
  aps: 'Agent Psychosocial',
  operateur: 'Centre d\'Écoute',
  organisation: 'Organisation Partenaire', 
  admin: 'Administration Système',
  superviseur: 'Supervision Générale',
  survivante: 'Espace Personnel'
};

/**
 * Descriptions des dashboards par rôle
 */
export const DASHBOARD_DESCRIPTIONS: Record<UserRole, string> = {
  aps: 'Gérez vos cas assignés et documentez vos interventions psychosociales',
  operateur: 'Triez les signalements et coordonnez les référencements',
  organisation: 'Recevez et traitez les cas référencés vers votre organisation',
  admin: 'Administrez la plateforme et supervisez la sécurité système',  
  superviseur: 'Supervisez les performances globales et générez des rapports stratégiques',
  survivante: 'Accédez à vos informations et communiquez de manière sécurisée'
};