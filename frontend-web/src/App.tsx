import React from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuthStore } from '@/store/authStore'
import { LoginPage } from '@/pages/Auth/LoginPage'
import { RegisterPage } from '@/pages/Auth/RegisterPage'
import { AccountPendingPage } from '@/pages/Auth/AccountPendingPage'

// Simple Dashboard Component
const SimpleDashboard: React.FC = () => {
  const { user, logout } = useAuthStore()
  
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header moderne */}
      <header className="nav-desktop">
        <div className="nav-desktop-content responsive-container">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <h1 className="text-xl font-bold text-purple-600">Assistance Msaada</h1>
            </div>
            <div className="hidden md:block ml-8">
              <nav className="flex space-x-8">
                <a href="#" className="text-gray-900 hover:text-purple-600 px-3 py-2 rounded-md text-sm font-medium">
                  Tableau de bord
                </a>
                <a href="#" className="text-gray-500 hover:text-purple-600 px-3 py-2 rounded-md text-sm font-medium">
                  Signalements
                </a>
                <a href="#" className="text-gray-500 hover:text-purple-600 px-3 py-2 rounded-md text-sm font-medium">
                  Profil
                </a>
              </nav>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            <span className="text-sm text-gray-700">
              Bienvenue, <span className="font-medium">{user?.email || 'Utilisateur'}</span>
            </span>
            <button
              onClick={logout}
              className="btn-desktop-primary"
            >
              Se déconnecter
            </button>
          </div>
        </div>
      </header>

      {/* Contenu principal */}
      <main className="responsive-container py-8">
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-gray-900 mb-2">
            Tableau de bord
          </h2>
          <p className="text-gray-600">
            Gérez vos signalements et accédez aux services de protection
          </p>
        </div>

        {/* Informations utilisateur */}
        {user && (
          <div className="bg-white rounded-lg shadow p-6 mb-8">
            <h3 className="text-xl font-semibold text-gray-900 mb-4">
              Informations utilisateur
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div className="bg-purple-50 p-4 rounded-lg">
                <h4 className="font-medium text-purple-900 mb-1">Email</h4>
                <p className="text-sm text-purple-800">{user.email || 'Non renseigné'}</p>
              </div>
              <div className="bg-purple-50 p-4 rounded-lg">
                <h4 className="font-medium text-purple-900 mb-1">Téléphone</h4>
                <p className="text-sm text-purple-800">{user.phone || 'Non renseigné'}</p>
              </div>
              <div className="bg-purple-50 p-4 rounded-lg">
                <h4 className="font-medium text-purple-900 mb-1">Rôle</h4>
                <p className="text-sm text-purple-800">{user.role}</p>
              </div>
              <div className="bg-purple-50 p-4 rounded-lg">
                <h4 className="font-medium text-purple-900 mb-1">Permissions</h4>
                <p className="text-sm text-purple-800">{user.permissions?.join(', ') || 'Aucune'}</p>
              </div>
            </div>
          </div>
        )}

        {/* Cartes de services */}
        <div className="grid-desktop-1 grid-desktop-2 grid-desktop-3">
          <div className="bg-white rounded-lg shadow p-6 hover:shadow-md transition-shadow">
            <div className="flex items-center mb-4">
              <div className="p-3 bg-red-100 rounded-lg mr-4">
                <svg className="h-6 w-6 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.996-.833-2.464 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z" />
                </svg>
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">Signalements</h3>
                <p className="text-sm text-gray-500">Nouveau signalement VBG</p>
              </div>
            </div>
            <p className="text-gray-600 text-sm mb-4">
              Créer un nouveau signalement de violence basée sur le genre
            </p>
            <button className="btn-desktop-primary w-full">
              Nouveau signalement
            </button>
          </div>

          <div className="bg-white rounded-lg shadow p-6 hover:shadow-md transition-shadow">
            <div className="flex items-center mb-4">
              <div className="p-3 bg-blue-100 rounded-lg mr-4">
                <svg className="h-6 w-6 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">Mon Profil</h3>
                <p className="text-sm text-gray-500">Gérer mes informations</p>
              </div>
            </div>
            <p className="text-gray-600 text-sm mb-4">
              Modifier vos informations personnelles et paramètres de sécurité
            </p>
            <button className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition-colors">
              Modifier le profil
            </button>
          </div>

          <div className="bg-white rounded-lg shadow p-6 hover:shadow-md transition-shadow">
            <div className="flex items-center mb-4">
              <div className="p-3 bg-green-100 rounded-lg mr-4">
                <svg className="h-6 w-6 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192L5.636 18.364M12 2.25a9.75 9.75 0 109.75 9.75 9.75 9.75 0 00-9.75-9.75z" />
                </svg>
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">Aide & Support</h3>
                <p className="text-sm text-gray-500">Assistance 24h/7j</p>
              </div>
            </div>
            <p className="text-gray-600 text-sm mb-4">
              Accéder au support psychosocial et à l'aide d'urgence
            </p>
            <button className="w-full bg-green-600 hover:bg-green-700 text-white font-medium py-2 px-4 rounded-lg transition-colors">
              Contacter le support
            </button>
          </div>
        </div>

        {/* Contacts d'urgence */}
        <div className="mt-8 bg-red-50 border border-red-200 rounded-lg p-6">
          <div className="flex items-center mb-4">
            <svg className="h-6 w-6 text-red-600 mr-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.996-.833-2.464 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
            <h3 className="text-lg font-semibold text-red-800">🆘 Contacts d'urgence</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
            <div>
              <h4 className="font-medium text-red-800 mb-1">Police</h4>
              <a href="tel:112" className="text-red-700 hover:text-red-900 font-semibold">
                📞 112
              </a>
            </div>
            <div>
              <h4 className="font-medium text-red-800 mb-1">Ligne VBG 24h/7j</h4>
              <a href="tel:+243800000000" className="text-red-700 hover:text-red-900 font-semibold">
                📞 +243 800 000 000
              </a>
            </div>
            <div>
              <h4 className="font-medium text-red-800 mb-1">Centre médical</h4>
              <a href="tel:+243900000000" className="text-red-700 hover:text-red-900 font-semibold">
                📞 +243 900 000 000
              </a>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}

// Loading Component
const LoadingSpinner: React.FC = () => (
  <div className="min-h-screen flex items-center justify-center">
    <div className="animate-spin rounded-full h-8 w-8 border-2 border-gray-300 border-t-purple-600" />
  </div>
)

// Auth Layout optimisé pour desktop
const AuthLayout: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div className="min-h-screen bg-gradient-to-br from-purple-50 to-blue-50">
    {children}
  </div>
)

// Protected Route Component
const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, isLoading } = useAuthStore()
  
  if (isLoading) {
    return <LoadingSpinner />
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }
  
  return <>{children}</>
}

// Public Route Component
const PublicRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, isLoading } = useAuthStore()
  
  if (isLoading) {
    return <LoadingSpinner />
  }
  
  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />
  }
  
  return <AuthLayout>{children}</AuthLayout>
}

// Main App Component
const App: React.FC = () => {
  return (
    <div className="App">
      <Routes>
        {/* Public Routes */}
        <Route 
          path="/login" 
          element={
            <PublicRoute>
              <LoginPage />
            </PublicRoute>
          } 
        />
        
        <Route 
          path="/register" 
          element={
            <PublicRoute>
              <RegisterPage />
            </PublicRoute>
          } 
        />
        
        <Route 
          path="/auth/login" 
          element={
            <PublicRoute>
              <LoginPage />
            </PublicRoute>
          } 
        />
        
        <Route 
          path="/auth/register" 
          element={
            <PublicRoute>
              <RegisterPage />
            </PublicRoute>
          } 
        />
        
        {/* Account Pending Page (accessible sans authentification) */}
        <Route 
          path="/auth/account-pending" 
          element={<AccountPendingPage />} 
        />
        
        {/* Protected Routes */}
        <Route 
          path="/dashboard" 
          element={
            <ProtectedRoute>
              <SimpleDashboard />
            </ProtectedRoute>
          } 
        />
        
        {/* Default redirect */}
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        
        {/* 404 */}
        <Route 
          path="*" 
          element={
            <AuthLayout>
              <div className="bg-white p-8 rounded-lg shadow text-center">
                <h1 className="text-2xl font-bold text-gray-900 mb-4">
                  Page non trouvée
                </h1>
                <p className="text-gray-600 mb-4">
                  La page que vous recherchez n'existe pas.
                </p>
                <Navigate to="/" replace />
              </div>
            </AuthLayout>
          } 
        />
      </Routes>
    </div>
  )
}

export default App