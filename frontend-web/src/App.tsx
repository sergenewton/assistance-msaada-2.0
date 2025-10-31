import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuthStore } from '@/store/authStore';

// Auth pages
import { LoginPage } from '@/pages/Auth/LoginPage';

// Dashboard pages
import { RoleDashboard, RoleProtectedRoute } from '@/pages/Dashboard/RoleDashboard';
import { APSDashboard } from '@/pages/Dashboard/APSDashboard';
import { OperatorDashboard } from '@/pages/Dashboard/OperatorDashboard';
import { OrganizationDashboard } from '@/pages/Dashboard/OrganizationDashboard';
import { AdminDashboard } from '@/pages/Dashboard/AdminDashboard';
import { SupervisorDashboard } from '@/pages/Dashboard/SupervisorDashboard';
import OperatorTriageUnprocessed from '@/pages/Triage/OperatorTriageUnprocessed';
import OperatorTriageUrgent from '@/pages/Triage/OperatorTriageUrgent';
import OperatorCaseView from '@/pages/Cases/OperatorCaseView';
import OperatorCaseTreatment from '@/pages/Cases/OperatorCaseTreatment';

// Test page
import { TestUsersPage } from '@/pages/TestUsers/TestUsersPage';

// Protected Route Component
interface ProtectedRouteProps {
  children: React.ReactNode;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const { isAuthenticated } = useAuthStore();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  return <>{children}</>;
};

// Public Route Component (redirect if authenticated)
interface PublicRouteProps {
  children: React.ReactNode;
}

const PublicRoute: React.FC<PublicRouteProps> = ({ children }) => {
  const { isAuthenticated } = useAuthStore();
  
  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />;
  }
  
  return <>{children}</>;
};

function App() {
  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
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
        
        {/* Test Routes - Available in development */}
        {process.env.NODE_ENV === 'development' && (
          <Route path="/test-users" element={<TestUsersPage />} />
        )}
        
        {/* Protected Routes */}
        <Route 
          path="/dashboard" 
          element={
            <ProtectedRoute>
              <RoleDashboard />
            </ProtectedRoute>
          } 
        />
        
        {/* Role-specific dashboards */}
        <Route 
          path="/dashboard/aps" 
          element={
            <ProtectedRoute>
              <APSDashboard />
            </ProtectedRoute>
          } 
        />
        
        <Route 
          path="/dashboard/operator" 
          element={
            <ProtectedRoute>
              <OperatorDashboard />
            </ProtectedRoute>
          } 
        />

        {/* Operator triage sub-routes */}
        <Route 
          path="/operator/triage/unprocessed" 
          element={
            <RoleProtectedRoute allowedRoles={["operateur"]}>
              <OperatorTriageUnprocessed />
            </RoleProtectedRoute>
          } 
        />
        <Route 
          path="/operator/triage/urgent" 
          element={
            <RoleProtectedRoute allowedRoles={["operateur"]}>
              <OperatorTriageUrgent />
            </RoleProtectedRoute>
          } 
        />
        {/* Operator cases */}
        <Route 
          path="/operator/cases/:id" 
          element={
            <RoleProtectedRoute allowedRoles={["operateur"]}>
              <OperatorCaseView />
            </RoleProtectedRoute>
          } 
        />
        <Route 
          path="/operator/cases/:id/traitement" 
          element={
            <RoleProtectedRoute allowedRoles={["operateur"]}>
              <OperatorCaseTreatment />
            </RoleProtectedRoute>
          } 
        />
        
        <Route 
          path="/dashboard/organization" 
          element={
            <ProtectedRoute>
              <OrganizationDashboard />
            </ProtectedRoute>
          } 
        />
        
        <Route 
          path="/dashboard/admin" 
          element={
            <ProtectedRoute>
              <AdminDashboard />
            </ProtectedRoute>
          } 
        />
        
        <Route 
          path="/dashboard/supervisor" 
          element={
            <ProtectedRoute>
              <SupervisorDashboard />
            </ProtectedRoute>
          } 
        />
        
        {/* Default redirect */}
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        
        {/* 404 - Route not found */}
        <Route 
          path="*" 
          element={
            <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
              <div className="text-center">
                <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-4">404</h1>
                <p className="text-gray-600 dark:text-gray-300 mb-8">Page non trouvée</p>
                <a 
                  href="/dashboard" 
                  className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Retour au tableau de bord
                </a>
              </div>
            </div>
          } 
        />
      </Routes>
    </div>
  );
}

export default App;
