#!/bin/bash

# Script per convertire il logo nelle dimensioni necessarie per iOS 26
# Utilizzo: ./convert_logo.sh "lymbo logo 1.icon"

INPUT_FILE="${1:-lymbo logo 1.icon}"
OUTPUT_DIR="Assets.xcassets/AppIcon.appiconset"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Errore: File '$INPUT_FILE' non trovato!"
    echo "Utilizzo: $0 <file_logo>"
    exit 1
fi

# Verifica che sips sia disponibile (macOS)
if ! command -v sips &> /dev/null; then
    echo "Errore: sips non trovato. Questo script richiede macOS."
    exit 1
fi

echo "Convertendo $INPUT_FILE nelle dimensioni necessarie per iOS 26..."

# Crea la directory di output se non esiste
mkdir -p "$OUTPUT_DIR"

# Dimensioni per iPhone
sips -z 40 40 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-20x20@2x.png" 2>/dev/null
sips -z 60 60 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-20x20@3x.png" 2>/dev/null
sips -z 58 58 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-29x29@2x.png" 2>/dev/null
sips -z 87 87 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-29x29@3x.png" 2>/dev/null
sips -z 80 80 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-40x40@2x.png" 2>/dev/null
sips -z 120 120 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-40x40@3x.png" 2>/dev/null
sips -z 120 120 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-60x60@2x.png" 2>/dev/null
sips -z 180 180 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-60x60@3x.png" 2>/dev/null

# Dimensioni per iPad
# Nota: alcune dimensioni @2x sono condivise con iPhone, quindi non vengono ricreate
sips -z 20 20 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-20x20@1x.png" 2>/dev/null
sips -z 29 29 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-29x29@1x.png" 2>/dev/null
sips -z 40 40 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-40x40@1x.png" 2>/dev/null
sips -z 76 76 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-76x76@1x.png" 2>/dev/null
sips -z 152 152 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-76x76@2x.png" 2>/dev/null
sips -z 167 167 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-83.5x83.5@2x.png" 2>/dev/null

# Dimensione marketing (1024x1024)
sips -z 1024 1024 "$INPUT_FILE" --out "$OUTPUT_DIR/AppIcon-1024x1024@1x.png" 2>/dev/null

echo "Rimuovendo il canale alpha dalle icone (richiesto da Apple)..."
# Rimuove il canale alpha convertendo in JPEG e poi riconvertendo in PNG
for file in "$OUTPUT_DIR"/*.png; do
    temp_file="${file}.temp"
    sips -s format jpeg -s formatOptions high "$file" --out "$temp_file" > /dev/null 2>&1
    if [ -f "$temp_file" ]; then
        sips -s format png "$temp_file" --out "$file" > /dev/null 2>&1
        rm -f "$temp_file"
    fi
done

echo "Conversione completata! Le icone sono state salvate in $OUTPUT_DIR"
echo ""
echo "Nota: Alcune dimensioni potrebbero essere condivise tra iPhone e iPad."
echo "Tutte le icone sono state convertite in formato RGB senza canale alpha (come richiesto da Apple)."

