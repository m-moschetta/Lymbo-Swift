#!/bin/bash

# Script per abilitare Firestore e Storage da terminale
# Questo script apre i link necessari nella console Firebase

PROJECT_ID="lymbo-ios-app"

echo "🚀 Abilitazione servizi Firebase per il progetto: $PROJECT_ID"
echo ""

# Apri i link nella console Firebase
echo "📋 Aprendo i link necessari nella console Firebase..."
echo ""

# Firestore
echo "1️⃣  Firestore:"
echo "   👉 https://console.firebase.google.com/project/$PROJECT_ID/firestore"
echo "   Clicca 'Crea database' e scegli modalità 'Test'"
echo ""

# Storage  
echo "2️⃣  Storage:"
echo "   👉 https://console.firebase.google.com/project/$PROJECT_ID/storage"
echo "   Clicca 'Get Started'"
echo ""

# Authentication
echo "3️⃣  Authentication (Google Sign-In):"
echo "   👉 https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
echo "   Abilita 'Google' come provider"
echo ""

# Apri i link automaticamente se possibile
if command -v open &> /dev/null; then
    echo "🌐 Apertura automatica dei link..."
    open "https://console.firebase.google.com/project/$PROJECT_ID/firestore"
    sleep 2
    open "https://console.firebase.google.com/project/$PROJECT_ID/storage"
    sleep 2
    open "https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
fi

echo ""
echo "⏳ Attendi qualche secondo dopo aver abilitato i servizi..."
echo "Poi premi INVIO per continuare con il deploy delle regole..."
read

# Prova a deployare le regole
echo ""
echo "📤 Deploy delle regole Firestore e Storage..."
cd "$(dirname "$0")/Firebase"
firebase deploy --only firestore:rules,storage:rules --project $PROJECT_ID

echo ""
echo "✅ Setup completato!"

