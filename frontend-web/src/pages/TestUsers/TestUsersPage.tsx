import React from 'react';
import { TEST_USER_LIST, loginAsTestUser } from '@/utils/testUsers';

export const TestUsersPage: React.FC = () => {
  const handleLoginAsUser = (userKey: string) => {
    try {
      loginAsTestUser(userKey);
    } catch (error) {
      console.error('Erreur lors de la connexion test:', error);
      alert('Erreur lors de la connexion de test');
    }
  };

  const handleClearSession = () => {
    // Nettoyer toutes les données d'authentification
    localStorage.removeItem('assistance-msaada-auth');
    localStorage.removeItem('auth_token');
    localStorage.removeItem('auth_user');
    localStorage.removeItem('auth_expires_at');
    
    // Recharger la page
    window.location.reload();
  };

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="w-16 h-16 bg-green-600 rounded-full flex items-center justify-center mx-auto mb-4">
            <i className="fas fa-shield-alt text-white text-2xl"></i>
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Test des Dashboards - Assistance Msaada 2
          </h1>
          <p className="text-gray-600 max-w-2xl mx-auto">
            Testez les différents tableaux de bord en vous connectant avec les utilisateurs de test. 
            Chaque utilisateur dispose d'un rôle spécifique avec des permissions et modules différents.
          </p>
        </div>

        {/* Actions globales */}
        <div className="mb-8 text-center">
          <button
            onClick={handleClearSession}
            className="inline-flex items-center px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors mr-4"
          >
            <i className="fas fa-sign-out-alt mr-2"></i>
            Déconnecter et nettoyer la session
          </button>
          <span className="text-sm text-gray-500">
            Utilisez ce bouton pour revenir à l'état initial
          </span>
        </div>

        {/* Grille des utilisateurs de test */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {TEST_USER_LIST.map((user) => (
            <div
              key={user.key}
              className="bg-white rounded-lg shadow-md border border-gray-200 p-6 hover:shadow-lg transition-shadow"
            >
              {/* Avatar et info principale */}
              <div className="flex items-center mb-4">
                <div className="w-12 h-12 bg-gradient-to-br from-green-400 to-green-600 rounded-full flex items-center justify-center text-white font-bold text-lg">
                  {user.name.split(' ').map(n => n[0]).join('').substring(0, 2)}
                </div>
                <div className="ml-3">
                  <h3 className="text-lg font-semibold text-gray-900">{user.name}</h3>
                  <p className="text-sm text-green-600 font-medium">{user.role}</p>
                </div>
              </div>

              {/* Informations de l'utilisateur */}
              <div className="space-y-2 mb-6">
                <div className="flex items-center text-sm text-gray-600">
                  <i className="fas fa-envelope w-4 mr-2"></i>
                  <span className="truncate">{user.email}</span>
                </div>
                <div className="flex items-center text-sm text-gray-600">
                  <i className="fas fa-building w-4 mr-2"></i>
                  <span className="truncate">{user.organization}</span>
                </div>
              </div>

              {/* Description */}
              <p className="text-sm text-gray-700 mb-6 leading-relaxed">
                {user.description}
              </p>

              {/* Bouton de connexion */}
              <button
                onClick={() => handleLoginAsUser(user.key)}
                className="w-full bg-green-600 text-white py-2 px-4 rounded-lg hover:bg-green-700 transition-colors flex items-center justify-center"
              >
                <i className="fas fa-sign-in-alt mr-2"></i>
                Se connecter en tant que {user.name}
              </button>
            </div>
          ))}
        </div>

        {/* Informations supplémentaires */}
        <div className="mt-12 bg-blue-50 border border-blue-200 rounded-lg p-6">
          <h3 className="text-lg font-semibold text-blue-900 mb-4 flex items-center">
            <i className="fas fa-info-circle mr-2"></i>
            Instructions de test
          </h3>
          <div className="space-y-3 text-sm text-blue-800">
            <div className="flex items-start">
              <span className="font-medium min-w-0 mr-2">1.</span>
              <span>Cliquez sur "Se connecter" pour un utilisateur pour simuler sa connexion</span>
            </div>
            <div className="flex items-start">
              <span className="font-medium min-w-0 mr-2">2.</span>
              <span>Vous serez automatiquement redirigé vers le dashboard correspondant à son rôle</span>
            </div>
            <div className="flex items-start">
              <span className="font-medium min-w-0 mr-2">3.</span>
              <span>Explorez les modules, menus et fonctionnalités disponibles pour ce rôle</span>
            </div>
            <div className="flex items-start">
              <span className="font-medium min-w-0 mr-2">4.</span>
              <span>Utilisez "Déconnecter" pour revenir à cette page et tester un autre utilisateur</span>
            </div>
          </div>
        </div>

        {/* Dashboards disponibles */}
        <div className="mt-8 bg-gray-50 border border-gray-200 rounded-lg p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">
            Dashboards à tester
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div className="space-y-2">
              <div className="flex items-center">
                <div className="w-3 h-3 bg-blue-500 rounded-full mr-2"></div>
                <span className="font-medium">Agent Psychosocial (APS)</span>
              </div>
              <div className="flex items-center">
                <div className="w-3 h-3 bg-green-500 rounded-full mr-2"></div>
                <span className="font-medium">Opérateur Centre d'Écoute</span>
              </div>
              <div className="flex items-center">
                <div className="w-3 h-3 bg-purple-500 rounded-full mr-2"></div>
                <span className="font-medium">Organisation Partenaire</span>
              </div>
            </div>
            <div className="space-y-2">
              <div className="flex items-center">
                <div className="w-3 h-3 bg-indigo-500 rounded-full mr-2"></div>
                <span className="font-medium">Superviseur/Coordinateur</span>
              </div>
              <div className="flex items-center">
                <div className="w-3 h-3 bg-red-500 rounded-full mr-2"></div>
                <span className="font-medium">Administrateur Système</span>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-12 text-center text-sm text-gray-500">
          <p>
            🔧 Page de test pour le développement - Version 2.0.0
          </p>
          <p className="mt-1">
            Les données affichées sont fictives et à des fins de démonstration uniquement.
          </p>
        </div>
      </div>
    </div>
  );
};