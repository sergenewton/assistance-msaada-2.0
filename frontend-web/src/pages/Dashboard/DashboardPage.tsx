import React from 'react'
import { RoleDashboard } from './RoleDashboard'

/**
 * Point d'entrée principal pour les tableaux de bord
 * Redirige automatiquement vers le dashboard approprié selon le rôle de l'utilisateur
 */
export const DashboardPage: React.FC = () => {
  return <RoleDashboard />
}