# 🔧 Guida: Abilitare Firebase Storage

## Passo 1: Apri la Console Firebase

1. Vai su: https://console.firebase.google.com/project/lymbo-ios-app/storage
2. Oppure:
   - Vai su https://console.firebase.google.com
   - Seleziona il progetto "Lymbo iOS App" (lymbo-ios-app)
   - Nel menu a sinistra, clicca su "Storage"

## Passo 2: Abilita Storage

1. Nella pagina Storage, vedrai un pulsante **"Get Started"** o **"Inizia"**
2. Clicca su **"Get Started"**
3. Ti apparirà una schermata con i termini di servizio

## Passo 3: Accetta i Termini

1. Leggi i termini di servizio di Firebase Storage
2. Seleziona la checkbox per accettare i termini
3. Clicca su **"Crea"** o **"Create"**

## Passo 4: Scegli la Location (se richiesto)

1. Firebase potrebbe chiederti di scegliere una location per il bucket Storage
2. Scegli una location vicina (es. `europe-west1` per l'Europa)
3. Clicca **"Fine"** o **"Done"**

## Passo 5: Verifica l'Abilitazione

Dopo aver completato i passi sopra, Storage sarà abilitato. Vedrai:
- Una dashboard Storage con statistiche
- Un bucket Storage creato automaticamente
- Le regole di sicurezza (che abbiamo già configurato)

## Passo 6: Deploy delle Regole Storage

Dopo aver abilitato Storage, torna al terminale e dimmi "fatto" - procederò io con il deploy automatico delle regole!

---

## ⚠️ Note Importanti

- **Non è necessario** abilitare Storage per testare l'autenticazione o Firestore
- Storage serve solo se vuoi permettere agli utenti di caricare immagini (foto profilo, portfolio, ecc.)
- Se non abiliti Storage ora, puoi farlo in qualsiasi momento in futuro

## ✅ Cosa Succede Dopo

Una volta abilitato Storage, potrai:
- Caricare immagini profilo utente
- Caricare immagini portfolio
- Gestire file multimediali nell'app

Tutte le funzionalità sono già implementate nel codice - basta abilitare Storage e deployare le regole!

