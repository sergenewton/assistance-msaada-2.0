import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import LoginPage from '../../../src/pages/auth/LoginPage';
import { useAuthHook } from '../../../src/hooks/useAuthHook';

// Mock du hook d'authentification
vi.mock('../../../src/hooks/useAuthHook');
const mockUseAuth = vi.mocked(useAuthHook);

// Mock de react-router-dom
const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  };
});

// Wrapper pour les tests avec Router
const TestWrapper = ({ children }: { children: React.ReactNode }) => (
  <BrowserRouter>{children}</BrowserRouter>
);

describe('LoginPage', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockUseAuth.mockReturnValue({
      login: vi.fn(),
      isLoading: false,
      error: null,
      user: null,
      isAuthenticated: false,
      logout: vi.fn(),
      register: vi.fn(),
      refreshToken: vi.fn(),
      getCurrentUser: vi.fn(),
      checkAuthStatus: vi.fn(),
      clearError: vi.fn(),
      hasPermission: vi.fn(),
      hasRole: vi.fn(),
      accessToken: null,
      userRole: null,
      roleDisplayName: null,
      userOrganization: null,
      userPermissions: [],
      hasTwoFactor: false,
      isAdmin: false,
      isSupervisor: false,
      isOrganization: false,
      isOperator: false,
      isAPS: false,
      isSurvivor: false,
      canViewReports: false,
      canCreateReports: false,
      canManageUsers: false,
      canViewAnalytics: false,
      setUser: vi.fn(),
      setToken: vi.fn(),
      setLoading: vi.fn(),
      setError: vi.fn(),
      updateUser: vi.fn(),
      isTokenExpired: vi.fn(),
      token: null,
    });
  });

  it('renders login form correctly', () => {
    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    // Vérifier la présence du logo
    expect(screen.getByText(/Assistance/)).toBeInTheDocument();
    expect(screen.getByText(/Msaada/)).toBeInTheDocument();

    // Vérifier les champs du formulaire
    expect(screen.getByLabelText(/Email ou Téléphone/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Mot de passe/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /se connecter/i })).toBeInTheDocument();

    // Vérifier les liens
    expect(screen.getByText(/Créer un compte/i)).toBeInTheDocument();
    expect(screen.getByText(/Mot de passe oublié/i)).toBeInTheDocument();

    // Vérifier les informations d'urgence VBG
    expect(screen.getByText(/Besoin d'aide immédiate/i)).toBeInTheDocument();
  });

  it('validates form inputs correctly', async () => {
    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    const submitButton = screen.getByRole('button', { name: /se connecter/i });
    
    // Essayer de soumettre le formulaire vide
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText(/L'email ou le téléphone est requis/i)).toBeInTheDocument();
      expect(screen.getByText(/Le mot de passe est requis/i)).toBeInTheDocument();
    });
  });

  it('accepts valid email format', async () => {
    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    const emailInput = screen.getByLabelText(/Email ou Téléphone/i);
    const passwordInput = screen.getByLabelText(/Mot de passe/i);

    fireEvent.change(emailInput, { target: { value: 'test@example.com' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });

    // Le formulaire ne devrait pas afficher d'erreurs de validation
    await waitFor(() => {
      expect(screen.queryByText(/Format d'email invalide/i)).not.toBeInTheDocument();
    });
  });

  it('accepts valid phone format', async () => {
    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    const emailInput = screen.getByLabelText(/Email ou Téléphone/i);
    const passwordInput = screen.getByLabelText(/Mot de passe/i);

    fireEvent.change(emailInput, { target: { value: '+243901234567' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });

    // Le formulaire ne devrait pas afficher d'erreurs de validation
    await waitFor(() => {
      expect(screen.queryByText(/Format de téléphone invalide/i)).not.toBeInTheDocument();
    });
  });

  it('rejects invalid identifier format', async () => {
    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    const emailInput = screen.getByLabelText(/Email ou Téléphone/i);
    const passwordInput = screen.getByLabelText(/Mot de passe/i);
    const submitButton = screen.getByRole('button', { name: /se connecter/i });

    fireEvent.change(emailInput, { target: { value: 'invalid-format' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(
        screen.getByText(/Veuillez entrer un email ou un numéro de téléphone valide/i)
      ).toBeInTheDocument();
    });
  });

  it('calls login function on form submission', async () => {
    const mockLogin = vi.fn().mockResolvedValue(undefined);
    mockUseAuth.mockReturnValue({
      ...mockUseAuth(),
      login: mockLogin,
    });

    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    const emailInput = screen.getByLabelText(/Email ou Téléphone/i);
    const passwordInput = screen.getByLabelText(/Mot de passe/i);
    const rememberCheckbox = screen.getByLabelText(/Se souvenir de moi/i);
    const submitButton = screen.getByRole('button', { name: /se connecter/i });

    fireEvent.change(emailInput, { target: { value: 'test@example.com' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });
    fireEvent.click(rememberCheckbox);
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith({
        identifier: 'test@example.com',
        password: 'password123',
        remember_me: true,
        device_name: expect.stringContaining('Web -'),
      });
    });
  });

  it('shows loading state during authentication', () => {
    mockUseAuth.mockReturnValue({
      ...mockUseAuth(),
      isLoading: true,
    });

    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    const submitButton = screen.getByRole('button', { name: /se connecter/i });
    expect(submitButton).toBeDisabled();
  });

  it('displays error message when authentication fails', () => {
    const errorMessage = 'Identifiants invalides';
    mockUseAuth.mockReturnValue({
      ...mockUseAuth(),
      error: errorMessage,
    });

    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    expect(screen.getByText(errorMessage)).toBeInTheDocument();
  });

  it('toggles password visibility', () => {
    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    const passwordInput = screen.getByLabelText(/Mot de passe/i);
    const toggleButton = screen.getByRole('button', { name: /afficher le mot de passe/i });

    // Initial state should be password type
    expect(passwordInput).toHaveAttribute('type', 'password');

    // Click to show password
    fireEvent.click(toggleButton);
    expect(passwordInput).toHaveAttribute('type', 'text');

    // Click to hide password
    fireEvent.click(toggleButton);
    expect(passwordInput).toHaveAttribute('type', 'password');
  });

  it('navigates to correct dashboard based on user role', async () => {
    const mockLogin = vi.fn().mockResolvedValue(undefined);
    
    // Mock authService.getCurrentUser() to return a user with specific role
    const mockAuthService = {
      getCurrentUser: vi.fn().mockReturnValue({ role: 'survivante' }),
    };

    vi.doMock('../../../src/services/authService', () => ({
      authService: mockAuthService,
    }));

    mockUseAuth.mockReturnValue({
      ...mockUseAuth(),
      login: mockLogin,
    });

    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    const emailInput = screen.getByLabelText(/Email ou Téléphone/i);
    const passwordInput = screen.getByLabelText(/Mot de passe/i);
    const submitButton = screen.getByRole('button', { name: /se connecter/i });

    fireEvent.change(emailInput, { target: { value: 'test@example.com' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('/survivor/dashboard');
    });
  });

  it('displays VBG-specific emergency contact information', () => {
    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    expect(screen.getByText(/Police : 112/)).toBeInTheDocument();
    expect(screen.getByText(/MONUSCO : \+243 123 456 789/)).toBeInTheDocument();
    expect(screen.getByText(/Ligne d'écoute VBG : \+243 987 654 321/)).toBeInTheDocument();
  });

  it('handles keyboard navigation correctly', () => {
    render(
      <TestWrapper>
        <LoginPage />
      </TestWrapper>
    );

    const emailInput = screen.getByLabelText(/Email ou Téléphone/i);
    const passwordInput = screen.getByLabelText(/Mot de passe/i);
    const submitButton = screen.getByRole('button', { name: /se connecter/i });

    // Test tab navigation
    emailInput.focus();
    fireEvent.keyDown(emailInput, { key: 'Tab' });
    expect(passwordInput).toHaveFocus();

    fireEvent.keyDown(passwordInput, { key: 'Tab' });
    // The remember me checkbox should be focused next, but we'll check the submit button
    // This depends on the exact tab order implementation
  });
});