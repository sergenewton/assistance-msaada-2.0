import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { User, TokenInfo } from '../services/authService';

/**
 * Interface du state d'authentification
 */
interface AuthState {
  // État
  user: User | null;
  token: TokenInfo | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  
  // Actions
  setUser: (user: User) => void;
  setToken: (token: TokenInfo) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  login: (user: User, token: TokenInfo) => void;
  logout: () => void;
  updateUser: (updates: Partial<User>) => void;
  clearError: () => void;
  
  // Utilitaires
  hasPermission: (permission: string) => boolean;
  hasRole: (role: string) => boolean;
  isTokenExpired: () => boolean;
}

/**
 * Store d'authentification avec Zustand
 * Persistance automatique des données d'authentification
 */
export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      // État initial
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      // Actions
      setUser: (user: User) =>
        set((state) => ({
          ...state,
          user,
          isAuthenticated: true,
          error: null,
        })),

      setToken: (token: TokenInfo) =>
        set((state) => ({
          ...state,
          token,
          error: null,
        })),

      setLoading: (isLoading: boolean) =>
        set((state) => ({
          ...state,
          isLoading,
        })),

      setError: (error: string | null) =>
        set((state) => ({
          ...state,
          error,
          isLoading: false,
        })),

      login: (user: User, token: TokenInfo) =>
        set({
          user,
          token,
          isAuthenticated: true,
          isLoading: false,
          error: null,
        }),

      logout: () =>
        set({
          user: null,
          token: null,
          isAuthenticated: false,
          isLoading: false,
          error: null,
        }),

      updateUser: (updates: Partial<User>) =>
        set((state) => ({
          ...state,
          user: state.user ? { ...state.user, ...updates } : null,
        })),

      clearError: () =>
        set((state) => ({
          ...state,
          error: null,
        })),

      // Vérifier si l'utilisateur a une permission spécifique
      hasPermission: (permission: string): boolean => {
        const { user } = get();
        if (!user || !user.permissions) return false;
        
        // Admin a toutes les permissions
        if (user.role === 'admin') return true;
        
        return user.permissions.includes(permission);
      },

      // Vérifier si l'utilisateur a un rôle spécifique
      hasRole: (role: string): boolean => {
        const { user } = get();
        if (!user) return false;
        
        return user.role === role;
      },

      // Vérifier si le token est expiré
      isTokenExpired: (): boolean => {
        const { token } = get();
        if (!token || !token.expires_at) return true;
        
        const expireTime = new Date(token.expires_at);
        const now = new Date();
        
        // Ajouter une marge de 5 minutes pour éviter les erreurs de timing
        const marginMs = 5 * 60 * 1000; // 5 minutes en millisecondes
        
        return now.getTime() >= (expireTime.getTime() - marginMs);
      },
    }),
    {
      name: 'assistance-msaada-auth',
      storage: {
        getItem: (name) => {
          const str = localStorage.getItem(name);
          if (!str) return null;
          
          try {
            return JSON.parse(str);
          } catch {
            return null;
          }
        },
        setItem: (name, value) => {
          localStorage.setItem(name, JSON.stringify(value));
        },
        removeItem: (name) => {
          localStorage.removeItem(name);
        },
      },
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

/**
 * Sélecteurs optimisés pour éviter les re-rendus inutiles
 */
export const authSelectors = {
  // Utilisateur connecté
  user: (state: AuthState) => state.user,
  
  // État d'authentification
  isAuthenticated: (state: AuthState) => state.isAuthenticated,
  
  // État de chargement
  isLoading: (state: AuthState) => state.isLoading,
  
  // Erreur actuelle
  error: (state: AuthState) => state.error,
  
  // Token d'accès
  accessToken: (state: AuthState) => state.token?.access_token,
  
  // Rôle de l'utilisateur
  userRole: (state: AuthState) => state.user?.role,
  
  // Nom d'affichage du rôle
  roleDisplayName: (state: AuthState) => state.user?.role_display_name,
  
  // Organisation de l'utilisateur
  userOrganization: (state: AuthState) => state.user?.organization,
  
  // Permissions de l'utilisateur
  userPermissions: (state: AuthState) => state.user?.permissions || [],
  
  // Vérification 2FA
  hasTwoFactor: (state: AuthState) => state.user?.two_factor_enabled || false,
  
  // Dernière connexion
  lastLogin: (state: AuthState) => state.user?.last_login_at,
};

/**
 * Hook personnalisé pour accéder au store d'authentification
 */
export const useAuth = () => {
  const store = useAuthStore();
  
  return {
    // État
    user: store.user,
    token: store.token,
    isAuthenticated: store.isAuthenticated,
    isLoading: store.isLoading,
    error: store.error,
    
    // Actions
    setUser: store.setUser,
    setToken: store.setToken,
    setLoading: store.setLoading,
    setError: store.setError,
    login: store.login,
    logout: store.logout,
    updateUser: store.updateUser,
    clearError: store.clearError,
    
    // Utilitaires
    hasPermission: store.hasPermission,
    hasRole: store.hasRole,
    isTokenExpired: store.isTokenExpired,
    
    // Getters pratiques
    accessToken: store.token?.access_token,
    userRole: store.user?.role,
    roleDisplayName: store.user?.role_display_name,
    userOrganization: store.user?.organization,
    userPermissions: store.user?.permissions || [],
    hasTwoFactor: store.user?.two_factor_enabled || false,
    
    // États dérivés
    isAdmin: store.user?.role === 'admin',
    isSupervisor: store.user?.role === 'superviseur',
    isOrganization: store.user?.role === 'organisation',
    isOperator: store.user?.role === 'operateur',
    isAPS: store.user?.role === 'aps',
    isSurvivor: store.user?.role === 'survivante',
    
    // Vérifications rapides
    canViewReports: store.hasPermission('reports.view'),
    canCreateReports: store.hasPermission('reports.create'),
    canManageUsers: store.hasPermission('users.manage'),
    canViewAnalytics: store.hasPermission('analytics.view'),
  };
};

/**
 * Type pour le hook useAuth
 */
export type UseAuthReturn = ReturnType<typeof useAuth>;