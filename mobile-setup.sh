#!/bin/bash

echo "🚀 Configuration de l'application mobile VBG Platform"
echo "=================================================="

# Vérifier si Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé. Veuillez l'installer depuis https://flutter.dev"
    exit 1
fi

echo "✅ Flutter est installé"

# Se déplacer vers le dossier mobile-app
cd mobile-app

echo "📦 Installation des dépendances..."
flutter pub get

echo "🏗️ Génération du code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "🧪 Exécution des tests..."
flutter test

echo "🔍 Analyse du code..."
flutter analyze

echo "✅ Configuration terminée avec succès!"
echo ""
echo "Pour lancer l'application :"
echo "  cd mobile-app"
echo "  flutter run"
echo ""
echo "Structure implémentée :"
echo "✅ Clean Architecture (data, domain, presentation)"
echo "✅ Organisation par fonctionnalités (auth, reports)" 
echo "✅ Gestion d'état avec Riverpod"
echo "✅ Tests unitaires et widgets"
echo "✅ Configuration Android et iOS"