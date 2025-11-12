# 🚀 Guida Rapida - Avvio Progetto Lymbo

## 📱 Avvio Rapido

### Metodo 1: Script Automatico (Consigliato)
```bash
./avvia_xcode.sh
```

### Metodo 2: Comando Manuale
```bash
open Lymbo.xcodeproj
```

### Metodo 3: Da Terminale (Build e Run)
```bash
# Compila il progetto
xcodebuild -project Lymbo.xcodeproj -scheme Lymbo -destination 'platform=iOS Simulator,name=iPhone 16' build

# Oppure compila e avvia direttamente
xcodebuild -project Lymbo.xcodeproj -scheme Lymbo -destination 'platform=iOS Simulator,name=iPhone 16' build run
```

## ⚙️ Configurazione Progetto

- **Bundle ID**: `com.lymbo.app`
- **Target iOS**: 18.0+
- **Simulatore Consigliato**: iPhone 16
- **Swift Version**: 5.9+

## 🔐 Abilitare Phone Authentication

Phone Authentication richiede configurazione manuale perché necessita di reCAPTCHA:

```bash
./abilita_phone_auth.sh
```

Oppure vai manualmente su:
https://console.firebase.google.com/project/lymbo-ios-app/authentication/providers

1. Clicca su "Phone"
2. Abilita il provider
3. Configura reCAPTCHA per iOS
4. Salva

## 📦 Dipendenze

Il progetto usa Swift Package Manager. Le dipendenze sono già configurate:
- Firebase SDK (Auth, Firestore, Storage, Messaging)
- Google Sign-In

## 🎯 Primo Avvio

1. Apri il progetto: `./avvia_xcode.sh`
2. Seleziona il simulatore iPhone 16
3. Premi `⌘ + R` per compilare ed eseguire
4. L'app mostrerà lo Splash Screen con onboarding

## ✅ Verifica Setup

```bash
# Verifica che il progetto compili
xcodebuild -project Lymbo.xcodeproj -scheme Lymbo -destination 'platform=iOS Simulator,name=iPhone 16' build

# Se vedi "BUILD SUCCEEDED", tutto è pronto!
```

## 🐛 Troubleshooting

### Errore: "No such module"
```bash
# Pulisci la cache SPM
rm -rf ~/Library/Developer/Xcode/DerivedData/Lymbo-*
xcodebuild -project Lymbo.xcodeproj -scheme Lymbo clean
```

### Errore: "GoogleService-Info.plist not found"
Verifica che il file esista in `Resources/GoogleService-Info.plist`

### Errore: Build Failed
```bash
# Pulisci e ricompila
xcodebuild clean -project Lymbo.xcodeproj -scheme Lymbo
xcodebuild -project Lymbo.xcodeproj -scheme Lymbo -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## 📝 Note Importanti

- Il progetto è configurato per iOS 18.0+ con retrocompatibilità
- Tutti i file sono già aggiunti al progetto Xcode
- Firebase è già configurato e pronto
- L'onboarding completo è implementato e funzionante

