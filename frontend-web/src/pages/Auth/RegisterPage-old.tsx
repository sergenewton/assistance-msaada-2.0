import React, { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useAuthHook } from '../../hooks/useAuthHook'
import { Eye, EyeOff, UserPlus, Phone, Mail, AlertCircle } from 'lucide-react'

// Schéma de validation pour l'inscription
const registerSchema = z.object({
  email: z
    .string()
    .optional()
    .refine((val) => !val || z.string().email().safeParse(val).success, {
      message: 'Format d\'email invalide'
    }),
  phone: z
    .string()
    .optional()
    .refine((val) => !val || /^\+?[1-9]\d{1,14}$/.test(val), {
      message: 'Format de téléphone invalide'
    }),
  password: z
    .string()
    .min(8, 'Le mot de passe doit contenir au moins 8 caractères')
    .regex(/[A-Z]/, 'Le mot de passe doit contenir au moins une majuscule')
    .regex(/[a-z]/, 'Le mot de passe doit contenir au moins une minuscule')
    .regex(/[0-9]/, 'Le mot de passe doit contenir au moins un chiffre')
    .regex(/[^A-Za-z0-9]/, 'Le mot de passe doit contenir au moins un caractère spécial'),
  confirmPassword: z.string(),
  role: z.enum(['survivante', 'aps', 'operateur', 'organisation', 'superviseur', 'admin']),
  organizationName: z.string().optional(),
  terms_accepted: z.boolean().refine((val) => val === true, {
    message: 'Vous devez accepter les conditions d\'utilisation'
  })
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Les mots de passe ne correspondent pas',
  path: ['confirmPassword']
}).refine((data) => data.email || data.phone, {
  message: 'L\'email ou le téléphone est requis',
  path: ['email']
})

type RegisterFormData = z.infer<typeof registerSchema>

// Schéma de validation simplifié
const registerSchema = z.object({
  username: z.string().min(3, 'Le nom d\'utilisateur doit contenir au moins 3 caractères'),
  fullName: z.string().min(2, 'Le nom complet est requis'),
  email: z.string().email('Format d\'email invalide'),
  phone: z.string().min(10, 'Numéro de téléphone requis'),
  password: z.string().min(6, 'Le mot de passe doit contenir au moins 6 caractères'),
  confirmPassword: z.string(),
  role: z.enum(['aps', 'operateur', 'organisation', 'superviseur']),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Les mots de passe ne correspondent pas',
  path: ['confirmPassword']
});

type RegisterFormData = z.infer<typeof registerSchema>

// Options de rôles pour professionnels (Frontend Web uniquement)
const roleOptions = [
  { value: 'aps', label: 'Agent Psychosocial (APS)' },
  { value: 'operateur', label: 'Opérateur Centre d\'Écoute' },
  { value: 'organisation', label: 'Organisation Partenaire' },
  { value: 'superviseur', label: 'Superviseur / Coordinateur' },
] as const

export const RegisterPage: React.FC = () => {
  const navigate = useNavigate()
  const { register: registerUser, isLoading, error } = useAuthHook()
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors, isValid }
  } = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
    mode: 'onChange'
  })

  const watchedRole = watch('role')

  const onSubmit = async (data: RegisterFormData) => {
    try {
      const registerData = {
        email: data.email || undefined,
        phone: data.phone || undefined,
        password: data.password,
        role: data.role,
        organization_name: data.organizationName,
        terms_accepted: data.terms_accepted
      }

      await registerUser(registerData)
      navigate('/dashboard', { replace: true })
    } catch (error) {
      console.error('Erreur lors de l\'inscription:', error)
    }
  }

  return (
    <div className="w-full max-w-md mx-auto">
      <div className="bg-white dark:bg-gray-800 shadow-2xl rounded-2xl p-8 border border-gray-100 dark:border-gray-700">
        {/* En-tête */}
        <div className="text-center mb-8">
          <Logo size="large" className="mx-auto mb-6" />
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
            Créer un compte
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            Rejoignez la plateforme de signalement VBG
          </p>
        </div>

        {/* Alertes d'erreur */}
        {error && (
          <Alert 
            type="error" 
            title="Erreur d'inscription"
            message={error}
            className="mb-6"
          />
        )}

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          {/* Sélection du rôle */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
              Type de compte *
            </label>
            <div className="grid grid-cols-1 gap-3">
              {roleOptions.map((option) => {
                const IconComponent = option.icon
                return (
                  <label
                    key={option.value}
                    className={`
                      relative flex items-start p-4 cursor-pointer rounded-lg border-2 transition-all
                      ${watchedRole === option.value 
                        ? 'border-purple-500 bg-purple-50 dark:bg-purple-900/20' 
                        : 'border-gray-200 dark:border-gray-600 hover:border-gray-300 dark:hover:border-gray-500'
                      }
                    `}
                  >
                    <input
                      type="radio"
                      value={option.value}
                      {...register('role')}
                      className="sr-only"
                    />
                    <IconComponent className="h-5 w-5 text-purple-600 mt-0.5 mr-3 flex-shrink-0" />
                    <div className="flex-1">
                      <div className="text-sm font-medium text-gray-900 dark:text-white">
                        {option.label}
                      </div>
                      <div className="text-xs text-gray-500 dark:text-gray-400">
                        {option.description}
                      </div>
                    </div>
                  </label>
                )
              })}
            </div>
            {errors.role && (
              <p className="mt-1 text-sm text-red-600 dark:text-red-400">
                {errors.role.message}
              </p>
            )}
          </div>

          {/* Email ou Téléphone */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <Input
                label="Email"
                type="email"
                icon={Mail}
                placeholder="votre@email.com"
                {...register('email')}
                error={errors.email?.message}
              />
            </div>
            <div>
              <Input
                label="Téléphone"
                type="tel"
                icon={Phone}
                placeholder="+243 900 000 000"
                {...register('phone')}
                error={errors.phone?.message}
              />
            </div>
          </div>

          {/* Organisation (si applicable) */}
          {watchedRole === 'organisation' && (
            <div>
              <Input
                label="Nom de l'organisation"
                type="text"
                placeholder="Nom de votre organisation"
                {...register('organizationName')}
                error={errors.organizationName?.message}
              />
            </div>
          )}

          {/* Mot de passe */}
          <div>
            <Input
              label="Mot de passe"
              type={showPassword ? 'text' : 'password'}
              placeholder="••••••••"
              {...register('password')}
              error={errors.password?.message}
              endIcon={
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                </button>
              }
            />
          </div>

          {/* Confirmation mot de passe */}
          <div>
            <Input
              label="Confirmer le mot de passe"
              type={showConfirmPassword ? 'text' : 'password'}
              placeholder="••••••••"
              {...register('confirmPassword')}
              error={errors.confirmPassword?.message}
              endIcon={
                <button
                  type="button"
                  onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  {showConfirmPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                </button>
              }
            />
          </div>

          {/* Conditions d'utilisation */}
          <div className="flex items-start">
            <div className="flex items-center h-5">
              <input
                type="checkbox"
                {...register('terms_accepted')}
                className="focus:ring-purple-500 h-4 w-4 text-purple-600 border-gray-300 rounded"
              />
            </div>
            <div className="ml-3 text-sm">
              <label className="text-gray-600 dark:text-gray-400">
                J'accepte les{' '}
                <Link to="/terms" className="text-purple-600 hover:text-purple-500">
                  conditions d'utilisation
                </Link>{' '}
                et la{' '}
                <Link to="/privacy" className="text-purple-600 hover:text-purple-500">
                  politique de confidentialité
                </Link>
              </label>
            </div>
          </div>
          {errors.terms_accepted && (
            <p className="text-sm text-red-600 dark:text-red-400">
              {errors.terms_accepted.message}
            </p>
          )}

          {/* Bouton d'inscription */}
          <Button
            type="submit"
            variant="primary"
            size="large"
            isLoading={isLoading}
            disabled={!isValid}
            className="w-full"
          >
            Créer le compte
          </Button>
        </form>

        {/* Lien vers la connexion */}
        <div className="mt-8 text-center">
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Vous avez déjà un compte ?{' '}
            <Link 
              to="/login" 
              className="font-medium text-purple-600 hover:text-purple-500 transition-colors"
            >
              Se connecter
            </Link>
          </p>
        </div>

        {/* Contacts d'urgence */}
        <div className="mt-8 p-4 bg-red-50 dark:bg-red-900/20 rounded-lg border border-red-200 dark:border-red-800">
          <h3 className="text-sm font-medium text-red-800 dark:text-red-200 mb-2">
            🆘 Urgence ? Contactez immédiatement :
          </h3>
          <div className="text-xs text-red-700 dark:text-red-300 space-y-1">
            <p>• Police : <strong>911</strong></p>
            <p>• Ligne d'écoute VBG : <strong>+243 800 000 000</strong></p>
            <p>• Centre médical : <strong>+243 900 000 000</strong></p>
          </div>
        </div>
      </div>
    </div>
  )
}