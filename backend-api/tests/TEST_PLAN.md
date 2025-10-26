# 🧪 Plan de Tests - Système d'Authentification VBG

## Vue d'ensemble

Ce document décrit la stratégie de test complète pour le système d'authentification de la plateforme Assistance Msaada 2.0, spécialement conçue pour les cas de violences basées sur le genre (VBG).

## 📋 Objectifs de Test

### 🎯 Couverture Cible : 80% minimum

### 🔐 Domaines Critiques
1. **Sécurité** : Protection des données sensibles VBG
2. **Authentification** : JWT, multi-appareils, rate limiting
3. **Autorisation** : RBAC avec 6 rôles spécialisés VBG
4. **Validation** : Données strictes (email/téléphone DRC)
5. **Conformité** : GDPR, audit trail, confidentialité

## 🏗️ Architecture des Tests

### Backend (Laravel 11 + PHPUnit)
```
tests/
├── Unit/Auth/
│   ├── AuthControllerTest.php     ✅ Créé
│   └── AuthMiddlewareTest.php     ✅ Créé
├── Feature/Auth/
│   └── AuthIntegrationTest.php    ✅ Créé
└── Integration/
    └── CompleteAuthFlowTest.php   📝 À créer
```

### Frontend (React + Vitest)
```
src/tests/
├── auth/
│   ├── LoginPage.test.tsx         ✅ Créé
│   └── AuthHook.test.tsx          📝 À créer
├── services/
│   └── authService.test.ts        ✅ Créé
└── components/
    └── ui/                        📝 À créer
```

## 📊 Cas de Test Définis

### 🔧 Tests Unitaires Backend (25 tests)

#### AuthController (12 tests)
- ✅ `test_register_successful_with_valid_data`
- ✅ `test_register_fails_with_invalid_email`
- ✅ `test_register_fails_with_weak_password`
- ✅ `test_register_fails_without_terms_acceptance`
- ✅ `test_login_successful_with_email`
- ✅ `test_login_successful_with_phone`
- ✅ `test_login_fails_with_invalid_credentials`
- ✅ `test_logout_successful`
- ✅ `test_me_returns_user_data`
- ✅ `test_refresh_token_successful`
- ✅ `test_phone_registration_with_valid_drc_number`
- ✅ `test_register_with_organization_role_requires_organization_id`

#### Middleware RBAC (8 tests)
- ✅ `test_check_permission_middleware_allows_access_with_valid_permission`
- ✅ `test_check_permission_middleware_denies_access_without_permission`
- ✅ `test_check_permission_middleware_allows_admin_all_permissions`
- ✅ `test_check_role_middleware_allows_access_with_correct_role`
- ✅ `test_check_role_middleware_denies_access_with_wrong_role`
- ✅ `test_check_role_middleware_allows_multiple_roles`
- ✅ `test_middleware_denies_access_for_unauthenticated_user`
- ✅ `test_middleware_logs_permission_violations`

### 🔄 Tests d'Intégration Backend (8 tests)

#### Flux Complets (8 tests)
- ✅ `test_complete_survivor_registration_and_login_flow`
- ✅ `test_organization_staff_registration_with_organization`
- ✅ `test_phone_registration_and_login_flow`
- ✅ `test_token_refresh_flow`
- ✅ `test_multiple_device_login_support`
- ✅ `test_permission_based_access_control`
- ✅ `test_rate_limiting_on_login_attempts`
- ✅ `test_security_headers_and_response_format`

### 🎨 Tests Frontend (15+ tests)

#### Composant LoginPage (12 tests)
- ✅ `renders login form correctly`
- ✅ `validates form inputs correctly`
- ✅ `accepts valid email format`
- ✅ `accepts valid phone format`
- ✅ `rejects invalid identifier format`
- ✅ `calls login function on form submission`
- ✅ `shows loading state during authentication`
- ✅ `displays error message when authentication fails`
- ✅ `toggles password visibility`
- ✅ `navigates to correct dashboard based on user role`
- ✅ `displays VBG-specific emergency contact information`
- ✅ `handles keyboard navigation correctly`

#### Service Auth (12+ tests)
- ✅ `should login successfully with valid credentials`
- ✅ `should handle login failure with invalid credentials`
- ✅ `should handle network errors gracefully`
- ✅ `should register successfully with valid data`
- ✅ `should handle validation errors`
- ✅ `should set authentication token correctly`
- ✅ `should clear authentication data correctly`
- ✅ `should check authentication status correctly`
- ✅ Plus 4 tests de gestion d'erreurs

## 🚀 Scénarios de Test VBG Spécialisés

### 👥 Test par Rôle Utilisateur

#### Survivante
```php
// Permissions: reports.view, reports.create
// Accès: Créer/voir ses propres rapports uniquement
// Sécurité: Données hautement protégées
```

#### Agent de Protection Sociale (APS)
```php
// Permissions: reports.view, users.view (survivantes)  
// Accès: Voir rapports de sa zone géographique
// Workflow: Suivi et accompagnement
```

#### Opérateur
```php
// Permissions: reports.view, users.view, analytics.view
// Accès: Gestion opérationnelle quotidienne
// Données: Statistiques non personnalisées
```

#### Organisation
```php
// Permissions: reports.view (zone), analytics.view
// Accès: Données de leur organisation uniquement
// Reporting: Statistiques agrégées
```

#### Superviseur
```php
// Permissions: ALL except system.settings
// Accès: Supervision multi-organisations
// Audit: Logs d'accès et violations
```

#### Admin
```php
// Permissions: ALL
// Accès: Gestion complète du système
// Responsabilité: Sécurité globale
```

### 🔒 Tests de Sécurité VBG

#### Protection des Données Sensibles
- ✅ Chiffrement des attributs sensibles
- ✅ Audit trail complet
- ✅ Rate limiting anti-bruteforce
- ✅ Expiration automatique des sessions
- ✅ Multi-device avec révocation

#### Conformité Réglementaire
- ✅ Acceptation GDPR obligatoire
- ✅ Droit à l'effacement des données
- ✅ Logs d'accès non répudiables
- ✅ Anonymisation des statistiques
- ✅ Chiffrement des communications

## 📈 Métriques et KPIs

### Coverage Targets
| Component | Current | Target | Status |
|-----------|---------|--------|---------|
| Backend Auth | 🔄 | 85% | En cours |
| Frontend Auth | 🔄 | 80% | En cours |
| E2E Critical | 🔄 | 90% | Planifié |
| Security Tests | 🔄 | 95% | Planifié |

### Performance Benchmarks
- **Temps de connexion** : < 2s
- **Refresh token** : < 500ms  
- **Validation formulaire** : < 100ms
- **Rate limiting** : 5 tentatives/minute

## 🛠️ Commandes de Test

### Backend Laravel
```bash
# Tests unitaires seulement
php artisan test --testsuite=Unit

# Tests d'intégration seulement  
php artisan test --testsuite=Feature

# Tests auth spécifiquement
php artisan test --filter=Auth

# Avec couverture de code
php artisan test --coverage --min=80
```

### Frontend React
```bash
# Tests unitaires
npm run test:unit

# Tests avec couverture
npm run test:coverage

# Tests en mode watch
npm run test:watch

# Tests e2e
npm run test:e2e
```

## 🎯 Prochaines Étapes

### Phase 1 : Tests Backend ⏳
1. ✅ Finaliser les factories et seeders
2. 🔄 Exécuter la suite de tests complète
3. 📊 Mesurer la couverture de code
4. 🐛 Corriger les cas d'échec

### Phase 2 : Tests Frontend ⏳  
1. 🔄 Corriger les imports et mocks
2. ✅ Compléter les tests de composants
3. 🧪 Ajouter les tests d'intégration
4. 📱 Tests responsive et accessibilité

### Phase 3 : Tests E2E 📋
1. 📝 Cypress pour les flux complets
2. 🤖 Tests automatisés de sécurité
3. 📊 Tests de performance/charge
4. 🚀 Intégration CI/CD

---

**🎯 Objectif Final** : Système d'authentification VBG 100% testé, sécurisé et conforme aux standards internationaux de protection des données sensibles.

**📅 Timeline** : Tests complets finalisés avant déploiement production.

**🔐 Priorité Maximale** : Sécurité des survivantes et confidentialité des données VBG.