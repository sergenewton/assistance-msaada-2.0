# VBG Platform Frontend Web

## Description
Interface web React/TypeScript pour la plateforme de signalement VBG

## Structure des Dossiers

```
frontend-web/
├── src/
│   ├── components/
│   │   ├── UI/                # Composants UI réutilisables
│   │   ├── Layout/           # Composants de mise en page
│   │   ├── Forms/            # Composants de formulaires
│   │   └── Reports/          # Composants spécifiques aux signalements
│   ├── pages/
│   │   ├── Auth/             # Pages d'authentification
│   │   ├── Dashboard/        # Pages du tableau de bord
│   │   └── Reports/          # Pages de gestion des signalements
│   ├── services/
│   │   └── api/              # Services API et clients HTTP
│   ├── hooks/                # Hooks React personnalisés
│   ├── store/
│   │   └── slices/           # Redux slices
│   ├── utils/                # Utilitaires et helpers
│   ├── types/                # Types TypeScript
│   ├── assets/
│   │   ├── images/           # Images et icônes
│   │   └── styles/           # Styles globaux
│   ├── locales/              # Fichiers de traduction i18n
│   └── tests/                # Tests unitaires et d'intégration
├── public/                   # Fichiers statiques
└── dist/                     # Build de production
```

## Conventions de Nommage

### Composants
- PascalCase : `ReportCard`, `LoginForm`, `UserProfile`
- Un composant par fichier avec extension `.tsx`

### Pages
- PascalCase : `LoginPage`, `DashboardPage`, `ReportsListPage`
- Dossier par section avec `index.tsx`

### Hooks
- camelCase avec préfixe "use" : `useAuth`, `useReports`, `useLocalStorage`

### Services
- camelCase avec suffixe "Service" : `authService`, `reportsService`

### Types
- PascalCase : `User`, `Report`, `ApiResponse`
- Interfaces avec préfixe "I" : `IUser`, `IReport`

### Variables et fonctions
- camelCase : `currentUser`, `handleSubmit`, `isLoading`

### Constantes
- UPPER_SNAKE_CASE : `API_BASE_URL`, `STORAGE_KEYS`

### Fichiers CSS
- kebab-case : `button-component.css`, `form-styles.css`

### Routes
- kebab-case : `/login`, `/dashboard`, `/reports/new`

## Installation

```bash
npm install
npm run dev
```

## Build

```bash
npm run build
npm run preview
```

## Tests

```bash
npm run test
npm run test:coverage
```

## Linting

```bash
npm run lint
npm run lint:fix
```