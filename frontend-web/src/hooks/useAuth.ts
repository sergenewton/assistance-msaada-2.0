import { useState, useCallback } from 'react';
import { authService, LoginCredentials, RegisterCredentials, User, AuthResponse } from '../services/authService';
import { useAuth as useAuthStore } from '../store/authStore';t { useState, useCallback } from 'react';
import { authService, LoginCredentials, RegisterCredentials, User, AuthResponse } from '../services/authService';
import { useAuthStore } from '../store/authStore';ort { useState, useCallback } from 'react';
import { authService, LoginCredentials, RegisterCredentials, AuthResponse } from '../services/authService';
import { useAuthStore } from '../store/authStore';

interface UseAuthReturn {
  // État
  isAuthenticated: boolean;
  user: any | null;
  isLoading: boolean;
  error: string | null;

  // Actions
  login: (credentials: LoginCredentials) => Promise<AuthResponse>;
  register: (credentials: RegisterCredentials) => Promise<AuthResponse>;
  logout: () => Promise<void>;
  refreshToken: () => Promise<boolean>;
  clearError: () => void;
}

/**
 * Hook personnalisé pour la gestion de l'authentification
 * Intégré avec Zustand pour la gestion d'état globale
 */
export const useAuth = (): UseAuthReturn => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const {
    user,
    token,
    isAuthenticated,
    setAuth,
    clearAuth,
    setUser,
  } = useAuthStore();

  /**
   * Connexion utilisateur
   */
  const login = useCallback(async (credentials: LoginCredentials): Promise<AuthResponse> => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await authService.login(credentials);

      if (response.success && response.data) {
        // Stocker les données d'authentification
        setAuth({
          user: response.data.user,
          token: response.data.token.access_token,
          refreshToken: response.data.token.refresh_token,
          expiresAt: response.data.token.expires_at,
        });

        // Configurer le token par défaut pour les futures requêtes
        authService.setAuthToken(response.data.token.access_token);
      } else {
        throw new Error(response.message || 'Erreur de connexion');
      }

      return response;
    } catch (err: any) {
      const errorMessage = err.response?.data?.message || err.message || 'Erreur de connexion';
      setError(errorMessage);
      throw err;
    } finally {
      setIsLoading(false);
    }
  }, [setAuth]);

  /**
   * Inscription utilisateur
   */
  const register = useCallback(async (credentials: RegisterCredentials): Promise<AuthResponse> => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await authService.register(credentials);

      if (response.success && response.data) {
        // Auto-connexion après inscription
        setAuth({
          user: response.data.user,
          token: response.data.token.access_token,
          refreshToken: response.data.token.refresh_token,
          expiresAt: response.data.token.expires_at,
        });

        authService.setAuthToken(response.data.token.access_token);
      } else {
        throw new Error(response.message || 'Erreur d\'inscription');
      }

      return response;
    } catch (err: any) {
      const errorMessage = err.response?.data?.message || err.message || 'Erreur d\'inscription';
      setError(errorMessage);
      throw err;
    } finally {
      setIsLoading(false);
    }
  }, [setAuth]);

  /**
   * Déconnexion utilisateur
   */
  const logout = useCallback(async (): Promise<void> => {
    setIsLoading(true);
    setError(null);

    try {
      // Appeler l'API pour invalider le token côté serveur
      if (token) {
        await authService.logout();
      }
    } catch (err) {
      // Même si l'API échoue, on déconnecte localement
      console.warn('Erreur lors de la déconnexion côté serveur:', err);
    } finally {
      // Nettoyer l'état local
      clearAuth();
      authService.clearAuthToken();
      setIsLoading(false);
    }
  }, [token, clearAuth]);

  /**
   * Rafraîchir le token d'accès
   */
  const refreshToken = useCallback(async (): Promise<boolean> => {
    if (!token) {
      return false;
    }

    setIsLoading(true);
    setError(null);

    try {
      const response = await authService.refreshToken();

      if (response.success && response.data) {
        // Mettre à jour le token
        setAuth({
          user,
          token: response.data.token.access_token,
          refreshToken: response.data.token.refresh_token,
          expiresAt: response.data.token.expires_at,
        });

        authService.setAuthToken(response.data.token.access_token);
        return true;
      } else {
        // Token invalide, forcer la déconnexion
        await logout();
        return false;
      }
    } catch (err) {
      console.error('Erreur lors du rafraîchissement du token:', err);
      await logout();
      return false;
    } finally {
      setIsLoading(false);
    }
  }, [token, user, setAuth, logout]);

  /**
   * Effacer les erreurs
   */
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    // État
    isAuthenticated,
    user,
    isLoading,
    error,

    // Actions
    login,
    register,
    logout,
    refreshToken,
    clearError,
  };
};