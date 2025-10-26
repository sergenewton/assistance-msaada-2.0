import { useState, useCallback } from 'react';
import { authService, LoginCredentials, RegisterCredentials, User, AuthResponse } from '../services/authService';
import { useAuth as useAuthStoreHook } from '../store/authStore';

/**
 * Hook personnalisé pour l'authentification
 * Fournit toutes les fonctionnalités d'authentification avec gestion des erreurs et du state
 */
export const useAuthHook = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  // Actions du store d'authentification
  const authStore = useAuthStoreHook();

  /**
   * Connexion utilisateur
   */
  const login = useCallback(async (credentials: LoginCredentials): Promise<void> => {
    try {
      setIsLoading(true);
      // NE PAS effacer l'erreur ici - elle sera effacée manuellement
      
      const response = await authService.login(credentials);
      
      if (response.success && response.data) {
        // Effacer l'erreur seulement en cas de succès
        setError(null);
        
        // Stocker le token dans le service
        authService.setAuthToken(response.data.token.access_token);
        
        // Mettre à jour le store global
        authStore.login(response.data.user, response.data.token);
        
        // Stocker les données localement pour la persistance
        authService.setCurrentUser(response.data.user);
        localStorage.setItem('auth_expires_at', response.data.token.expires_at);
      } else {
        throw new Error(response.message || 'Échec de la connexion');
      }
    } catch (error) {
      let errorMessage = 'Une erreur est survenue lors de la connexion';
      
      if (error instanceof Error) {
        if (error.message.includes('401') || error.message.includes('Unauthorized')) {
          errorMessage = 'Email/nom d\'utilisateur ou mot de passe incorrect';
        } else if (error.message.includes('404')) {
          errorMessage = 'Utilisateur non trouvé';
        } else if (error.message.includes('429')) {
          errorMessage = 'Trop de tentatives de connexion. Veuillez patienter.';
        } else {
          errorMessage = error.message;
        }
      }
      
      setError(errorMessage);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, [authStore]);

  /**
   * Inscription utilisateur
   */
  const register = useCallback(async (credentials: RegisterCredentials): Promise<void> => {
    try {
      setIsLoading(true);
      setError(null);
      
      const response = await authService.register(credentials);
      
      if (response.success && response.data) {
        // Stocker le token dans le service
        authService.setAuthToken(response.data.token.access_token);
        
        // Mettre à jour le store global
        authStore.login(response.data.user, response.data.token);
        
        // Stocker les données localement
        authService.setCurrentUser(response.data.user);
        localStorage.setItem('auth_expires_at', response.data.token.expires_at);
      } else {
        throw new Error(response.message || 'Échec de l\'inscription');
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Une erreur est survenue';
      setError(errorMessage);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, [authStore]);

  /**
   * Déconnexion utilisateur
   */
  const logout = useCallback(async (): Promise<void> => {
    try {
      setIsLoading(true);
      setError(null);
      
      // Déconnexion côté serveur
      await authService.logout();
    } catch (error) {
      // Continuer même si la déconnexion serveur échoue
      console.warn('Erreur lors de la déconnexion serveur:', error);
    } finally {
      // Nettoyage local dans tous les cas
      authService.clearAuthToken();
      authStore.logout();
      setIsLoading(false);
    }
  }, [authStore]);

  /**
   * Rafraîchir le token d'accès
   */
  const refreshToken = useCallback(async (): Promise<void> => {
    try {
      setIsLoading(true);
      setError(null);
      
      const response = await authService.refreshToken();
      
      if (response.success && response.data) {
        // Mettre à jour le token
        authService.setAuthToken(response.data.token.access_token);
        
        // Mettre à jour le store
        authStore.login(response.data.user, response.data.token);
        
        // Mettre à jour le stockage local
        authService.setCurrentUser(response.data.user);
        localStorage.setItem('auth_expires_at', response.data.token.expires_at);
      } else {
        throw new Error('Échec du rafraîchissement du token');
      }
    } catch (error) {
      // En cas d'erreur, forcer la déconnexion
      authService.clearAuthToken();
      authStore.logout();
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, [authStore]);

  /**
   * Vérifier et recharger les données utilisateur
   */
  const getCurrentUser = useCallback(async (): Promise<User | null> => {
    try {
      setIsLoading(true);
      setError(null);
      
      const userData = await authService.getMe();
      
      // Mettre à jour le store avec les nouvelles données
      authStore.setUser(userData);
      authService.setCurrentUser(userData);
      
      return userData;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erreur lors du chargement des données utilisateur';
      setError(errorMessage);
      return null;
    } finally {
      setIsLoading(false);
    }
  }, [authStore]);

  /**
   * Vérifier la validité de la session
   */
  const checkAuthStatus = useCallback(async (): Promise<boolean> => {
    try {
      // Vérification locale d'abord
      if (!authService.isAuthenticated()) {
        authStore.logout();
        return false;
      }
      
      // Vérification côté serveur
      const tokenStatus = await authService.verifyToken();
      
      if (!tokenStatus.valid) {
        authService.clearAuthToken();
        authStore.logout();
        return false;
      }
      
      return true;
    } catch (error) {
      // En cas d'erreur, considérer non authentifié
      authService.clearAuthToken();
      authStore.logout();
      return false;
    }
  }, [authStore]);

  /**
   * Effacer les erreurs
   */
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    // État du store
    ...authStore,
    
    // État local du hook (override des propriétés communes)
    isLoading: isLoading || authStore.isLoading,
    error: error || authStore.error,
    
    // Actions
    login,
    register,
    logout,
    refreshToken,
    getCurrentUser,
    checkAuthStatus,
    clearError,
  };
};