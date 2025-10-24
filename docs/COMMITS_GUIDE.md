# 📝 Guide des Conventional Commits - VBG Platform

## 🎯 Format Standard

```
type(scope): description

[optional body]

[optional footer(s)]
```

## 📋 Types de Commits

| Type | Emoji | Description | Exemple |
|------|-------|-------------|---------|
| `feat` | ✨ | Nouvelle fonctionnalité | `feat(api): add user authentication` |
| `fix` | 🐛 | Correction de bug | `fix(web): resolve login redirect issue` |
| `docs` | 📚 | Documentation | `docs: update API documentation` |
| `style` | 💄 | Formatage, style | `style(mobile): fix code formatting` |
| `refactor` | ♻️ | Refactorisation | `refactor(api): optimize database queries` |
| `perf` | ⚡️ | Performance | `perf(web): lazy load components` |
| `test` | ✅ | Tests | `test(api): add user service unit tests` |
| `build` | 🛠️ | Build système | `build: update webpack config` |
| `ci` | 👷 | CI/CD | `ci: add automated testing workflow` |
| `chore` | 🔧 | Maintenance | `chore: update dependencies` |
| `revert` | ⏪ | Annulation | `revert: remove experimental feature` |
| `security` | 🔒 | Sécurité | `security(api): fix SQL injection vulnerability` |
| `deps` | ⬆️ | Dépendances | `deps(web): update React to v18.2.0` |

## 🎯 Scopes Disponibles

| Scope | Description | Utilisation |
|-------|-------------|-------------|
| `api` | Backend Laravel | Controllers, Models, Services, Routes |
| `web` | Frontend React | Components, Pages, Hooks, Store |
| `mobile` | App Flutter | Screens, Widgets, Providers, Services |
| `shared` | Code partagé | Types, Utils, Configurations |
| `docs` | Documentation | README, guides, API docs |
| `ci` | CI/CD | GitHub Actions, Docker, Scripts |
| `infra` | Infrastructure | Kubernetes, Terraform, Configs |
| `config` | Configuration | Env files, app configs |
| `deps` | Dépendances | Package updates, installations |
| `release` | Release/Version | Version bumps, changelogs |

## ✅ Exemples Corrects

### Fonctionnalités
```bash
feat(api): add user profile endpoints
feat(web): implement dashboard analytics
feat(mobile): add push notification system
feat(shared): create API response types
```

### Corrections
```bash
fix(api): resolve database connection timeout
fix(web): fix responsive design on mobile
fix(mobile): handle network connectivity issues
fix(shared): correct type definitions
```

### Documentation
```bash
docs: update installation guide
docs(api): add endpoint documentation
docs(mobile): update architecture guide
```

### Refactorisation
```bash
refactor(api): extract user service logic
refactor(web): optimize component structure
refactor(mobile): improve state management
```

### Tests
```bash
test(api): add integration tests for auth
test(web): add unit tests for components
test(mobile): add widget tests for forms
```

## ❌ Exemples Incorrects

```bash
# ❌ Pas de type
add user authentication

# ❌ Type incorrect
enhancement(api): add new feature

# ❌ Scope incorrect
feat(backend): add user auth

# ❌ Description trop courte
feat(api): add

# ❌ Description avec majuscule
feat(api): Add user authentication

# ❌ Description avec point final
feat(api): add user authentication.

# ❌ Trop long (> 100 caractères)
feat(api): add a very long user authentication system with multiple providers and social login integration
```

## 🔧 Configuration Automatique

### Installation
```bash
# À la racine du monorepo
npm install

# Initialiser husky
npm run prepare

# Commit avec aide interactive
npm run commit
```

### Hooks Git Automatiques

#### Pre-commit
- Lint et format automatique
- Tests unitaires rapides
- Vérification des fichiers

#### Commit-msg
- Validation du format conventional
- Vérification des types et scopes
- Limitation de la longueur

## 🚀 Workflow Recommandé

### 1. Développement
```bash
# Travail normal sur le code
git add .

# Commit interactif (recommandé pour débuter)
npm run commit

# Ou commit manuel (pour les experts)
git commit -m "feat(api): add user authentication endpoints"
```

### 2. Messages de Commit Détaillés
```bash
git commit -m "feat(api): add user authentication endpoints

- Add JWT token generation
- Implement refresh token rotation  
- Add password strength validation
- Include rate limiting for login attempts

Closes #123
Breaking Change: Authentication now requires email verification"
```

### 3. Release Automatique
```bash
# Génère automatiquement le CHANGELOG et bump la version
npm run release
```

## 📊 Génération Automatique

### CHANGELOG.md
Le fichier de changelog est généré automatiquement à partir des commits :

```markdown
# Changelog

## [1.1.0] - 2024-01-15

### ✨ Features
- **api**: add user authentication endpoints (#123)
- **web**: implement dashboard analytics (#124)  
- **mobile**: add push notification system (#125)

### 🐛 Bug Fixes
- **api**: resolve database connection timeout (#126)
- **web**: fix responsive design on mobile (#127)

### 📚 Documentation
- update API documentation (#128)
```

### Semantic Versioning
Les versions sont automatiquement calculées :

- `feat`: MINOR version (1.0.0 → 1.1.0)
- `fix`: PATCH version (1.0.0 → 1.0.1)  
- `BREAKING CHANGE`: MAJOR version (1.0.0 → 2.0.0)

## 🎯 Bonnes Pratiques

### ✅ À Faire
- Utiliser l'impératif présent ("add" pas "added")
- Être concis mais descriptif
- Mentionner le scope quand c'est pertinent  
- Utiliser les hooks automatiques
- Référencer les issues (#123)

### ❌ À Éviter
- Messages vagues ("fix stuff", "update")
- Mélanger plusieurs types de changements
- Oublier le scope sur les monorepos
- Messages trop longs ou trop courts
- Ignorer les règles de format