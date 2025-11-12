#!/bin/bash

# Script per avviare il progetto Lymbo in Xcode

echo "🚀 Avvio progetto Lymbo..."

# Verifica che Xcode sia installato
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode non trovato. Installa Xcode dal Mac App Store."
    exit 1
fi

# Naviga alla directory del progetto
cd "$(dirname "$0")"

# Verifica che il progetto esista
if [ ! -f "Lymbo.xcodeproj/project.pbxproj" ]; then
    echo "❌ Progetto Xcode non trovato!"
    exit 1
fi

echo "✅ Progetto trovato"
echo "📦 Bundle ID: com.lymbo.app"
echo "📱 Target: iOS 18.0+"
echo ""

# Apri il progetto in Xcode
echo "🔓 Apertura progetto in Xcode..."
open Lymbo.xcodeproj

echo ""
echo "✅ Progetto aperto in Xcode!"
echo ""
echo "📝 Prossimi passi:"
echo "   1. Seleziona il simulatore iPhone 16"
echo "   2. Premi ⌘ + R per compilare ed eseguire"
echo "   3. Oppure usa: xcodebuild -scheme Lymbo -destination 'platform=iOS Simulator,name=iPhone 16' build"
echo ""

