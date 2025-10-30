// Point d'entrée principal
export { DashboardPage } from './DashboardPage';
export { RoleDashboard, RoleProtectedRoute } from './RoleDashboard';

// Dashboards spécifiques par rôle
export { APSDashboard } from './APSDashboard';
export { OperatorDashboard } from './OperatorDashboard';
export { OrganizationDashboard } from './OrganizationDashboard';
export { AdminDashboard } from './AdminDashboard';
export { SupervisorDashboard } from './SupervisorDashboard';

// Types et utilitaires
export * from '@/types/dashboard';
export * from '@/utils/roleRouting';