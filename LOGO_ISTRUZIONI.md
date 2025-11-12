# Istruzioni per Aggiungere il Logo dell'App

## Struttura Creata

Ho creato la struttura completa per l'icona dell'app secondo le best practice di iOS 26:

- ✅ `Assets.xcassets/AppIcon.appiconset/` - Directory per le icone
- ✅ `Contents.json` - Configurazione con tutte le dimensioni necessarie
- ✅ Progetto Xcode aggiornato per includere l'Asset Catalog
- ✅ Script `convert_logo.sh` per convertire automaticamente il logo

## Come Aggiungere il Tuo Logo

### Opzione 1: Usa lo Script Automatico (Consigliato)

1. **Posiziona il file del logo** nella root del progetto con il nome `lymbo logo 1.icon` (o qualsiasi altro formato supportato: PNG, JPG, ICNS)

2. **Esegui lo script di conversione**:
   ```bash
   ./convert_logo.sh "lymbo logo 1.icon"
   ```

   Oppure se il file ha un nome diverso:
   ```bash
   ./convert_logo.sh "percorso/al/tuo/logo.png"
   ```

3. Lo script creerà automaticamente tutte le dimensioni necessarie:
   - iPhone: 20x20, 29x29, 40x40, 60x60 (tutte le scale @2x e @3x)
   - iPad: 20x20, 29x29, 40x40, 76x76, 83.5x83.5 (scale @1x e @2x)
   - Marketing: 1024x1024

### Opzione 2: Conversione Manuale

Se preferisci convertire manualmente, usa `sips` (disponibile su macOS):

```bash
# Esempio: converti il logo in 1024x1024
sips -z 1024 1024 "lymbo logo 1.icon" --out Assets.xcassets/AppIcon.appiconset/AppIcon-1024x1024@1x.png

# E così via per tutte le altre dimensioni...
```

### Opzione 3: Usa Xcode

1. Apri il progetto in Xcode
2. Seleziona `Assets.xcassets` nel navigator
3. Seleziona `AppIcon`
4. Trascina il tuo logo nelle slot appropriati

## Dimensioni Richieste

Per iOS 26 (con retrocompatibilità iOS 18+), sono necessarie queste dimensioni:

### iPhone
- 20x20 @2x (40x40 px)
- 20x20 @3x (60x60 px)
- 29x29 @2x (58x58 px)
- 29x29 @3x (87x87 px)
- 40x40 @2x (80x80 px)
- 40x40 @3x (120x120 px)
- 60x60 @2x (120x120 px)
- 60x60 @3x (180x180 px)

### iPad
- 20x20 @1x (20x20 px)
- 20x20 @2x (40x40 px) - condivisa con iPhone
- 29x29 @1x (29x29 px)
- 29x29 @2x (58x58 px) - condivisa con iPhone
- 40x40 @1x (40x40 px)
- 40x40 @2x (80x80 px) - condivisa con iPhone
- 76x76 @1x (76x76 px)
- 76x76 @2x (152x152 px)
- 83.5x83.5 @2x (167x167 px)

### Marketing (App Store)
- 1024x1024 @1x (1024x1024 px)

## Best Practice iOS 26

1. **Formato**: PNG senza trasparenza (opaco)
2. **Design**: 
   - Forme semplici e chiare
   - Evita dettagli eccessivi
   - Assicurati che sia riconoscibile anche in dimensioni piccole
3. **Liquid Glass**: iOS 26 supporta le icone "Liquid Glass" con effetto traslucido
   - Il sistema applica automaticamente gli effetti
   - Non includere ombre o angoli arrotondati nel design originale
4. **Colori**: Assicurati che l'icona sia visibile sia su sfondi chiari che scuri

## Verifica

Dopo aver aggiunto le icone:

1. Compila il progetto:
   ```bash
   xcodebuild -project Lymbo.xcodeproj -scheme Lymbo -destination 'platform=iOS Simulator,name=iPhone 16' build
   ```

2. Verifica che l'icona appaia correttamente nel simulatore

## Note

- Il file `Contents.json` è già configurato correttamente
- Alcune dimensioni sono condivise tra iPhone e iPad (come indicato nel JSON)
- Se alcune immagini mancano, Xcode mostrerà degli avvisi ma l'app funzionerà comunque

