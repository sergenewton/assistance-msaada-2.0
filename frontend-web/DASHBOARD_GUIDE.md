# Dashboards par Rôle - Assistance Msaada 2

## Vue d'ensemble

Ce document décrit l'implémentation des tableaux de bord spécialisés par rôle utilisateur dans la plateforme Assistance Msaada 2. Chaque rôle dispose d'une interface adaptée à ses permissions et responsabilités.

## Architecture

### Structure des Fichiers

```
src/
├── components/
│   ├── Layout/
│   │   ├── DashboardLayout.tsx    # Layout principal des dashboards
│   │   ├── Header.tsx             # En-tête commun
│   │   ├── Sidebar.tsx            # Barre latérale de navigation
│   │   └── index.ts
│   └── Dashboard/
│       ├── StatsCard.tsx          # Cartes de statistiques
│       ├── ModuleCard.tsx         # Cartes des modules
│       ├── RecentCases.tsx        # Liste des cas récents
│       └── index.ts
├── pages/Dashboard/
│   ├── DashboardPage.tsx          # Point d'entrée principal
│   ├── RoleDashboard.tsx          # Routeur intelligent par rôle
│   ├── APSDashboard.tsx           # Dashboard Agent Psychosocial
│   ├── OperatorDashboard.tsx      # Dashboard Opérateur Centre d'Écoute
│   ├── OrganizationDashboard.tsx  # Dashboard Organisation Partenaire
│   ├── AdminDashboard.tsx         # Dashboard Administrateur Système
│   ├── SupervisorDashboard.tsx    # Dashboard Superviseur/Coordinateur
│   └── index.ts
├── types/
│   └── dashboard.ts               # Types TypeScript pour les dashboards
└── utils/
    └── roleRouting.ts             # Utilitaires de routage par rôle
```

## Dashboards par Rôle

### 1. Agent Psychosocial (APS)
**Route:** `/dashboard/aps`

**Modules disponibles:**
- ✅ Gestion des Cas (Cas assignés, suivi, documentation)
- ✅ Communication Sécurisée (Chat avec survivantes)
- ✅ Rapports et Statistiques (Rapports d'étape)
- 🔄 Feedback et Évaluation (En développement)

**Fonctionnalités clés:**
- Vue des cas assignés uniquement
- Mise à jour des statuts de prise en charge
- Documentation des séances d'accompagnement
- Demande de référencements complémentaires
- Génération de rapports d'étape

### 2. Opérateur Centre d'Écoute
**Route:** `/dashboard/operator`

**Modules disponibles:**
- ✅ Gestion des Cas (Triage, évaluation, attribution)
- ✅ Alertes et Notifications (Alertes temps réel)
- ✅ Communication Sécurisée (Coordination équipes)
- ✅ Rapports et Statistiques (Vue globale)
- 🔄 Sécurité Avancée (En développement)

**Fonctionnalités clés:**
- Réception et triage de tous les signalements
- Évaluation du niveau d'urgence et de danger
- Attribution des APS aux cas
- Suivi global de l'évolution des cas
- Relance des organisations en retard
- Validation de la clôture des cas

### 3. Organisation Partenaire
**Route:** `/dashboard/organization`

**Modules disponibles:**
- ✅ Gestion des Cas (Cas référencés, acceptation/déclinaison)
- ✅ Communication Sécurisée (Coordination référencements)
- ✅ Rapports et Statistiques (Historique interventions)
- 🔄 Feedback et Évaluation (En développement)

**Fonctionnalités clés:**
- Réception des cas référencés dans leur domaine
- Acceptation ou déclinaison avec justification
- Mise à jour du statut d'avancement
- Upload de documents (certificats, PV, etc.)
- Proposition de référencements croisés
- Consultation de l'historique des cas

### 4. Administrateur Système
**Route:** `/dashboard/admin`

**Modules disponibles:**
- ✅ Authentification & Sécurité (Gestion utilisateurs)
- ✅ Gestion des Cas (Vue administrative)
- ✅ Sensibilisation (Gestion contenus)
- ✅ Communication Sécurisée (Supervision)
- ✅ Alertes et Notifications (Configuration)
- ✅ Rapports et Statistiques (Accès complet)
- 🔄 Feedback et Évaluation (En développement)
- ✅ Sécurité Avancée (Audit, logs)

**Fonctionnalités clés:**
- Gestion complète des utilisateurs et accès
- Configuration des paramètres système
- Gestion des organisations partenaires
- Consultation des logs d'audit
- Gestion des sauvegardes
- Configuration des alertes et notifications
- Gestion des contenus de sensibilisation
- Export de données anonymisées

### 5. Superviseur/Coordinateur
**Route:** `/dashboard/supervisor`

**Modules disponibles:**
- ✅ Supervision des Cas (Vue d'ensemble complète)
- ✅ Sensibilisation Stratégique (Campagnes, impact)
- ✅ Communication Stratégique (Coordination globale)
- ✅ Alertes Stratégiques (KPIs, performances)
- ✅ Analytics Avancées (Rapports stratégiques)
- ✅ Évaluation Performance (Métriques globales)
- ✅ Sécurité Opérationnelle (Conformité)

**Fonctionnalités clés:**
- Accès complet aux tableaux de bord
- Vue consolidée de tous les cas
- Génération de rapports stratégiques
- Supervision des performances (temps de réponse, etc.)
- Réaffectation de cas en cas de problème
- Export de données statistiques anonymisées
- Monitoring des KPIs

## Composants Réutilisables

### DashboardLayout
Layout principal intégrant sidebar, header et zone de contenu.

```tsx
<DashboardLayout
  title="Titre du dashboard"
  subtitle="Description optionnelle"
  navigationItems={navigationItems}
  userRole={userRole}
>
  {children}
</DashboardLayout>
```

### StatsCard
Carte d'affichage de statistiques avec tendances optionnelles.

```tsx
<StatsCard
  title="Titre"
  value={42}
  icon="fas fa-icon"
  color="blue"
  trend={{ value: 12, isPositive: true }}
  onClick={() => {}}
/>
```

### ModuleCard
Carte représentant un module fonctionnel.

```tsx
<ModuleCard
  module={moduleConfig}
  onClick={() => handleModuleClick(module.id)}
/>
```

### RecentCases
Composant d'affichage des cas récents avec actions.

```tsx
<RecentCases
  cases={cases}
  title="Cas récents"
  onViewAll={() => {}}
  onCaseClick={(id) => {}}
/>
```

## Système de Routage

### Routage Intelligent
Le composant `RoleDashboard` détermine automatiquement le dashboard à afficher selon le rôle de l'utilisateur connecté.

```tsx
// Utilisation simple
<RoleDashboard />
```

### Protection des Routes
Le composant `RoleProtectedRoute` protège l'accès aux routes selon les rôles autorisés.

```tsx
<RoleProtectedRoute allowedRoles={['admin', 'superviseur']}>
  <AdminFeature />
</RoleProtectedRoute>
```

### Configuration des Routes
```typescript
export const ROLE_ROUTES: Record<UserRole, string> = {
  aps: '/dashboard/aps',
  operateur: '/dashboard/operator',
  organisation: '/dashboard/organization',
  admin: '/dashboard/admin',
  superviseur: '/dashboard/supervisor',
  survivante: '/dashboard/survivor'
};
```

## Permissions et Sécurité

### Système de Permissions
Chaque rôle dispose de permissions spécifiques définies dans `ROLE_PERMISSIONS`.

```typescript
export const ROLE_PERMISSIONS: Record<UserRole, string[]> = {
  aps: [
    'cases.view.assigned',
    'cases.update.status',
    'communication.secure.chat',
    // ...
  ],
  // ...
};
```

### Modules par Rôle
Les modules disponibles pour chaque rôle sont définis dans `ROLE_MODULES`.

```typescript
export const ROLE_MODULES: Record<UserRole, ModuleType[]> = {
  aps: [
    'case-management',
    'secure-communication',
    'reports-statistics',
    'feedback-evaluation'
  ],
  // ...
};
```

## Développement Future

### Modules à Développer
- 🔄 **Feedback et Évaluation** - Interface d'évaluation continue
- 🔄 **Sécurité Avancée** - Détection d'intrusions, audit complet
- 🔄 **Dashboard Survivante** - Interface dédiée aux bénéficiaires

### Améliorations Prévues
- Graphiques interactifs (Chart.js/D3.js)
- Notifications en temps réel (WebSocket)
- Export avancé de données
- Interface mobile optimisée
- Thème sombre complet

## Guide d'Intégration

### 1. Ajout d'un Nouveau Rôle
1. Ajouter le rôle dans `UserRole` type
2. Créer le dashboard correspondant
3. Ajouter les routes dans `ROLE_ROUTES`
4. Définir les permissions dans `ROLE_PERMISSIONS`
5. Configurer les modules dans `ROLE_MODULES`
6. Mettre à jour `RoleDashboard.tsx`

### 2. Ajout d'un Nouveau Module
1. Ajouter le type dans `ModuleType`
2. Créer la configuration du module
3. Développer l'interface du module
4. Ajouter aux rôles appropriés dans `ROLE_MODULES`
5. Implémenter les permissions associées

### 3. Utilisation
```tsx
import { DashboardPage } from '@/pages/Dashboard';

// Dans votre router
<Route path="/dashboard" component={DashboardPage} />
```

## Support et Maintenance

- **Version actuelle:** 2.0.0
- **Dernière mise à jour:** Octobre 2024
- **Technologies:** React, TypeScript, Tailwind CSS, Zustand
- **Compatibilité:** Navigateurs modernes, mobile responsive

## Contact
Pour toute question sur l'implémentation des dashboards, contactez l'équipe technique du projet Assistance Msaada 2.