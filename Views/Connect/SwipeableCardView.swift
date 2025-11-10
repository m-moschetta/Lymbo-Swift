//
//  SwipeableCardView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct SwipeableCardView: View {
    let creative: Creative
    let selectedWorkIndex: Int
    let onSwipe: (SwipeDirection) -> Void
    let onTapImage: () -> Void
    let onSelectWork: ((Int) -> Void)?
    
    @State private var dragOffset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var showOverlays = true
    @State private var isFlipped = false
    @State private var flipRotation: Double = 0 // Rotazione progressiva durante il drag
    @State private var isDraggingFlip = false // Se stiamo trascinando per ruotare
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Card Container with Shadow
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Front Side - Profile Description
                ZStack {
                    // Background
                    Color.card
                        .cornerRadius(12)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Spacer for eye icon
                            Spacer()
                                .frame(height: 60)
                            
                            // Profile Image (Large)
                            HStack {
                                Spacer()
                                Button(action: onTapImage) {
                                    AsyncImage(url: URL(string: "https://picsum.photos/120/120?random=\(creative.name.hash)")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Image(systemName: creative.profileImage)
                                            .font(.system(size: 50))
                                            .foregroundColor(.foreground)
                                    }
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.border, lineWidth: 3)
                                    )
                                }
                                Spacer()
                            }
                            .padding(.top, 8)
                            
                            // Profile Info
                            VStack(spacing: 12) {
                                Text(creative.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.foreground)
                                
                                Text(creative.type)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.mutedForeground)
                                
                                if let guild = creative.guild {
                                    Text(guild)
                                        .font(.system(size: 16))
                                        .foregroundColor(.mutedForeground)
                                }
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 14))
                                    Text(creative.position)
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.mutedForeground)
                            }
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            
                            Divider()
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                            
                            // Description
                            VStack(alignment: .leading, spacing: 12) {
                                Text("About")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.foreground)
                                
                                Text(creative.description)
                                    .font(.system(size: 16))
                                    .foregroundColor(.mutedForeground)
                                    .lineSpacing(6)
                            }
                            .padding(.horizontal, 20)
                            
                            // Portfolio Preview
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Portfolio")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.foreground)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(Array(creative.works.enumerated()), id: \.offset) { index, _ in
                                            AsyncImage(url: URL(string: "https://picsum.photos/150/150?random=\(index + 100)")) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Color.muted
                                            }
                                            .frame(width: 150, height: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                    .scrollDisabled(false) // Permetti scroll quando necessario
                }
                .rotation3DEffect(
                    .degrees(isFlipped ? flipRotation : -180 + flipRotation),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.6
                )
                .opacity({
                    // Il fronte (profilo) è visibile solo quando la card è ruotata
                    if !isFlipped {
                        // Quando non è flipped, il fronte è nascosto (mostriamo il retro di default)
                        return flipRotation >= 90 ? 1.0 : 0.0
                    } else {
                        // Quando è flipped, il fronte è visibile
                        return flipRotation < 90 ? 1.0 : 0.0
                    }
                }())
                .allowsHitTesting({
                    // Quando flipped, disabilita hit testing per permettere swipe sul contenitore principale
                    if !isFlipped {
                        return flipRotation >= 90
                    } else {
                        // Quando flipped, disabilita hit testing del ScrollView per permettere swipe
                        return false
                    }
                }())
                
                // Eye Icon - FUORI dal ZStack rotato, sempre visibile quando non flipped (mostriamo retro)
                if !isFlipped {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    isFlipped.toggle()
                                    flipRotation = 0
                                }
                            }) {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.foreground)
                                    .frame(width: 44, height: 44)
                                    .background(Color.muted)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            .padding(.top, 16)
                            .padding(.trailing, 16)
                        }
                        Spacer()
                    }
                    .allowsHitTesting(true)
                    .zIndex(1000) // Assicura che sia sempre sopra tutto quando mostra portfolio
                }
                
                // Back Side - Portfolio Images
                ZStack {
                    // Main Work Image - Shows selected work from portfolio
                    if selectedWorkIndex < creative.works.count {
                        AsyncImage(url: URL(string: "https://picsum.photos/400/600?random=\(selectedWorkIndex + 100)")) { phase in
                            switch phase {
                            case .empty:
                                Color.muted
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Color.muted
                            @unknown default:
                                Color.muted
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .cornerRadius(12)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .id("work-\(selectedWorkIndex)") // Force refresh when index changes
                    } else {
                        Color.muted
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .cornerRadius(12)
                    }
                    
                    // Back Side Overlays (visible when showing portfolio images - default state)
                    ZStack {
                        
                        // Top Left: Guild Badge with avatar icon (if present)
                        if !isFlipped && showOverlays, let guild = creative.guild {
                            VStack {
                                HStack(spacing: 8) {
                                    // Small avatar icon
                                    AsyncImage(url: URL(string: "https://picsum.photos/24/24?random=\(guild.hash)")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.accentColor)
                                    }
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                                    
                                    HStack(spacing: 4) {
                                        Text("Part of:")
                                            .font(.system(size: 11, weight: .regular))
                                        Text(guild)
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .foregroundColor(.accentColor)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.primaryColor.opacity(0.7))
                                    .cornerRadius(12)
                                    
                                    Spacer()
                                }
                                .padding(.leading, 16)
                                .padding(.top, 16)
                                
                                Spacer()
                            }
                        }
                        
                        // Bottom Section: Type, Position badges
                        if !isFlipped && showOverlays {
                            VStack {
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    // Type Badge
                                    HStack(spacing: 4) {
                                        Image(systemName: "paintbrush.fill")
                                            .font(.system(size: 12))
                                        Text(creative.type)
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(.accentColor)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.primaryColor.opacity(0.7))
                                    .cornerRadius(12)
                                    
                                    // Position Badge
                                    HStack(spacing: 4) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 12))
                                        Text(creative.position)
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(.accentColor)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.primaryColor.opacity(0.7))
                                    .cornerRadius(12)
                                    
                                    // Small thumbnails carousel at the bottom
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(Array(creative.works.enumerated()), id: \.offset) { index, _ in
                                                Button(action: {
                                                    // Update selected work index
                                                    onSelectWork?(index)
                                                }) {
                                                    AsyncImage(url: URL(string: "https://picsum.photos/60/60?random=\(index + 100)")) { phase in
                                                        switch phase {
                                                        case .empty:
                                                            Color.muted
                                                        case .success(let image):
                                                            image
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                        case .failure:
                                                            Color.muted
                                                        @unknown default:
                                                            Color.muted
                                                        }
                                                    }
                                                    .frame(width: 60, height: 60)
                                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .stroke(selectedWorkIndex == index ? Color.accentColor : Color.clear, lineWidth: 2)
                                                    )
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                    .frame(height: 70)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 16)
                                .padding(.bottom, 16)
                            }
                        }
                    }
                }
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 + flipRotation : flipRotation),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.6
                )
                .opacity({
                    // Il retro (immagini portfolio) è visibile di default
                    if !isFlipped {
                        // Quando non è flipped, il retro è visibile di default (flipRotation < 90)
                        return flipRotation < 90 ? 1.0 : 0.0
                    } else {
                        // Quando è flipped, il retro è nascosto (mostriamo il fronte)
                        return flipRotation >= 90 ? 1.0 : 0.0
                    }
                }())
                .allowsHitTesting({
                    // Disabilita hit testing quando è nascosto
                    if !isFlipped {
                        return flipRotation < 90
                    } else {
                        // Quando flipped, disabilita sempre hit testing per permettere swipe sul fronte
                        return false
                    }
                }())
                .animation(.spring(response: 0.7, dampingFraction: 0.6), value: selectedWorkIndex)
                
                // Eye Icon - FUORI dal ZStack rotato, sempre visibile quando flipped
                if isFlipped {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    isFlipped.toggle()
                                    flipRotation = 0
                                }
                            }) {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.accentColor)
                                    .frame(width: 44, height: 44)
                                    .background(Color.primaryColor.opacity(0.8))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            .padding(.top, 16)
                            .padding(.trailing, 16)
                        }
                        Spacer()
                    }
                    .allowsHitTesting(true)
                    .zIndex(1000) // Assicura che sia sempre sopra tutto quando mostra profilo
                }
                
            }
            .offset(dragOffset)
            .rotationEffect(.degrees(rotation))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Se la card non è ancora ruotata
                        if !isFlipped {
                            // Se si trascina verso destra, gestisci la rotazione
                            if value.translation.width > 0 {
                                // Rotazione progressiva seguendo il movimento del dito verso destra
                                let dragProgress = value.translation.width / geometry.size.width
                                flipRotation = Double(dragProgress * 180)
                                
                                // Limita la rotazione tra 0 e 180 gradi
                                flipRotation = max(0, min(180, flipRotation))
                                
                                isDraggingFlip = true
                            } else {
                                // Se si trascina verso sinistra, permetti lo swipe normale (pass)
                                dragOffset = value.translation
                                rotation = Double(value.translation.width / 10)
                                isDraggingFlip = false
                            }
                        } else {
                            // Se la card è già ruotata, permetti lo swipe normale (like/pass)
                            dragOffset = value.translation
                            rotation = Double(value.translation.width / 10)
                        }
                    }
                    .onEnded { value in
                        if !isFlipped {
                            if isDraggingFlip {
                                // Gestisci la rotazione quando si trascina verso destra
                                let dragProgress = value.translation.width / geometry.size.width
                                let velocity = value.predictedEndTranslation.width / geometry.size.width
                                
                                // Se trascinato oltre il 50% o con velocità sufficiente, completa la rotazione
                                if dragProgress > 0.5 || velocity > 0.5 {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                        isFlipped = true
                                        flipRotation = 0
                                    }
                                } else {
                                    // Altrimenti torna indietro
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        flipRotation = 0
                                    }
                                }
                                isDraggingFlip = false
                            } else {
                                // Gestisci lo swipe quando si trascina verso sinistra
                                let swipeThreshold: CGFloat = 100
                                
                                if abs(value.translation.width) > swipeThreshold {
                                    if value.translation.width < 0 {
                                        // Swipe verso sinistra = Pass
                                        onSwipe(.left)
                                    }
                                } else if value.translation.height < -swipeThreshold {
                                    showOverlays = false
                                    onSwipe(.up)
                                } else if value.translation.height > swipeThreshold {
                                    showOverlays = true
                                    onSwipe(.down)
                                }
                                
                                // Reset della posizione con animazione
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    dragOffset = .zero
                                    rotation = 0
                                }
                            }
                        } else if isFlipped {
                            // Swipe normale quando la card è ruotata
                            let swipeThreshold: CGFloat = 100
                            
                            if abs(value.translation.width) > swipeThreshold {
                                if value.translation.width > 0 {
                                    // Swipe verso destra = Like
                                    onSwipe(.right)
                                } else {
                                    // Swipe verso sinistra = Pass
                                    onSwipe(.left)
                                }
                            } else if value.translation.height < -swipeThreshold {
                                showOverlays = false
                                onSwipe(.up)
                            } else if value.translation.height > swipeThreshold {
                                showOverlays = true
                                onSwipe(.down)
                            }
                            
                            // Reset della posizione con animazione
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                dragOffset = .zero
                                rotation = 0
                            }
                        }
                    }
            )
        }
    }
}

#Preview {
    SwipeableCardView(
        creative: sampleCreatives[0],
        selectedWorkIndex: 0,
        onSwipe: { _ in },
        onTapImage: {},
        onSelectWork: nil
    )
    .frame(height: 600)
    .padding()
}

