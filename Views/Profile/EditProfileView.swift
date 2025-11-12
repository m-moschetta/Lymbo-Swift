//
//  EditProfileView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthService()
    
    @State private var userProfile: UserProfile?
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    // Form fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var artistName = ""
    @State private var useRealName = true
    @State private var profession = ""
    @State private var bio = ""
    @State private var dateOfBirth = Date()
    @State private var location = ""
    
    // Images
    @State private var profileImage: UIImage?
    @State private var selectedWorks: [UIImage] = []
    @State private var showImagePicker = false
    @State private var showWorkPicker = false
    @State private var isPickingProfileImage = false
    
    // Portfolio URLs (per mantenere quelle esistenti)
    @State private var existingPortfolioURLs: [String] = []
    @State private var existingPortfolioPaths: [String] = []
    
    @StateObject private var locationService = LocationService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if isLoading {
                        ProgressView()
                            .padding(.top, 100)
                    } else {
                        // Profile Image Section
                        VStack(spacing: 16) {
                            Text("Profile Picture")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.foreground)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                isPickingProfileImage = true
                                showImagePicker = true
                            }) {
                                Group {
                                    if let profileImage = profileImage {
                                        Image(uiImage: profileImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else if let source = existingProfileImageSource {
                                        CachedAsyncImage(url: source.url, storagePath: source.path) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Image(systemName: "person.circle.fill")
                                                .font(.system(size: 60))
                                                .foregroundColor(.mutedForeground)
                                        }
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.mutedForeground)
                                    }
                                }
                                .frame(width: 120, height: 120)
                                .background(Color.muted)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.border, lineWidth: 2)
                                )
                                .overlay(
                                    Circle()
                                        .fill(Color.primaryColor.opacity(0.7))
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 24))
                                        )
                                )
                            }
                            
                            Text("Tap to change profile picture")
                                .font(.system(size: 14))
                                .foregroundColor(.mutedForeground)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Name Section
                        VStack(spacing: 16) {
                            Text("Name")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.foreground)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Toggle(isOn: $useRealName) {
                                Text("Use my real name")
                                    .font(.system(size: 16))
                                    .foregroundColor(.foreground)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .primaryColor))
                            
                            if useRealName {
                                TextField("First Name", text: $firstName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .foregroundColor(.foreground)
                                
                                TextField("Last Name", text: $lastName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .foregroundColor(.foreground)
                            } else {
                                TextField("Artist Name", text: $artistName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .foregroundColor(.foreground)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Date of Birth
                        VStack(spacing: 16) {
                            Text("Date of Birth")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.foreground)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .foregroundColor(.foreground)
                                .padding()
                                .background(Color.card)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // Profession
                        VStack(spacing: 16) {
                            Text("Profession")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.foreground)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("What kind of designer are you?", text: $profession)
                                .textFieldStyle(CustomTextFieldStyle())
                                .foregroundColor(.foreground)
                        }
                        .padding(.horizontal, 20)
                        
                        // Location
                        VStack(spacing: 16) {
                            Text("Location")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.foreground)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Location Display
                            if !location.isEmpty {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.primaryColor)
                                    Text(location)
                                        .font(.system(size: 16))
                                        .foregroundColor(.foreground)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.card)
                                .cornerRadius(12)
                            }
                            
                            // Get Location Button
                            Button(action: {
                                getLocation()
                            }) {
                                HStack {
                                    if locationService.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 16))
                                        Text(location.isEmpty ? "Get My Location" : "Update Location")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(locationService.isLoading ? Color.gray : Color.primaryColor)
                                .cornerRadius(8)
                            }
                            .disabled(locationService.isLoading)
                            
                            // Manual Input Option
                            TextField("Or enter your city manually", text: $location)
                                .textFieldStyle(CustomTextFieldStyle())
                                .foregroundColor(.foreground)
                            
                            if let locationError = locationService.errorMessage {
                                Text(locationError)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 20)
                        .onAppear {
                            // Richiedi permessi quando appare la sezione
                            if locationService.authorizationStatus == .notDetermined {
                                locationService.requestAuthorization()
                            }
                        }
                        
                        // Bio
                        VStack(spacing: 16) {
                            Text("Bio")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.foreground)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ZStack(alignment: .topLeading) {
                                if bio.isEmpty {
                                    Text("Tell us about yourself...")
                                        .foregroundColor(.mutedForeground)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 20)
                                }
                                
                                TextEditor(text: $bio)
                                    .frame(height: 120)
                                    .padding(8)
                                    .background(Color.primaryColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.border, lineWidth: 1)
                                    )
                                    .onChange(of: bio) { newValue in
                                        if newValue.count > 200 {
                                            bio = String(newValue.prefix(200))
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
                            }
                            
                            Text("\(bio.count)/200")
                                .font(.system(size: 12))
                                .foregroundColor(.mutedForeground)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, 20)
                        
                        // Portfolio Works
                        VStack(spacing: 16) {
                            HStack {
                                Text("Portfolio Works")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.foreground)
                                
                                Spacer()
                                
                                Button(action: {
                                    showWorkPicker = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.primaryColor)
                                }
                            }
                            
                            // Existing portfolio images
                            if !existingPortfolioURLs.isEmpty || !existingPortfolioPaths.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        let maxCount = max(existingPortfolioURLs.count, existingPortfolioPaths.count)
                                        ForEach(0..<maxCount, id: \.self) { index in
                                            let path = existingPortfolioPaths.indices.contains(index) ? existingPortfolioPaths[index] : nil
                                            let url = existingPortfolioURLs.indices.contains(index) ? URL(string: existingPortfolioURLs[index]) : nil
                                            
                                            ZStack(alignment: .topTrailing) {
                                                CachedAsyncImage(url: url, storagePath: path) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                } placeholder: {
                                                    Rectangle()
                                                        .fill(Color.muted)
                                                }
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(12)
                                                
                                                Button(action: {
                                                    if existingPortfolioURLs.indices.contains(index) {
                                                        existingPortfolioURLs.remove(at: index)
                                                    }
                                                    if existingPortfolioPaths.indices.contains(index) {
                                                        existingPortfolioPaths.remove(at: index)
                                                    }
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .background(Color.white)
                                                        .clipShape(Circle())
                                                }
                                                .padding(4)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // New selected images
                            if !selectedWorks.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(Array(selectedWorks.enumerated()), id: \.offset) { index, image in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(12)
                                                
                                                Button(action: {
                                                    selectedWorks.remove(at: index)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .background(Color.white)
                                                        .clipShape(Circle())
                                                }
                                                .padding(4)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if existingPortfolioURLs.isEmpty && selectedWorks.isEmpty {
                                Button(action: {
                                    showWorkPicker = true
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 40))
                                            .foregroundColor(.mutedForeground)
                                        Text("Add Portfolio Works")
                                            .font(.system(size: 14))
                                            .foregroundColor(.mutedForeground)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                    .background(Color.card)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        // Save Button
                        Button(action: {
                            guard !isSaving else { return }
                            saveProfile()
                        }) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Save Changes")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isSaving ? Color.gray : Color.primaryColor)
                            .cornerRadius(12)
                        }
                        .disabled(isSaving)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .background(Color.backgroundColor)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadProfile()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
            .sheet(isPresented: $showWorkPicker) {
                MultipleImagePicker(images: $selectedWorks, maxSelection: 10 - existingPortfolioURLs.count)
            }
        }
    }
    
    private func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        Task {
            do {
                let profile = try await UserProfileService.shared.fetchUserProfile(uid: uid)
                await MainActor.run {
                    self.userProfile = profile
                    
                    if let profile = profile {
                        self.firstName = profile.firstName ?? ""
                        self.lastName = profile.lastName ?? ""
                        self.artistName = profile.artistName ?? ""
                        self.useRealName = profile.artistName == nil || profile.artistName?.isEmpty == true
                        self.profession = profile.profession ?? ""
                        self.bio = profile.bio ?? ""
                        self.dateOfBirth = profile.dateOfBirth?.dateValue() ?? Date()
                        self.location = profile.location ?? ""
                        self.existingPortfolioURLs = profile.portfolioURLs ?? []
                        self.existingPortfolioPaths = profile.portfolioPaths ?? []
                    }
                    
                    self.isLoading = false
                }
            } catch {
                print("Error loading profile: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func saveProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                // Upload nuova foto profilo se presente
                var profileImageURL: String? = userProfile?.profileImageURL
                var profileImagePath: String? = userProfile?.profileImagePath
                if let profileImage = profileImage {
                    let targetPath = "profiles/\(uid)/profile.jpg"
                    let url = try await StorageService.shared.uploadProfileImage(
                        image: profileImage,
                        path: targetPath
                    )
                    profileImageURL = url.absoluteString
                    profileImagePath = targetPath
                }
                
                // Upload nuove opere
                var newWorkURLs: [String] = []
                var newWorkPaths: [String] = []
                for (index, work) in selectedWorks.enumerated() {
                    let nextIndex = existingPortfolioPaths.count + index
                    let workPath = "portfolios/\(uid)/image_\(nextIndex).jpg"
                    let url = try await StorageService.shared.uploadPortfolioImage(
                        image: work,
                        userID: uid,
                        imageIndex: nextIndex
                    )
                    newWorkURLs.append(url.absoluteString)
                    newWorkPaths.append(workPath)
                }
                
                // Combina URL esistenti e nuovi
                let allPortfolioURLs = existingPortfolioURLs + newWorkURLs
                let allPortfolioPaths = existingPortfolioPaths + newWorkPaths
                
                // Prepara gli aggiornamenti
                let displayName = useRealName ? "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces) : artistName
                
                var updates: [String: Any] = [
                    "displayName": displayName,
                    "profession": profession.isEmpty ? NSNull() : profession,
                    "bio": bio.isEmpty ? NSNull() : bio,
                    "dateOfBirth": Timestamp(date: dateOfBirth),
                    "portfolioURLs": allPortfolioURLs,
                    "portfolioPaths": allPortfolioPaths.isEmpty ? NSNull() : allPortfolioPaths
                ]
                
                if !location.isEmpty {
                    updates["location"] = location
                } else {
                    updates["location"] = NSNull()
                }
                
                if let profileImageURL = profileImageURL {
                    updates["profileImageURL"] = profileImageURL
                    print("💾 Saving profileImageURL to Firestore: \(profileImageURL)")
                }
                if let profileImagePath = profileImagePath {
                    updates["profileImagePath"] = profileImagePath
                }
                
                if !allPortfolioURLs.isEmpty {
                    updates["portfolioURLs"] = allPortfolioURLs
                    print("💾 Saving \(allPortfolioURLs.count) portfolio URLs to Firestore")
                }
                if !allPortfolioPaths.isEmpty {
                    updates["portfolioPaths"] = allPortfolioPaths
                }
                
                try await UserProfileService.shared.updateUserProfile(uid: uid, updates: updates)
                
                // Invalida la cache per le immagini aggiornate
                if let cacheKey = profileImagePath ?? profileImageURL {
                    await ImageCache.shared.removeImage(forKey: cacheKey)
                }
                
                for key in allPortfolioPaths {
                    await ImageCache.shared.removeImage(forKey: key)
                }
                for url in allPortfolioURLs {
                    await ImageCache.shared.removeImage(forKey: url)
                }
                
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSaving = false
                }
            }
        }
    }
    
    private var existingProfileImageSource: (url: URL?, path: String?)? {
        let path = userProfile?.profileImagePath
        let url = userProfile?.profileImageURL.flatMap { URL(string: $0) }
        
        if path == nil && url == nil {
            return nil
        }
        return (url, path)
    }
    
    private func getLocation() {
        Task {
            do {
                if let city = try await locationService.getCurrentCity() {
                    await MainActor.run {
                        location = city
                        locationService.errorMessage = nil
                    }
                } else {
                    await MainActor.run {
                        locationService.errorMessage = "Could not determine your city. Please enter it manually."
                    }
                }
            } catch {
                await MainActor.run {
                    if let locationError = error as? LocationError,
                       locationError == .notAuthorized {
                        locationService.errorMessage = "Location permission denied. Please enable it in Settings or enter your city manually."
                    } else {
                        locationService.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
}
