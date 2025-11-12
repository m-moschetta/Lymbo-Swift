# Setup Firebase per Lymbo

## Prerequisiti

1. Node.js installato (per Firebase CLI)
2. Account Google per accedere a Firebase Console

## Passi per il Setup

### 1. Installa Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Login a Firebase

```bash
firebase login
```

Questo aprirà il browser per autenticarti con il tuo account Google.

### 3. Crea il Progetto Firebase

```bash
cd "/Users/mariomoschetta/Lymbo Swift"
firebase projects:create --display-name "Lymbo App" lymbo-app
```

**Nota**: Se il progetto esiste già, usa:
```bash
firebase use --add
```

### 4. Crea l'App iOS

```bash
firebase apps:create ios --bundle-id com.lymbo.app --project lymbo-app
```

### 5. Scarica GoogleService-Info.plist

```bash
firebase apps:sdkconfig ios --project lymbo-app -o Resources/GoogleService-Info.plist
```

**IMPORTANTE**: Dopo aver scaricato il file, aggiungilo al progetto Xcode:
1. Apri Xcode
2. Trascina `GoogleService-Info.plist` nella cartella `Resources` del progetto
3. Assicurati che sia aggiunto al target "Lymbo"

### 6. Inizializza Firestore e Storage

```bash
firebase init firestore storage
```

Quando richiesto:
- Usa le regole esistenti (`Firebase/firestore.rules` e `Firebase/storage.rules`)
- Non sovrascrivere i file esistenti

### 7. Deploy delle Regole

```bash
firebase deploy --only firestore:rules,storage:rules
```

## Configurazione in Xcode

### 1. Aggiungi le Dipendenze Firebase

1. Apri `Lymbo.xcodeproj` in Xcode
2. Vai su **File → Add Packages...**
3. Aggiungi: `https://github.com/firebase/firebase-ios-sdk`
4. Seleziona le seguenti librerie:
   - FirebaseAuth
   - FirebaseCore
   - FirebaseFirestore
   - FirebaseStorage
   - FirebaseMessaging

### 2. Aggiungi Google Sign-In

1. Vai su **File → Add Packages...**
2. Aggiungi: `https://github.com/google/GoogleSignIn-iOS`
3. Seleziona la versione più recente

### 3. Configura Google Sign-In

1. Vai su [Firebase Console](https://console.firebase.google.com)
2. Seleziona il progetto "Lymbo App"
3. Vai su **Authentication → Sign-in method**
4. Abilita **Google** come provider
5. Copia il **Web client ID** dalla configurazione OAuth
6. Aggiungi l'URL di callback: `com.lymbo.app:/google-signin`

### 4. Configura Info.plist

Aggiungi al file `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.lymbo.app</string>
        </array>
    </dict>
</array>
```

## Verifica Setup

Dopo aver completato tutti i passi:

1. Compila il progetto: `⌘ + B`
2. Verifica che non ci siano errori di compilazione
3. Esegui l'app sul simulatore iPhone 16

## Troubleshooting

### Errore: "GoogleService-Info.plist not found"
- Assicurati che il file sia nella cartella `Resources`
- Verifica che sia aggiunto al target nell'Xcode

### Errore: "Firebase not configured"
- Verifica che `GoogleService-Info.plist` sia presente
- Controlla che FirebaseApp.configure() sia chiamato in AppDelegate

### Errore: Google Sign-In non funziona
- Verifica che Google Sign-In sia abilitato in Firebase Console
- Controlla che il bundle ID corrisponda (`com.lymbo.app`)
- Verifica che l'URL scheme sia configurato correttamente in Info.plist

