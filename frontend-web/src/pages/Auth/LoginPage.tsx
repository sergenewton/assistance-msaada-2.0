import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Eye, EyeOff, Mail, Lock, AlertCircle } from 'lucide-react';
import { useAuthHook } from '../../hooks/useAuthHook';
import { authService } from '../../services/authService';
// Removed Button component import as we use native button
// Removed Input component import as we use native input with custom styling
// Removed Alert import as we use custom error display
// Removed Logo import as we use custom SVG icon

// Schéma de validation avec Zod
const loginSchema = z.object({
  identifier: z
    .string()
    .min(1, 'L\'email ou nom d\'utilisateur est requis')
    .refine(
      (value) => {
        // Vérifier si c'est un email valide ou un username
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        const usernameRegex = /^[a-zA-Z0-9_]{3,20}$/;
        return emailRegex.test(value) || usernameRegex.test(value);
      },
      'Veuillez entrer un email valide ou nom d\'utilisateur (3-20 caractères)'
    ),
  password: z
    .string()
    .min(6, 'Le mot de passe doit contenir au moins 6 caractères'),
  remember_me: z.boolean().optional().default(false),
});

type LoginFormData = z.infer<typeof loginSchema>;

interface LoginPageProps {
  title?: string;
  subtitle?: string;
}

/**
 * Page de connexion pour la plateforme VBG
 * Interface sécurisée avec validation stricte - Design moderne vert
 */
export const LoginPage: React.FC<LoginPageProps> = ({ 
  title = "Assistance Msaada 2.0", 
  subtitle = "Connectez-vous à votre compte" 
}) => {
  const navigate = useNavigate();
  const { login, isLoading, error, clearError } = useAuthHook();
  const [showPassword, setShowPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    watch,

  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      identifier: '',
      password: '',
      remember_me: false,
    },
  });

  // Observer les changements dans les champs pour effacer les erreurs
  const identifierValue = watch('identifier');
  const passwordValue = watch('password');
  
  React.useEffect(() => {
    // Effacer l'erreur quand l'utilisateur commence à taper
    if (error && (identifierValue || passwordValue)) {
      clearError();
    }
  }, [identifierValue, passwordValue, error, clearError]);

  // S'assurer que toute session précédente ne perturbe pas l'affichage des erreurs
  React.useEffect(() => {
    // En arrivant sur la page de login, on nettoie les tokens résiduels
    authService.clearAuthToken();
  }, []);

  const onSubmit = async (data: LoginFormData) => {
    try {
      // Effacer les erreurs précédentes avant de tenter la connexion
      clearError();
      
      await login({
        identifier: data.identifier,
        password: data.password,
        remember_me: data.remember_me,
        device_name: `Web - ${navigator.userAgent.substring(0, 50)}`,
      });

      // Si on arrive ici, la connexion a réussi
      // Obtenir le rôle de l'utilisateur depuis le store
      const currentUser = authService.getCurrentUser();
      const userRole = currentUser?.role;
      
      switch (userRole) {
        case 'survivante':
          navigate('/dashboard/survivor');
          break;
        case 'aps':
          navigate('/dashboard/aps');
          break;
        case 'operateur':
          navigate('/dashboard/operator');
          break;
        case 'organisation':
          navigate('/dashboard/organization');
          break;
        case 'superviseur':
          navigate('/dashboard/supervisor');
          break;
        case 'admin':
          navigate('/dashboard/admin');
          break;
        default:
          navigate('/dashboard');
      }
    } catch (error) {
      // Les erreurs sont gérées automatiquement par le hook
      // L'erreur reste affichée jusqu'à ce que l'utilisateur la corrige
      console.error('Erreur de connexion:', error);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Carte de connexion */}
        <div className="bg-white shadow-lg rounded-2xl p-8">
          {/* En-tête avec icône */}
          <div className="text-center mb-8">
            <div className="mx-auto w-16 h-16 bg-emerald-500 rounded-xl flex items-center justify-center mb-4 shadow-md">
              <svg className="h-8 w-8 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013 3v1" />
              </svg>
            </div>
            <h1 className="text-2xl font-semibold text-gray-900 mb-2">{title}</h1>
            <p className="text-gray-600 text-sm">{subtitle}</p>
          </div>

          {/* Message d'erreur global */}
          {error && (
            <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <AlertCircle className="h-5 w-5 text-red-500 mr-3" />
                  <span className="text-red-700 text-sm">{error}</span>
                </div>
                <button
                  type="button"
                  onClick={clearError}
                  className="text-red-400 hover:text-red-600 transition-colors"
                >
                  <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>
          )}

          {/* Formulaire */}
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-6" noValidate>
            {/* Identifiant (Email ou nom d'utilisateur) */}
            <div>
              <label htmlFor="identifier" className="block text-sm font-medium text-gray-700 mb-2">
                Email ou Nom d'utilisateur
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Mail className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="identifier"
                  type="text"
                  autoComplete="username"
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-colors ${
                    errors.identifier ? 'border-red-300 bg-red-50' : 'border-gray-300'
                  }`}
                  placeholder="votre@email.com"
                  {...register('identifier')}
                />
              </div>
              {errors.identifier && (
                <p className="mt-2 text-sm text-red-600">{errors.identifier.message}</p>
              )}
            </div>

            {/* Mot de passe */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Mot de passe
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  className={`w-full pl-10 pr-10 py-3 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-colors ${
                    errors.password ? 'border-red-300 bg-red-50' : 'border-gray-300'
                  }`}
                  placeholder="••••••••"
                  {...register('password')}
                />
                <button
                  type="button"
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? (
                    <EyeOff className="h-5 w-5 text-gray-400 hover:text-gray-600" />
                  ) : (
                    <Eye className="h-5 w-5 text-gray-400 hover:text-gray-600" />
                  )}
                </button>
              </div>
              {errors.password && (
                <p className="mt-2 text-sm text-red-600">{errors.password.message}</p>
              )}
            </div>

            {/* Bouton de connexion */}
            <button
              type="submit"
              disabled={isSubmitting || isLoading}
              className="w-full bg-emerald-500 hover:bg-emerald-600 text-white font-medium py-3 px-4 rounded-lg transition-colors focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isSubmitting || isLoading ? 'Connexion en cours...' : 'Se connecter'}
            </button>
          </form>

          {/* Lien inscription */}
          <div className="mt-6 text-center">
            <p className="text-sm text-gray-600">
              Pas encore de compte ?{' '}
              <Link
                to="/auth/register"
                className="font-medium text-emerald-600 hover:text-emerald-500"
              >
                Créer un compte
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};