import React from 'react';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';

export const TestRoutePage: React.FC = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50 flex items-center justify-center p-8">
      <div className="bg-white rounded-2xl shadow-2xl p-12 max-w-2xl">
        <div className="text-center">
          <div className="text-6xl mb-6">🎉</div>
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Route de Test Fonctionne !
          </h1>
          <p className="text-xl text-gray-600 mb-6">
            Si vous voyez cette page, React Router charge bien les nouveaux composants.
          </p>
          <div className="bg-green-50 border-2 border-green-200 rounded-lg p-6 mb-6">
            <p className="text-green-800 font-semibold text-lg">
              ✓ Le composant TestRoutePage a été chargé
            </p>
            <p className="text-green-700 mt-2">
              ✓ React Router fonctionne correctement
            </p>
            <p className="text-green-700">
              ✓ Vite compile et sert les nouveaux fichiers
            </p>
          </div>
          <div className="space-y-3">
            <a 
              href="/admin/users/list" 
              className="block bg-blue-600 text-white px-8 py-3 rounded-lg hover:bg-blue-700 transition-colors font-semibold"
            >
              → Aller à /admin/users/list
            </a>
            <a 
              href="/admin/users/roles" 
              className="block bg-purple-600 text-white px-8 py-3 rounded-lg hover:bg-purple-700 transition-colors font-semibold"
            >
              → Aller à /admin/users/roles
            </a>
            <a 
              href="/dashboard/admin" 
              className="block bg-gray-600 text-white px-8 py-3 rounded-lg hover:bg-gray-700 transition-colors font-semibold"
            >
              ← Retour Dashboard Admin
            </a>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TestRoutePage;
