#!/bin/bash

# Script per creare il progetto Xcode per Lymbo

PROJECT_NAME="Lymbo"
PROJECT_DIR="."

# Crea la struttura del progetto
mkdir -p "${PROJECT_NAME}.xcodeproj"
mkdir -p "${PROJECT_NAME}.xcodeproj/project.xcworkspace"
mkdir -p "${PROJECT_NAME}.xcodeproj/xcshareddata"
mkdir -p "${PROJECT_NAME}.xcodeproj/xcuserdata"

echo "Progetto Xcode creato. Apri Xcode e crea un nuovo progetto iOS App con SwiftUI."
echo "Poi aggiungi tutti i file Swift nella cartella Views e Theme."

