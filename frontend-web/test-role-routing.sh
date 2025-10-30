#!/bin/bash

echo "🚀 Test du système de redirection par rôle - Assistance Msaada 2"
echo "=================================================================="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le dossier frontend-web"
    exit 1
fi

echo "📋 Vérification des composants critiques..."

# Check critical files
CRITICAL_FILES=(
    "src/App.tsx"
    "src/pages/Dashboard/RoleDashboard.tsx"
    "src/pages/Dashboard/APSDashboard.tsx"
    "src/pages/Dashboard/OperatorDashboard.tsx"
    "src/pages/Dashboard/OrganizationDashboard.tsx"
    "src/pages/Dashboard/AdminDashboard.tsx"
    "src/pages/Dashboard/SupervisorDashboard.tsx"
    "src/pages/TestUsers/TestUsersPage.tsx"
    "src/utils/testUsers.ts"
    "src/utils/roleRouting.ts"
    "src/types/dashboard.ts"
    "src/store/authStore.ts"
)

missing_files=()
for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - MANQUANT"
        missing_files+=("$file")
    fi
done

echo ""

if [ ${#missing_files[@]} -eq 0 ]; then
    echo "🎉 Tous les fichiers critiques sont présents!"
    echo ""
    echo "📋 Instructions de test:"
    echo "1. Démarrer le serveur de développement: npm run dev"
    echo "2. Ouvrir: http://localhost:5173/test-users"
    echo "3. Tester la connexion avec chaque utilisateur de test:"
    echo ""
    echo "   👤 APS: aps@msaada.com / password123"
    echo "   👤 Opérateur: operator@msaada.com / password123"
    echo "   👤 Organisation: org@msaada.com / password123"
    echo "   👤 Admin: admin@msaada.com / password123"
    echo "   👤 Superviseur: supervisor@msaada.com / password123"
    echo ""
    echo "4. Vérifier que chaque rôle redirige vers son dashboard spécifique"
    echo ""
    echo "🔧 Pour lancer le test maintenant:"
    echo "   npm run dev"
else
    echo "❌ Certains fichiers critiques sont manquants:"
    for file in "${missing_files[@]}"; do
        echo "   - $file"
    done
    echo ""
    echo "Veuillez créer ces fichiers avant de continuer."
fi

echo ""
echo "=================================================================="