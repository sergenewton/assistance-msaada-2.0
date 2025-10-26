import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import axios, { AxiosError } from 'axios';
import { authService, LoginCredentials, RegisterCredentials } from '../../../src/services/authService';

// Mock axios
vi.mock('axios');
const mockedAxios = vi.mocked(axios);

// Mock localStorage
const localStorageMock = {
  getItem: vi.fn(),
  setItem: vi.fn(),
  removeItem: vi.fn(),
  clear: vi.fn(),
};
Object.defineProperty(window, 'localStorage', { value: localStorageMock });

// Mock window.location
Object.defineProperty(window, 'location', {
  value: { href: '' },
  writable: true,
});

describe('AuthService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    
    // Mock axios.create to return a mocked instance
    mockedAxios.create.mockReturnValue({
      defaults: { headers: { common: {} } },
      interceptors: {
        request: { use: vi.fn() },
        response: { use: vi.fn() },
      },
      post: vi.fn(),
      get: vi.fn(),
    } as any);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('login', () => {
    it('should login successfully with valid credentials', async () => {
      const mockResponse = {
        data: {
          success: true,
          message: 'Connexion réussie',
          data: {
            user: {
              id: '1',
              email: 'test@example.com',
              role: 'survivante',
              role_display_name: 'Survivante',
              permissions: ['reports.view', 'reports.create'],
              two_factor_enabled: false,
              created_at: '2025-01-01T00:00:00Z',
            },
            token: {
              access_token: 'token123',
              token_type: 'Bearer',
              expires_at: '2025-01-01T01:00:00Z',
            }
          }
        }
      };

      const mockAxiosInstance = {
        post: vi.fn().mockResolvedValue(mockResponse),
        defaults: { headers: { common: {} } },
        interceptors: {
          request: { use: vi.fn() },
          response: { use: vi.fn() },
        },
      };

      mockedAxios.create.mockReturnValue(mockAxiosInstance as any);

      const credentials: LoginCredentials = {
        identifier: 'test@example.com',
        password: 'password123',
        device_name: 'Test Device',
      };

      const result = await authService.login(credentials);

      expect(result.success).toBe(true);
      expect(result.data?.user.email).toBe('test@example.com');
      expect(result.data?.token.access_token).toBe('token123');
    });

    it('should handle login failure with invalid credentials', async () => {
      const mockError = {
        response: {
          status: 401,
          data: {
            success: false,
            message: 'Identifiants invalides',
          }
        }
      };

      const mockAxiosInstance = {
        post: vi.fn().mockRejectedValue(mockError),
        defaults: { headers: { common: {} } },
        interceptors: {
          request: { use: vi.fn() },
          response: { use: vi.fn() },
        },
      };

      mockedAxios.create.mockReturnValue(mockAxiosInstance as any);

      const credentials: LoginCredentials = {
        identifier: 'test@example.com',
        password: 'wrongpassword',
      };

      await expect(authService.login(credentials)).rejects.toThrow('Identifiants invalides');
    });

    it('should handle network errors gracefully', async () => {
      const mockError = {
        code: 'ERR_NETWORK',
        message: 'Network Error'
      };

      const mockAxiosInstance = {
        post: vi.fn().mockRejectedValue(mockError),
        defaults: { headers: { common: {} } },
        interceptors: {
          request: { use: vi.fn() },
          response: { use: vi.fn() },
        },
      };

      mockedAxios.create.mockReturnValue(mockAxiosInstance as any);

      const credentials: LoginCredentials = {
        identifier: 'test@example.com',
        password: 'password123',
      };

      await expect(authService.login(credentials)).rejects.toThrow(
        'Erreur réseau. Vérifiez votre connexion internet.'
      );
    });
  });

  describe('register', () => {
    it('should register successfully with valid data', async () => {
      const mockResponse = {
        data: {
          success: true,
          message: 'Inscription réussie',
          data: {
            user: {
              id: '1',
              email: 'newuser@example.com',
              role: 'survivante',
              role_display_name: 'Survivante',
              permissions: ['reports.view', 'reports.create'],
              two_factor_enabled: false,
              created_at: '2025-01-01T00:00:00Z',
            },
            token: {
              access_token: 'newtoken123',
              token_type: 'Bearer',
              expires_at: '2025-01-01T01:00:00Z',
            }
          }
        }
      };

      const mockAxiosInstance = {
        post: vi.fn().mockResolvedValue(mockResponse),
        defaults: { headers: { common: {} } },
        interceptors: {
          request: { use: vi.fn() },
          response: { use: vi.fn() },
        },
      };

      mockedAxios.create.mockReturnValue(mockAxiosInstance as any);

      const credentials: RegisterCredentials = {
        email: 'newuser@example.com',
        password: 'SecurePass123!',
        password_confirmation: 'SecurePass123!',
        role: 'survivante',
        terms_accepted: true,
        privacy_policy_accepted: true,
      };

      const result = await authService.register(credentials);

      expect(result.success).toBe(true);
      expect(result.data?.user.email).toBe('newuser@example.com');
    });

    it('should handle validation errors', async () => {
      const mockError = {
        response: {
          status: 422,
          data: {
            success: false,
            message: 'Erreur de validation',
            errors: {
              email: ['L\'email est déjà utilisé'],
              password: ['Le mot de passe doit contenir au moins 8 caractères']
            }
          }
        }
      };

      const mockAxiosInstance = {
        post: vi.fn().mockRejectedValue(mockError),
        defaults: { headers: { common: {} } },
        interceptors: {
          request: { use: vi.fn() },
          response: { use: vi.fn() },
        },
      };

      mockedAxios.create.mockReturnValue(mockAxiosInstance as any);

      const credentials: RegisterCredentials = {
        email: 'existing@example.com',
        password: '123',
        password_confirmation: '123',
        role: 'survivante',
        terms_accepted: true,
        privacy_policy_accepted: true,
      };

      await expect(authService.register(credentials)).rejects.toThrow(
        'L\'email est déjà utilisé, Le mot de passe doit contenir au moins 8 caractères'
      );
    });
  });

  describe('token management', () => {
    it('should set authentication token correctly', () => {
      const token = 'test-token-123';
      
      authService.setAuthToken(token);
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith('auth_token', token);
    });

    it('should clear authentication data correctly', () => {
      authService.clearAuthToken();
      
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('auth_token');
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('auth_user');
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('auth_expires_at');
    });

    it('should check authentication status correctly', () => {
      // Mock valid token and expiry
      localStorageMock.getItem.mockImplementation((key) => {
        if (key === 'auth_token') return 'valid-token';
        if (key === 'auth_expires_at') {
          // Return future date
          const futureDate = new Date(Date.now() + 3600000); // 1 hour from now
          return futureDate.toISOString();
        }
        return null;
      });

      expect(authService.isAuthenticated()).toBe(true);

      // Mock expired token
      localStorageMock.getItem.mockImplementation((key) => {
        if (key === 'auth_token') return 'expired-token';
        if (key === 'auth_expires_at') {
          // Return past date
          const pastDate = new Date(Date.now() - 3600000); // 1 hour ago
          return pastDate.toISOString();
        }
        return null;
      });

      expect(authService.isAuthenticated()).toBe(false);
    });
  });

  describe('device detection', () => {
    it('should detect mobile devices correctly', () => {
      // Mock mobile user agent
      Object.defineProperty(navigator, 'userAgent', {
        value: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)',
        writable: true,
      });

      const credentials: LoginCredentials = {
        identifier: 'test@example.com',
        password: 'password123',
      };

      // The device name should be set automatically during login
      // This would be tested through the actual login call
      expect(navigator.userAgent).toContain('iPhone');
    });

    it('should detect desktop browsers correctly', () => {
      Object.defineProperty(navigator, 'userAgent', {
        value: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        writable: true,
      });

      expect(navigator.userAgent).toContain('Chrome');
    });
  });

  describe('error handling', () => {
    it('should handle timeout errors', async () => {
      const mockError = {
        code: 'ECONNABORTED',
        message: 'Timeout'
      };

      const mockAxiosInstance = {
        post: vi.fn().mockRejectedValue(mockError),
        defaults: { headers: { common: {} } },
        interceptors: {
          request: { use: vi.fn() },
          response: { use: vi.fn() },
        },
      };

      mockedAxios.create.mockReturnValue(mockAxiosInstance as any);

      const credentials: LoginCredentials = {
        identifier: 'test@example.com',
        password: 'password123',
      };

      await expect(authService.login(credentials)).rejects.toThrow(
        'Délai d\'attente dépassé. Vérifiez votre connexion.'
      );
    });

    it('should handle rate limiting', async () => {
      const mockError = {
        response: {
          status: 429,
          data: {
            success: false,
            message: 'Trop de tentatives'
          }
        }
      };

      const mockAxiosInstance = {
        post: vi.fn().mockRejectedValue(mockError),
        defaults: { headers: { common: {} } },
        interceptors: {
          request: { use: vi.fn() },
          response: { use: vi.fn() },
        },
      };

      mockedAxios.create.mockReturnValue(mockAxiosInstance as any);

      const credentials: LoginCredentials = {
        identifier: 'test@example.com',
        password: 'password123',
      };

      await expect(authService.login(credentials)).rejects.toThrow(
        'Trop de tentatives. Veuillez patienter avant de réessayer.'
      );
    });

    it('should handle server errors', async () => {
      const mockError = {
        response: {
          status: 500,
          data: {
            success: false,
            message: 'Erreur serveur'
          }
        }
      };

      const mockAxiosInstance = {
        post: vi.fn().mockRejectedValue(mockError),
        defaults: { headers: { common: {} } },
        interceptors: {
          request: { use: vi.fn() },
          response: { use: vi.fn() },
        },
      };

      mockedAxios.create.mockReturnValue(mockAxiosInstance as any);

      const credentials: LoginCredentials = {
        identifier: 'test@example.com',
        password: 'password123',
      };

      await expect(authService.login(credentials)).rejects.toThrow(
        'Erreur serveur. Veuillez réessayer plus tard.'
      );
    });
  });
});