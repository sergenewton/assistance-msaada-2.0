# VBG Platform Mobile App

## Description
Application mobile Flutter pour la plateforme de signalement VBG utilisant Clean Architecture

## Structure des Dossiers

```
mobile-app/
├── lib/
│   ├── core/
│   │   ├── constants/         # Constantes globales
│   │   ├── errors/           # Gestion d'erreurs
│   │   ├── network/          # Configuration réseau
│   │   ├── utils/            # Utilitaires
│   │   └── themes/           # Thèmes et styles
│   ├── features/
│   │   ├── auth/             # Fonctionnalité d'authentification
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # Sources de données (API, local)
│   │   │   │   ├── models/       # Modèles de données
│   │   │   │   └── repositories/ # Implémentations repositories
│   │   │   ├── domain/
│   │   │   │   ├── entities/     # Entités métier
│   │   │   │   ├── repositories/ # Interfaces repositories
│   │   │   │   └── usecases/     # Cas d'utilisation
│   │   │   └── presentation/
│   │   │       ├── bloc/         # BLoC pour gestion d'état
│   │   │       ├── pages/        # Pages/Screens
│   │   │       └── widgets/      # Widgets spécifiques
│   │   └── reports/          # Fonctionnalité de signalements
│   │       └── [même structure que auth]
│   └── shared/
│       └── widgets/          # Widgets partagés
├── assets/
│   ├── images/              # Images et icônes
│   ├── fonts/               # Polices personnalisées
│   └── translations/        # Fichiers de traduction
├── test/
│   └── features/            # Tests unitaires par fonctionnalité
└── android/                 # Configuration Android
└── ios/                     # Configuration iOS
```

## Architecture

Ce projet suit les principes de **Clean Architecture** avec :

- **Domain Layer** : Entités, cas d'utilisation et interfaces
- **Data Layer** : Implémentations, modèles et sources de données
- **Presentation Layer** : UI, BLoC et gestion d'état

## Conventions de Nommage

### Fichiers et Dossiers
- snake_case : `user_profile_page.dart`, `auth_repository.dart`

### Classes
- PascalCase : `UserProfilePage`, `AuthRepository`, `LoginBloc`

### Variables et fonctions
- camelCase : `currentUser`, `handleLogin`, `isLoading`

### Constantes
- lowerCamelCase avec const : `const apiBaseUrl = '...'`

### BLoC
- Événements : `AuthEvent`, `LoginRequested`
- États : `AuthState`, `AuthLoading`, `AuthSuccess`
- BLoC : `AuthBloc`, `ReportsBloc`

### Pages/Screens
- Suffixe "Page" : `LoginPage`, `DashboardPage`, `ReportDetailPage`

### Widgets
- Descriptifs : `CustomButton`, `ReportCard`, `LoadingIndicator`

### Modèles
- Suffixe "Model" : `UserModel`, `ReportModel`

### Entités
- Noms métier : `User`, `Report`, `VbgCase`

### Use Cases
- Verbe d'action : `LoginUser`, `CreateReport`, `GetUserProfile`

### Repositories
- Suffixe "Repository" : `AuthRepository`, `ReportsRepository`

### Data Sources
- Suffixe avec type : `AuthRemoteDataSource`, `AuthLocalDataSource`

## Installation

```bash
flutter pub get
flutter pub run build_runner build
flutter run
```

## Tests

```bash
flutter test
flutter test --coverage
```

## Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```