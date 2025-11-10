# Lymbo - App iOS

App di matching per creativi basata sul design Figma.

## Struttura del Progetto

### Views
- **MainTabView**: Tab bar principale con Connect, Links, Events, Profile
- **Connect**: Schermata principale per lo swipe/match
  - `ConnectView.swift`: Vista principale con card swipeabili
  - `SwipeableCardView.swift`: Card con gesti swipe
  - `WorksCarouselView.swift`: Carosello delle opere
  - `CreativeDetailsView.swift`: Dettagli del creativo
  - `PreferencesView.swift`: Menu preferenze
- **Links**: Gestione connessioni
  - `LinksView.swift`: Vista principale con tab Archive/Chats
  - `ReceivedLikesView.swift`: Like ricevuti
  - `ArchiveView.swift`: Archivio profili
  - `ChatsView.swift`: Chat con i match
- **Events**: Eventi per creativi
  - `EventsView.swift`: Lista eventi
- **Profile**: Profilo utente
  - `ProfileView.swift`: Vista profilo con impostazioni

### Theme
- **ColorScheme.swift**: Schema colori basato sul design Figma

## Setup

1. Apri Xcode
2. Crea un nuovo progetto iOS App con SwiftUI
3. Nome progetto: "Lymbo"
4. Aggiungi tutti i file Swift dalla cartella `Views` e `Theme`
5. Assicurati che il deployment target sia iOS 18+

## Funzionalità Implementate

- ✅ Tab bar con 4 sezioni principali
- ✅ Schermata Connect con swipe cards
- ✅ Carosello opere
- ✅ Dettagli creativo
- ✅ Menu preferenze
- ✅ Links con Archive e Chats
- ✅ Schermata Events
- ✅ Schermata Profile con impostazioni
- ✅ Schema colori dal design Figma

## Note

- Le immagini utilizzano placeholder da picsum.photos per la demo
- I dati sono mockup per la dimostrazione
- Per produzione, integrare con backend API

