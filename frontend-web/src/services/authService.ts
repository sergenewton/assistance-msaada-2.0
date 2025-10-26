import axios, { AxiosInstance, AxiosError } from 'axios';

// Types pour l'authentification
export interface LoginCredentials {
  identifier: string; // Email ou téléphone
  password: string;
  remember_me?: boolean;
  device_name?: string;
}

export interface RegisterCredentials {
  email?: string;
  phone?: string;
  password: string;
  password_confirmation: string;
  role?: string;
  organization_id?: string;
  terms_accepted: boolean;
  privacy_policy_accepted: boolean;
}

export interface User {
  id: string;
  email?: string;
  phone?: string;
  role: string;
  role_display_name: string;
  permissions: string[];
  organization_id?: string;
  organization?: {
    id: string;
    name: string;
    type: string;
  };
  two_factor_enabled: boolean;
  last_login_at?: string;
  created_at: string;
}

export interface TokenInfo {
  access_token: string;
  refresh_token?: string;
  token_type: string;
  expires_at: string;
}

export interface AuthResponse {
  success: boolean;
  message: string;
  data?: {
    user: User;
    token: TokenInfo;
  };
  errors?: Record<string, string[]>;
}

export interface ApiErrorResponse {
  success: false;
  message: string;
  error_code?: string;
  errors?: Record<string, string[]>;
}

/**
 * Service d'authentification pour l'API
 * Gestion centralisée des appels d'authentification avec sécurité VBG
 */
class AuthService {
  private api: AxiosInstance;
  private baseURL: string;

  constructor() {
    this.baseURL = import.meta.env.VITE_API_URL || 'http://localhost:8000';
    
    // Configuration Axios
    this.api = axios.create({
      baseURL: `${this.baseURL}/api/v1`,
      timeout: 10000, // 10 secondes
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
    });

    // Intercepteur pour les requêtes (ajouter le token automatiquement)
    this.api.interceptors.request.use(
      (config) => {
        const token = this.getStoredToken();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Intercepteur pour les réponses (gestion des erreurs globales)
    this.api.interceptors.response.use(
      (response) => response,
      (error: AxiosError) => {
        if (error.response?.status === 401) {
          // Token expiré ou invalide
          this.clearAuthToken();
          window.location.href = '/auth/login';
        }
        return Promise.reject(error);
      }
    );
  }

  /**
   * Connexion utilisateur
   */
  async login(credentials: LoginCredentials): Promise<AuthResponse> {
    try {
      const response = await this.api.post('/auth/login', {
        ...credentials,
        device_name: credentials.device_name || this.getDeviceName(),
      });

      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Inscription utilisateur
   */
  async register(credentials: RegisterCredentials): Promise<AuthResponse> {
    try {
      const response = await this.api.post('/auth/register', credentials);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Déconnexion utilisateur
   */
  async logout(): Promise<void> {
    try {
      await this.api.post('/auth/logout');
    } catch (error) {
      // Même si l'API échoue, on continue la déconnexion locale
      console.warn('Erreur lors de la déconnexion serveur:', error);
    }
  }

  /**
   * Déconnexion de tous les appareils
   */
  async logoutAll(): Promise<void> {
    try {
      await this.api.post('/auth/logout-all');
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Rafraîchir le token d'accès
   */
  async refreshToken(): Promise<AuthResponse> {
    try {
      const response = await this.api.post('/auth/refresh');
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Vérifier la validité du token
   */
  async verifyToken(): Promise<{ valid: boolean; expires_at?: string }> {
    try {
      const response = await this.api.get('/auth/verify');
      return response.data.data;
    } catch (error) {
      return { valid: false };
    }
  }

  /**
   * Obtenir les informations de l'utilisateur connecté
   */
  async getMe(): Promise<User> {
    try {
      const response = await this.api.get('/auth/me');
      return response.data.data.user;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Configurer le token d'authentification
   */
  setAuthToken(token: string): void {
    localStorage.setItem('auth_token', token);
    this.api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  }

  /**
   * Supprimer le token d'authentification
   */
  clearAuthToken(): void {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('auth_user');
    localStorage.removeItem('auth_expires_at');
    delete this.api.defaults.headers.common['Authorization'];
  }

  /**
   * Obtenir le token stocké localement
   */
  private getStoredToken(): string | null {
    return localStorage.getItem('auth_token');
  }

  /**
   * Obtenir un nom d'appareil basique
   */
  private getDeviceName(): string {
    const userAgent = navigator.userAgent;
    
    // Détection mobile
    if (/Mobile|Android|iPhone|iPad/.test(userAgent)) {
      if (/iPhone/.test(userAgent)) return 'iPhone';
      if (/iPad/.test(userAgent)) return 'iPad';
      if (/Android/.test(userAgent)) return 'Android';
      return 'Mobile Device';
    }
    
    // Détection navigateur desktop
    if (/Chrome/.test(userAgent)) return 'Chrome Browser';
    if (/Firefox/.test(userAgent)) return 'Firefox Browser';
    if (/Safari/.test(userAgent)) return 'Safari Browser';
    if (/Edge/.test(userAgent)) return 'Edge Browser';
    
    return 'Web Browser';
  }

  /**
   * Gestionnaire d'erreurs centralisé
   */
  private handleError(error: any): Error {
    if (axios.isAxiosError(error)) {
      const axiosError = error as AxiosError<ApiErrorResponse>;
      
      if (axiosError.response?.data) {
        const errorData = axiosError.response.data;
        
        // Erreurs de validation
        if (errorData.errors) {
          const validationErrors = Object.values(errorData.errors).flat();
          throw new Error(validationErrors.join(', '));
        }
        
        // Erreur générale
        if (errorData.message) {
          throw new Error(errorData.message);
        }
      }
      
      // Erreurs réseau
      if (axiosError.code === 'ECONNABORTED') {
        throw new Error('Délai d\'attente dépassé. Vérifiez votre connexion.');
      }
      
      if (axiosError.code === 'ERR_NETWORK') {
        throw new Error('Erreur réseau. Vérifiez votre connexion internet.');
      }
      
      // Status codes spécifiques
      switch (axiosError.response?.status) {
        case 401:
          throw new Error('Session expirée. Veuillez vous reconnecter.');
        case 403:
          throw new Error('Accès refusé. Permissions insuffisantes.');
        case 404:
          throw new Error('Service non trouvé. Vérifiez votre configuration.');
        case 429:
          throw new Error('Trop de tentatives. Veuillez patienter avant de réessayer.');
        case 500:
          throw new Error('Erreur serveur. Veuillez réessayer plus tard.');
        case 503:
          throw new Error('Service temporairement indisponible.');
        default:
          throw new Error('Une erreur inattendue s\'est produite.');
      }
    }
    
    // Erreur générique
    throw new Error(error.message || 'Une erreur inattendue s\'est produite.');
  }

  /**
   * Vérifier si l'utilisateur est connecté localement
   */
  isAuthenticated(): boolean {
    const token = this.getStoredToken();
    const expiresAt = localStorage.getItem('auth_expires_at');
    
    if (!token || !expiresAt) {
      return false;
    }
    
    // Vérifier l'expiration
    const expireTime = new Date(expiresAt);
    const now = new Date();
    
    if (now >= expireTime) {
      this.clearAuthToken();
      return false;
    }
    
    return true;
  }

  /**
   * Obtenir l'utilisateur depuis le stockage local
   */
  getCurrentUser(): User | null {
    const userStr = localStorage.getItem('auth_user');
    if (!userStr) return null;
    
    try {
      return JSON.parse(userStr);
    } catch {
      return null;
    }
  }

  /**
   * Sauvegarder l'utilisateur dans le stockage local
   */
  setCurrentUser(user: User): void {
    localStorage.setItem('auth_user', JSON.stringify(user));
  }
}

// Instance singleton
export const authService = new AuthService();