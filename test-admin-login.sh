#!/bin/bash

# Script de test de connexion Super Admin
# Assistance Msaada 2.0

echo "🔐 Test de Connexion Super Admin - ASSISTANCE MSAADA 2.0"
echo "========================================================"
echo ""

# Test de l'endpoint de login
echo "🧪 Test de l'API de connexion..."
echo "Endpoint: POST http://localhost:8000/api/v1/auth/login"
echo "Données: {\"identifier\": \"admin@msaada.cd\", \"password\": \"Admin@2025!\"}"
echo ""

response=$(curl -s -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier": "admin@msaada.cd", "password": "Admin@2025!"}')

# Vérifier si la connexion a réussi
if echo "$response" | jq -e '.success == true' >/dev/null 2>&1; then
    echo "✅ Connexion réussie !"
    echo ""
    echo "📊 Détails de la réponse :"
    echo "$response" | jq .
    echo ""
    
    # Extraire le token pour des tests supplémentaires
    token=$(echo "$response" | jq -r '.data.token.access_token')
    user_id=$(echo "$response" | jq -r '.data.user.id')
    
    echo "🔑 Token d'accès : ${token:0:50}..."
    echo "👤 ID Utilisateur : $user_id"
    echo ""
    
    # Test de l'endpoint /me avec le token
    echo "🧪 Test de l'endpoint /me avec le token..."
    me_response=$(curl -s http://localhost:8000/api/v1/auth/me \
      -H "Authorization: Bearer $token")
    
    if echo "$me_response" | jq -e '.success == true' >/dev/null 2>&1; then
        echo "✅ Endpoint /me fonctionne !"
        echo "👤 Utilisateur authentifié :"
        echo "$me_response" | jq '.data.user'
    else
        echo "❌ Endpoint /me ne fonctionne pas"
        echo "$me_response"
    fi
    
else
    echo "❌ Connexion échouée !"
    echo "📄 Réponse du serveur :"
    echo "$response" | jq . 2>/dev/null || echo "$response"
fi

echo ""
echo "🌐 Interface web disponible : http://localhost:3000"
echo "🔧 API Backend disponible : http://localhost:8000"