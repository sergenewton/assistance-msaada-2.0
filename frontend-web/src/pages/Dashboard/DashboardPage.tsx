import React from 'react'
import { useAuthStore } from '@/store/authStore'

export const DashboardPage: React.FC = () => {
  const { user } = useAuthStore()

  return (
    <div className="space-y-6">
      <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
          Tableau de bord
        </h1>
        <p className="text-gray-600 dark:text-gray-400 mb-6">
          Bienvenue sur la plateforme Assistance Msaada
        </p>
        
        {user && (
          <div className="bg-purple-50 dark:bg-purple-900/20 p-4 rounded-lg">
            <h2 className="text-lg font-semibold text-purple-900 dark:text-purple-100 mb-2">
              Informations utilisateur
            </h2>
            <div className="space-y-2 text-sm">
              <p className="text-purple-800 dark:text-purple-200">
                <strong>Email:</strong> {user.email || 'Non renseigné'}
              </p>
              <p className="text-purple-800 dark:text-purple-200">
                <strong>Téléphone:</strong> {user.phone || 'Non renseigné'}
              </p>
              <p className="text-purple-800 dark:text-purple-200">
                <strong>Rôle:</strong> {user.role}
              </p>
              <p className="text-purple-800 dark:text-purple-200">
                <strong>Permissions:</strong> {user.permissions?.join(', ') || 'Aucune'}
              </p>
            </div>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
            Signalements
          </h3>
          <p className="text-gray-600 dark:text-gray-400 text-sm">
            Gérer les signalements de VBG
          </p>
          <div className="mt-4">
            <button className="text-purple-600 hover:text-purple-700 text-sm font-medium">
              Voir les signalements →
            </button>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
            Profil
          </h3>
          <p className="text-gray-600 dark:text-gray-400 text-sm">
            Modifier vos informations
          </p>
          <div className="mt-4">
            <button className="text-purple-600 hover:text-purple-700 text-sm font-medium">
              Modifier le profil →
            </button>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
            Assistance
          </h3>
          <p className="text-gray-600 dark:text-gray-400 text-sm">
            Obtenir de l'aide et du support
          </p>
          <div className="mt-4">
            <button className="text-purple-600 hover:text-purple-700 text-sm font-medium">
              Contacter le support →
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}