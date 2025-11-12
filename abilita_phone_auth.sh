#!/bin/bash

# Script per tentare di abilitare Phone Authentication
# Nota: Phone Auth richiede configurazione manuale per reCAPTCHA

PROJECT_ID="lymbo-ios-app"
ACCESS_TOKEN=$(gcloud auth print-access-token 2>/dev/null || echo "")

if [ -z "$ACCESS_TOKEN" ]; then
    echo "⚠️  Token di autenticazione non disponibile"
    echo "📝 Phone Authentication richiede configurazione manuale"
    echo ""
    echo "🔗 Apri questo link per abilitare Phone Auth:"
    echo "   https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
    echo ""
    echo "📋 Passi da seguire:"
    echo "   1. Clicca su 'Phone'"
    echo "   2. Abilita il provider"
    echo "   3. Configura reCAPTCHA (richiesto per iOS)"
    echo "   4. Salva"
    echo ""
    open "https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
    exit 0
fi

echo "🔐 Tentativo di abilitare Phone Authentication..."

# Prova ad abilitare via API (potrebbe non funzionare completamente)
RESPONSE=$(curl -s -X POST \
  "https://identitytoolkit.googleapis.com/admin/v2/projects/$PROJECT_ID/config" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "signIn": {
      "phoneNumber": {
        "enabled": true
      }
    }
  }' 2>&1)

if echo "$RESPONSE" | grep -q "error"; then
    echo "⚠️  Impossibile abilitare automaticamente Phone Auth"
    echo "📝 È necessario abilitarlo manualmente dalla console"
    echo ""
    echo "🔗 Link diretto:"
    echo "   https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
    echo ""
    open "https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
else
    echo "✅ Phone Authentication abilitato!"
fi

