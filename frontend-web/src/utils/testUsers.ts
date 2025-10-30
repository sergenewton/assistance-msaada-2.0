import { User, TokenInfo } from '@/services/authService';

/**
 * Utilisateurs de test pour valider le système de dashboards par rôle
 */
export const TEST_USERS: Record<string, { user: User; token: TokenInfo }> = {
  // 1. Agent Psychosocial
  aps_user: {
    user: {
      id: 'aps-001',
      email: 'marie.dupont@msaada.cd',
      phone: '+243991234567',
      role: 'aps',
      role_display_name: 'Agent Psychosocial',
      permissions: [
        'cases.view.assigned',
        'cases.update.status',
        'cases.document.sessions',
        'communication.secure.chat',
        'referrals.request',
        'reports.progress.generate'
      ],
      organization: {
        id: 'aps-org-001',
        name: 'Centre Psychosocial Tumaini',
        type: 'ong'
      },
      two_factor_enabled: false,
      last_login_at: '2024-10-30T08:00:00Z',
      created_at: '2024-01-15T10:00:00Z'
    },
    token: {
      access_token: 'aps_test_token_12345',
      token_type: 'Bearer',
      expires_at: '2024-10-30T20:00:00Z',
      refresh_token: 'aps_refresh_token_12345'
    }
  },

  // 2. Opérateur Centre d'Écoute
  operator_user: {
    user: {
      id: 'op-001',
      email: 'jean.kamau@msaada.cd',
      phone: '+243992345678',
      role: 'operateur',
      role_display_name: 'Opérateur Centre d\'Écoute',
      permissions: [
        'cases.view.all',
        'cases.triage',
        'cases.assign',
        'urgency.evaluate',
        'referrals.manage',
        'organizations.contact',
        'cases.validate.closure'
      ],
      organization: {
        id: 'center-001',
        name: 'Centre d\'Écoute Msaada',
        type: 'center'
      },
      two_factor_enabled: true,
      last_login_at: '2024-10-30T09:15:00Z',
      created_at: '2024-01-10T14:00:00Z'
    },
    token: {
      access_token: 'operator_test_token_67890',
      token_type: 'Bearer',
      expires_at: '2024-10-30T21:15:00Z',
      refresh_token: 'operator_refresh_token_67890'
    }
  },

  // 3. Organisation Partenaire
  org_user: {
    user: {
      id: 'org-001',
      email: 'contact@lisanga-juridique.cd',
      phone: '+243993456789',
      role: 'organisation',
      role_display_name: 'Organisation Partenaire',
      permissions: [
        'cases.view.referred',
        'cases.accept.decline',
        'cases.update.progress',
        'documents.upload',
        'referrals.cross.propose',
        'cases.history.view'
      ],
      organization: {
        id: 'partner-001',
        name: 'Centre Juridique Lisanga',
        type: 'legal_aid'
      },
      two_factor_enabled: false,
      last_login_at: '2024-10-30T07:30:00Z',
      created_at: '2024-02-01T16:00:00Z'
    },
    token: {
      access_token: 'org_test_token_11111',
      token_type: 'Bearer',
      expires_at: '2024-10-30T19:30:00Z',
      refresh_token: 'org_refresh_token_11111'
    }
  },

  // 4. Superviseur/Coordinateur
  supervisor_user: {
    user: {
      id: 'sup-001',
      email: 'coordinator@msaada.cd',
      phone: '+243994567890',
      role: 'superviseur',
      role_display_name: 'Superviseur/Coordinateur',
      permissions: [
        'dashboard.consolidated.view',
        'cases.view.all',
        'reports.strategic.generate',
        'performance.monitor',
        'cases.reassign',
        'data.export.statistics',
        'analytics.full.access'
      ],
      organization: {
        id: 'msaada-001',
        name: 'Assistance Msaada',
        type: 'coordination'
      },
      two_factor_enabled: true,
      last_login_at: '2024-10-30T06:00:00Z',
      created_at: '2023-12-01T12:00:00Z'
    },
    token: {
      access_token: 'supervisor_test_token_22222',
      token_type: 'Bearer',
      expires_at: '2024-10-30T18:00:00Z',
      refresh_token: 'supervisor_refresh_token_22222'
    }
  },

  // Bonus: Administrateur Système
  admin_user: {
    user: {
      id: 'admin-001',
      email: 'admin@msaada.cd',
      phone: '+243995678901',
      role: 'admin',
      role_display_name: 'Administrateur Système',
      permissions: [
        'users.manage',
        'system.configure',
        'organizations.manage',
        'audit.logs.view',
        'backups.manage',
        'alerts.configure',
        'content.awareness.manage',
        'data.export.anonymized'
      ],
      organization: {
        id: 'msaada-admin',
        name: 'Administration Msaada',
        type: 'admin'
      },
      two_factor_enabled: true,
      last_login_at: '2024-10-30T05:00:00Z',
      created_at: '2023-11-01T10:00:00Z'
    },
    token: {
      access_token: 'admin_test_token_33333',
      token_type: 'Bearer',
      expires_at: '2024-10-30T17:00:00Z',
      refresh_token: 'admin_refresh_token_33333'
    }
  }
};

/**
 * Simuler une connexion avec un utilisateur de test
 */
export const loginAsTestUser = (userKey: keyof typeof TEST_USERS) => {
  const testData = TEST_USERS[userKey];
  if (!testData) {
    throw new Error(`Utilisateur de test "${userKey}" non trouvé`);
  }

  // Stocker dans localStorage pour simulation
  localStorage.setItem('assistance-msaada-auth', JSON.stringify({
    user: testData.user,
    token: testData.token,
    isAuthenticated: true
  }));

  // Recharger la page pour déclencher la redirection
  window.location.reload();
};

/**
 * Liste des utilisateurs pour l'interface de test
 */
export const TEST_USER_LIST = [
  {
    key: 'aps_user',
    name: 'Marie Dupont',
    role: 'Agent Psychosocial',
    email: 'marie.dupont@msaada.cd',
    organization: 'Centre Psychosocial Tumaini',
    description: 'Gestion des cas assignés, accompagnement psychosocial'
  },
  {
    key: 'operator_user', 
    name: 'Jean Kamau',
    role: 'Opérateur Centre d\'Écoute',
    email: 'jean.kamau@msaada.cd',
    organization: 'Centre d\'Écoute Msaada',
    description: 'Triage des signalements, coordination des référencements'
  },
  {
    key: 'org_user',
    name: 'Fatou Mbeki',
    role: 'Organisation Partenaire',
    email: 'contact@lisanga-juridique.cd', 
    organization: 'Centre Juridique Lisanga',
    description: 'Prise en charge juridique, traitement des cas référencés'
  },
  {
    key: 'supervisor_user',
    name: 'Dr. Amina Tshisekedi',
    role: 'Superviseur/Coordinateur',
    email: 'coordinator@msaada.cd',
    organization: 'Assistance Msaada',
    description: 'Supervision globale, rapports stratégiques, monitoring'
  },
  {
    key: 'admin_user',
    name: 'Administrateur Système',
    role: 'Administrateur Système', 
    email: 'admin@msaada.cd',
    organization: 'Administration Msaada',
    description: 'Gestion système, utilisateurs, sécurité et configuration'
  }
] as const;