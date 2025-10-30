// Types spécifiques aux dashboards
export type UserRole = 
  | 'aps' // Agent Psychosocial
  | 'operateur' // Opérateur Centre d'Écoute  
  | 'organisation' // Organisation Partenaire
  | 'admin' // Administrateur Système
  | 'superviseur' // Superviseur/Coordinateur
  | 'survivante'; // Survivante (pour future extension)

export type ModuleType = 
  | 'auth-security' // Module Authentification & Sécurité
  | 'case-management' // Module Gestion des Cas
  | 'awareness' // Module Sensibilisation
  | 'secure-communication' // Module Communication Sécurisée
  | 'alerts-notifications' // Module Alertes et Notifications
  | 'reports-statistics' // Module Rapports et Statistiques
  | 'feedback-evaluation' // Module Feedback et Évaluation
  | 'advanced-security'; // Module Sécurité Avancée

export interface Module {
  id: ModuleType;
  name: string;
  description: string;
  icon: string;
  color: string;
  permissions: string[];
  isActive: boolean;
}

export interface DashboardConfig {
  role: UserRole;
  modules: Module[];
  layout: 'default' | 'compact' | 'grid';
  quickActions: QuickAction[];
  notifications: NotificationConfig;
}

export interface QuickAction {
  id: string;
  label: string;
  icon: string;
  path: string;
  permissions: string[];
  color?: string;
}

export interface NotificationConfig {
  showBadges: boolean;
  autoRefresh: boolean;
  refreshInterval: number; // en millisecondes
}

export interface DashboardStats {
  totalCases: number;
  activeCases: number;
  urgentCases: number;
  completedCases: number;
  pendingActions: number;
  responseTime: number; // en heures
}

export interface CaseOverview {
  id: string;
  trackingNumber: string;
  urgency: 'critical' | 'high' | 'moderate' | 'low';
  status: 'new' | 'in-progress' | 'pending' | 'completed' | 'closed';
  type: string;
  createdAt: string;
  lastUpdate: string;
  assignedTo?: string;
  organization?: string;
}

export interface NavigationItem {
  id: string;
  label: string;
  icon: string;
  path?: string;
  children?: NavigationItem[];
  permissions: string[];
  badge?: number;
  isActive?: boolean;
}

// Configuration des permissions par rôle
export const ROLE_PERMISSIONS: Record<UserRole, string[]> = {
  aps: [
    'cases.view.assigned',
    'cases.update.status',
    'cases.document.sessions',
    'communication.secure.chat',
    'referrals.request',
    'reports.progress.generate'
  ],
  operateur: [
    'cases.view.all',
    'cases.triage',
    'cases.assign',
    'urgency.evaluate',
    'referrals.manage',
    'organizations.contact',
    'cases.validate.closure'
  ],
  organisation: [
    'cases.view.referred',
    'cases.accept.decline',
    'cases.update.progress',
    'documents.upload',
    'referrals.cross.propose',
    'cases.history.view'
  ],
  admin: [
    'users.manage',
    'system.configure',
    'organizations.manage',
    'audit.logs.view',
    'backups.manage',
    'alerts.configure',
    'content.awareness.manage',
    'data.export.anonymized'
  ],
  superviseur: [
    'dashboard.consolidated.view',
    'cases.view.all',
    'reports.strategic.generate',
    'performance.monitor',
    'cases.reassign',
    'data.export.statistics',
    'analytics.full.access'
  ],
  survivante: [
    'profile.view',
    'profile.update',
    'case.own.view',
    'communication.secure.chat',
    'feedback.provide'
  ]
};

// Configuration des modules par rôle
export const ROLE_MODULES: Record<UserRole, ModuleType[]> = {
  aps: [
    'case-management',
    'secure-communication', 
    'reports-statistics',
    'feedback-evaluation'
  ],
  operateur: [
    'case-management',
    'alerts-notifications',
    'secure-communication',
    'reports-statistics',
    'advanced-security'
  ],
  organisation: [
    'case-management',
    'secure-communication',
    'reports-statistics',
    'feedback-evaluation'
  ],
  admin: [
    'auth-security',
    'case-management',
    'awareness',
    'secure-communication',
    'alerts-notifications',
    'reports-statistics',
    'feedback-evaluation',
    'advanced-security'
  ],
  superviseur: [
    'case-management',
    'awareness',
    'secure-communication',
    'alerts-notifications',
    'reports-statistics',
    'feedback-evaluation',
    'advanced-security'
  ],
  survivante: [
    'secure-communication',
    'awareness',
    'feedback-evaluation'
  ]
};