# 🌳 Stratégie de Branches - VBG Platform

## 🎯 GitHub Flow Adapté

Nous utilisons une version adaptée de GitHub Flow pour notre monorepo, optimisée pour les 3 applications.

## 📋 Structure des Branches

### Branches Principales
```
main                    # 🚀 Production (toujours déployable)
└── develop            # 🔄 Intégration continue (pré-production)
```

### Branches de Travail
```
feature/[scope]/[description]    # ✨ Nouvelles fonctionnalités
hotfix/[scope]/[description]     # 🚨 Corrections urgentes
release/v[version]               # 📦 Préparation des releases
```

## 🏷️ Conventions de Nommage

### Feature Branches
```bash
# Format: feature/[scope]/[kebab-case-description]
feature/api/user-authentication
feature/web/dashboard-redesign  
feature/mobile/push-notifications
feature/shared/type-definitions
```

### Hotfix Branches
```bash
# Format: hotfix/[scope]/[kebab-case-description]
hotfix/api/security-vulnerability
hotfix/web/login-redirect-bug
hotfix/mobile/crash-on-startup
```

### Release Branches
```bash
# Format: release/v[major].[minor].[patch]
release/v1.0.0
release/v1.1.0
release/v2.0.0-beta.1
```

## 🔄 Workflow Détaillé

### 1. Feature Development
```bash
# Créer une nouvelle branche depuis develop
git checkout develop
git pull origin develop
git checkout -b feature/api/user-profiles

# Développer et commiter
git add .
git commit -m "feat(api): add user profile endpoints"

# Pousser et créer PR
git push origin feature/api/user-profiles
# Créer Pull Request: feature/api/user-profiles → develop
```

### 2. Code Review & Tests
```yaml
# Automatique via GitHub Actions
- Lint & Format check
- Unit tests
- Integration tests  
- Security scan
- Performance check
```

### 3. Integration (develop)
```bash
# Merge après approbation
git checkout develop
git merge feature/api/user-profiles --no-ff
git push origin develop

# Suppression de la branche
git branch -d feature/api/user-profiles
git push origin --delete feature/api/user-profiles
```

### 4. Release Process
```bash
# Création branche release
git checkout develop
git checkout -b release/v1.1.0

# Préparation release (bump version, changelog, etc.)
# Tests finaux, corrections mineures uniquement

# Merge vers main
git checkout main
git merge release/v1.1.0 --no-ff
git tag v1.1.0
git push origin main --tags

# Merge back vers develop
git checkout develop  
git merge release/v1.1.0 --no-ff
git push origin develop
```

### 5. Hotfix Process  
```bash
# Créer depuis main
git checkout main
git checkout -b hotfix/api/critical-security-fix

# Fix et test
git commit -m "fix(api): resolve SQL injection vulnerability"

# Merge vers main
git checkout main
git merge hotfix/api/critical-security-fix --no-ff
git tag v1.1.1
git push origin main --tags

# Merge vers develop
git checkout develop
git merge hotfix/api/critical-security-fix --no-ff
git push origin develop
```

## 🎯 Scopes Disponibles

| Scope | Description | Exemples |
|-------|-------------|----------|
| `api` | Backend Laravel | `feature/api/auth-system` |
| `web` | Frontend React | `feature/web/user-dashboard` |  
| `mobile` | App Flutter | `feature/mobile/offline-mode` |
| `shared` | Code partagé | `feature/shared/api-types` |
| `docs` | Documentation | `feature/docs/api-reference` |
| `ci` | CI/CD Pipeline | `feature/ci/docker-optimization` |
| `infra` | Infrastructure | `feature/infra/kubernetes-setup` |

## 🚫 Règles Importantes

### ❌ Interdictions
- Pas de commit direct sur `main`
- Pas de commit direct sur `develop`  
- Pas de merge sans review
- Pas de force push sur branches partagées

### ✅ Bonnes Pratiques
- Branches courtes (< 1 semaine)
- Commits atomiques et descriptifs
- Tests passants obligatoires
- Code review par au moins 1 personne
- Rebase avant merge pour historique propre

## 🔄 Protection des Branches

### Main Branch
```yaml
Protection Rules:
- Require PR reviews (min: 1)
- Require status checks
- Require branches to be up to date
- Restrict pushes (admins only)
- Require signed commits
```

### Develop Branch  
```yaml
Protection Rules:
- Require PR reviews (min: 1)
- Require status checks
- Allow admins to bypass
```

## 🚀 Déploiement Automatique

```yaml
Triggers:
  main: 
    - Production deployment
    - Docker images build
    - Documentation update
    
  develop:
    - Staging deployment  
    - Preview environments
    - Integration tests
    
  feature/*:
    - Feature preview (optionnel)
    - Lint & tests only
```