# 🧪 Guide de Test - Système de Tableaux de Bord par Rôles

## 📋 Vue d'ensemble

Ce guide vous permet de tester le système de redirection automatique vers les différents tableaux de bord selon le rôle de l'utilisateur connecté.

## 🚀 Démarrage Rapide

### 1. Lancer le serveur de développement
```bash
cd frontend-web
npm run dev
```

### 2. Accéder à la page de test
Ouvrir dans le navigateur : `http://localhost:3000/test-users`

## 👥 Utilisateurs de Test Disponibles

| Rôle | Email | Mot de passe | Dashboard cible |
|------|-------|-------------|----------------|
| **APS** | aps@msaada.com | password123 | `/dashboard/aps` |
| **Opérateur** | operator@msaada.com | password123 | `/dashboard/operator` |
| **Organisation** | org@msaada.com | password123 | `/dashboard/organization` |
| **Admin** | admin@msaada.com | password123 | `/dashboard/admin` |
| **Superviseur** | supervisor@msaada.com | password123 | `/dashboard/supervisor` |

## 🎯 Processus de Test

### Étape 1: Test de Redirection par Rôle
1. Sur la page `/test-users`, cliquer sur "Se connecter" pour un utilisateur
2. Vérifier que la redirection s'effectue vers le bon dashboard
3. Confirmer que l'interface correspond au rôle (navigation, modules, actions)

### Étape 2: Test des Fonctionnalités par Dashboard

#### 🩺 **APS Dashboard** (`/dashboard/aps`)
- ✅ Gestion des cas assignés
- ✅ Communication sécurisée
- ✅ Suivi des victimes
- ✅ Rapports d'intervention
- ✅ Planning et disponibilités

#### 📞 **Opérateur Dashboard** (`/dashboard/operator`)  
- ✅ Triage des signalements
- ✅ Attribution des cas
- ✅ Suivi global des cas
- ✅ Coordination organisations
- ✅ Métriques opérationnelles

#### 🏢 **Organisation Dashboard** (`/dashboard/organization`)
- ✅ Gestion des références
- ✅ Suivi des prises en charge
- ✅ Communication coordination
- ✅ Rapports d'activité
- ✅ Gestion capacités

#### 👨‍💼 **Admin Dashboard** (`/dashboard/admin`)
- ✅ Gestion système complète
- ✅ Administration utilisateurs
- ✅ Configuration sécurité
- ✅ Monitoring performance
- ✅ Audit et logs

#### 👨‍💼 **Superviseur Dashboard** (`/dashboard/supervisor`)
- ✅ Vue d'ensemble stratégique
- ✅ Supervision équipes
- ✅ Contrôle qualité
- ✅ Rapports de performance
- ✅ Prise de décisions

### Étape 3: Test de Protection des Routes
1. Essayer d'accéder directement à un dashboard d'un autre rôle
2. Vérifier que l'accès est bloqué ou redirigé
3. Confirmer les permissions appropriées

## 🔧 Fonctionnalités Testées

### Authentification et Autorisation
- [x] Login avec utilisateurs de test
- [x] Stockage sécurisé des tokens
- [x] Redirection automatique par rôle
- [x] Protection des routes sensibles

### Interface Utilisateur
- [x] Layouts responsifs pour chaque rôle
- [x] Navigation contextuelle
- [x] Modules pertinents par rôle
- [x] Actions rapides appropriées
- [x] Cohérence visuelle

### Performance et UX
- [x] Temps de chargement optimisés
- [x] Transitions fluides
- [x] Feedback utilisateur approprié
- [x] États de chargement

## 🚨 Points de Vigilance lors des Tests

### Vérifications Obligatoires
1. **Redirection correcte** : Chaque rôle arrive sur SON dashboard
2. **Navigation contextuelle** : Menu adapté aux permissions
3. **Actions disponibles** : Boutons/modules selon le rôle
4. **Données affichées** : Informations pertinentes au contexte
5. **Protection** : Pas d'accès aux ressources non autorisées

### Indicateurs de Succès
- ✅ Aucune erreur de console
- ✅ Chargement fluide des dashboards
- ✅ Navigation intuitive
- ✅ Données cohérentes affichées
- ✅ Actions fonctionnelles (même si simulées)

## 🔍 Dépannage

### Problèmes Courants

**🚫 Dashboard ne se charge pas**
- Vérifier que le serveur est démarré (`npm run dev`)
- Consulter la console pour les erreurs
- Vérifier les imports des composants

**🔄 Redirection incorrecte**
- Vérifier `src/utils/roleRouting.ts`
- Confirmer le rôle utilisateur dans authStore
- Vérifier la logique de `RoleDashboard.tsx`

**🎨 Styles manquants**
- Vérifier Tailwind CSS est chargé
- Confirmer les imports CSS dans main.tsx
- Vérifier les classes CSS utilisées

## 📊 Rapport de Test

Après avoir testé tous les rôles, documenter :

| Rôle | Dashboard Charge | Navigation OK | Actions OK | Données OK | Notes |
|------|------------------|---------------|------------|------------|-------|
| APS | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | |
| Opérateur | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | |
| Organisation | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | |
| Admin | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | |
| Superviseur | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | |

## 🎯 Prochaines Étapes

Une fois les tests validés :
1. Intégrer avec l'API backend réelle
2. Implémenter la persistence des données
3. Ajouter les tests unitaires automatisés
4. Préparer le déploiement en staging

---

**🎉 Bon testing !** N'hésitez pas à documenter tous les problèmes rencontrés pour améliorer le système.