#!/bin/bash

# Script pour afficher les informations du compte Super Admin
# Assistance Msaada 2.0

BACKEND_DIR="$(dirname "$0")/backend-api"

echo "🔍 Informations du compte Super Admin - ASSISTANCE MSAADA 2.0"
echo "=============================================================="

cd "$BACKEND_DIR"

# Vérifier la connexion à la base de données
if ! mysql -u vbg -pvbgpass -D vbg_platform -e "SELECT 1;" >/dev/null 2>&1; then
    echo "❌ Impossible de se connecter à la base de données MySQL"
    echo "📝 Assurez-vous que MySQL est démarré et configuré correctement"
    exit 1
fi

# Récupérer les informations du super admin
admin_info=$(mysql -u vbg -pvbgpass -D vbg_platform -N -e "
    SELECT u.id, r.display_name, u.is_active, u.created_at, u.last_login_at 
    FROM users u 
    JOIN roles r ON u.role_id = r.id 
    WHERE r.name = 'admin' 
    ORDER BY u.created_at DESC 
    LIMIT 1;
" 2>/dev/null)

if [ -z "$admin_info" ]; then
    echo "❌ Aucun compte super admin trouvé"
    echo "💡 Exécutez le seeder pour créer le compte :"
    echo "   cd backend-api && php artisan db:seed --class=InitialSetupSeeder"
    exit 1
fi

echo "✅ Compte Super Admin trouvé !"
echo ""
echo "📧 Email de connexion : admin@msaada.cd"
echo "🔑 Mot de passe       : Admin@2025!"
echo ""
echo "📊 Détails du compte :"
echo "$admin_info" | while IFS=$'\t' read -r id role_name is_active created_at last_login; do
    echo "   🆔 ID: $id"
    echo "   👤 Rôle: $role_name" 
    echo "   ✅ Actif: $([ "$is_active" = "1" ] && echo "Oui" || echo "Non")"
    echo "   📅 Créé le: $created_at"
    echo "   🔐 Dernière connexion: $([ "$last_login" = "NULL" ] && echo "Jamais" || echo "$last_login")"
done

echo ""
echo "⚠️  IMPORTANT: Changez ce mot de passe dès la première connexion !"
echo "🌐 Accès administration: http://localhost:3000/admin"