//
//  CreateAccountFlowView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

struct CreateAccountFlowView: View {
    @StateObject private var authService = AuthService()
    @State private var currentStep: OnboardingStep = .authMethod
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date()
    @State private var useRealName = true
    @State private var artistName = ""
    @State private var selectedCategory = ""
    @State private var customCategory = ""
    @State private var selectedWorks: [UIImage] = []
    @State private var profileImage: UIImage?
    @State private var bio = ""
    @State private var location = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showImagePicker = false
    @State private var showWorkPicker = false
    @StateObject private var locationService = LocationService.shared
    
    enum OnboardingStep {
        case authMethod
        case emailPasswordStep
        case verifyNameInfo  // Nuovo step per verificare/modificare dati da Google
        case nameInfo
        case designerCategory
        case uploadWorks
        case profilePicture
        case bio
        case location
        case ready
        case tutorial
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                switch currentStep {
                case .authMethod:
                    authMethodStep
                case .emailPasswordStep:
                    emailPasswordStep
                case .verifyNameInfo:
                    verifyNameInfoStep
                case .nameInfo:
                    nameInfoStep
                case .designerCategory:
                    designerCategoryStep
                case .uploadWorks:
                    uploadWorksStep
                case .profilePicture:
                    profilePictureStep
                case .bio:
                    bioStep
                case .location:
                    locationStep
                case .ready:
                    readyStep
                case .tutorial:
                    tutorialStep
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Se l'utente è già autenticato ma non ha completato l'onboarding,
                // salta il passo auth e vai direttamente al nome
                if authService.isAuthenticated && currentStep == .authMethod {
                    currentStep = .nameInfo
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
            .sheet(isPresented: $showWorkPicker) {
                MultipleImagePicker(images: $selectedWorks, maxSelection: 10)
            }
        }
    }
    
    // MARK: - Auth Method Step
    private var authMethodStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.foreground)
                    .padding(.top, 60)
                
                Text("Choose how you want to sign up")
                    .font(.system(size: 16))
                    .foregroundColor(.mutedForeground)
            }
            
            VStack(spacing: 16) {
                // Google Sign In
                Button(action: handleGoogleSignIn) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "globe")
                                .font(.system(size: 18))
                            Text("Continue with Google")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(isLoading ? Color.gray : Color.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
                .padding(.horizontal, 24)
                
                // Apple Sign In
                Button(action: handleAppleSignIn) {
                    HStack {
                        Image(systemName: "applelogo")
                            .font(.system(size: 18))
                        Text("Continue with Apple")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.foreground)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
                .padding(.horizontal, 24)
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.border)
                    Text("OR")
                        .font(.system(size: 14))
                        .foregroundColor(.mutedForeground)
                        .padding(.horizontal, 16)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.border)
                }
                .padding(.vertical, 8)
                
                // Email/Password Button
                Button(action: {
                    currentStep = .emailPasswordStep
                }) {
                    Text("Sign up with Email")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.foreground)
                }
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Email/Password Step (temporary state)
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showEmailPassword = false
    
    private var emailPasswordStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Create Account")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.foreground)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .foregroundColor(.foreground)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .foregroundColor(.foreground)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                        .foregroundColor(.foreground)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: handleEmailSignUp) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isValidEmailForm && !isLoading ? Color.primaryColor : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isValidEmailForm || isLoading)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
    
    private var isValidEmailForm: Bool {
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    // MARK: - Verify Name Info Step (per Google Sign-In con dati esistenti)
    private var verifyNameInfoStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Is this information correct?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.foreground)
                        .padding(.top, 40)
                    
                    Text("We found this information in your account")
                        .font(.system(size: 16))
                        .foregroundColor(.mutedForeground)
                }
                
                VStack(spacing: 16) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(CustomTextFieldStyle())
                        .foregroundColor(.foreground)
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(CustomTextFieldStyle())
                        .foregroundColor(.foreground)
                    
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color.card)
                        .cornerRadius(12)
                    
                    Button(action: {
                        useRealName.toggle()
                    }) {
                        HStack {
                            Image(systemName: useRealName ? "square" : "checkmark.square.fill")
                                .foregroundColor(.primaryColor)
                            Text("Don't use my real name")
                                .font(.system(size: 16))
                                .foregroundColor(.foreground)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    if !useRealName {
                        TextField("Artist Name", text: $artistName)
                            .textFieldStyle(CustomTextFieldStyle())
                            .foregroundColor(.foreground)
                    }
                }
                
                Button(action: {
                    currentStep = .designerCategory
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Name Info Step
    private var nameInfoStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Tell us about yourself")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.foreground)
                        .padding(.top, 40)
                }
                
                if useRealName {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(CustomTextFieldStyle())
                } else {
                    TextField("Artist Name", text: $artistName)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .foregroundColor(.foreground)
                    .padding()
                    .background(Color.card)
                    .cornerRadius(12)
                
                Button(action: {
                    useRealName.toggle()
                }) {
                    HStack {
                        Image(systemName: useRealName ? "square" : "checkmark.square.fill")
                            .foregroundColor(.primaryColor)
                        Text("Don't use my real name")
                            .font(.system(size: 16))
                            .foregroundColor(.foreground)
                    }
                }
                .padding(.horizontal, 24)
                
                Button(action: {
                    currentStep = .designerCategory
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Designer Category Step
    private var designerCategoryStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("What kind of designer are you?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.foreground)
                    .padding(.top, 40)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(designerCategories, id: \.self) { category in
                        CategoryButton(
                            title: category,
                            isSelected: selectedCategory == category,
                            action: {
                                selectedCategory = category
                                customCategory = ""
                            }
                        )
                    }
                }
                
                TextField("Or add your own", text: $customCategory)
                    .textFieldStyle(CustomTextFieldStyle())
                    .foregroundColor(.foreground)
                    .onChange(of: customCategory) { newValue in
                        if !newValue.isEmpty {
                            selectedCategory = ""
                        }
                    }
                
                if !customCategory.isEmpty && ProfanityFilter.shared.containsProfanity(customCategory) {
                    Text("Please use appropriate language")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    if !customCategory.isEmpty && !ProfanityFilter.shared.containsProfanity(customCategory) {
                        selectedCategory = customCategory
                    }
                    currentStep = .uploadWorks
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background((selectedCategory.isEmpty && customCategory.isEmpty) ? Color.gray : Color.primaryColor)
                        .cornerRadius(12)
                }
                .disabled(selectedCategory.isEmpty && customCategory.isEmpty)
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Upload Works Step
    private var uploadWorksStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Choose up to 10 artworks that represent you")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.foreground)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                
                if selectedWorks.isEmpty {
                    Button(action: {
                        showWorkPicker = true
                    }) {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundColor(.mutedForeground)
                            Text("Add Artworks")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.foreground)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.card)
                        .cornerRadius(12)
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(selectedWorks.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
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
                            
                            if selectedWorks.count < 10 {
                                Button(action: {
                                    showWorkPicker = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 30))
                                        .foregroundColor(.mutedForeground)
                                        .frame(width: 120, height: 120)
                                        .background(Color.card)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                Button(action: {
                    currentStep = .profilePicture
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                Button(action: {
                    currentStep = .profilePicture
                }) {
                    Text("Skip for now")
                        .font(.system(size: 14))
                        .foregroundColor(.mutedForeground)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Profile Picture Step
    private var profilePictureStep: some View {
        VStack(spacing: 32) {
            Text("Show yourself (or don't)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.foreground)
                .multilineTextAlignment(.center)
                .padding(.top, 60)
            
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.border, lineWidth: 2)
                    )
                    .onTapGesture {
                        showImagePicker = true
                    }
            } else {
                Button(action: {
                    showImagePicker = true
                }) {
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.mutedForeground)
                        Text("Add Profile Picture")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.foreground)
                    }
                    .frame(width: 200, height: 200)
                    .background(Color.card)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.border, lineWidth: 2)
                    )
                }
            }
            
            Button(action: {
                currentStep = .bio
            }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primaryColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            
            Button(action: {
                currentStep = .bio
            }) {
                Text("Skip for now")
                    .font(.system(size: 14))
                    .foregroundColor(.mutedForeground)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Bio Step
    private var bioStep: some View {
        VStack(spacing: 32) {
            Text("Tell us about yourself")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.foreground)
                .padding(.top, 60)
            
            ZStack(alignment: .topLeading) {
                if bio.isEmpty {
                    Text("Write something about yourself...")
                        .foregroundColor(.mutedForeground)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                }
                
                TextEditor(text: $bio)
                    .frame(height: 150)
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
                    .scrollContentBackground(.hidden) // Nasconde lo sfondo predefinito del TextEditor
            }
            
            Text("\(bio.count)/200")
                .font(.system(size: 12))
                .foregroundColor(.mutedForeground)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Button(action: {
                completeOnboarding()
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isLoading ? Color.gray : Color.primaryColor)
                .cornerRadius(12)
            }
            .disabled(isLoading)
            .padding(.horizontal, 24)
            
            Button(action: {
                completeOnboarding()
            }) {
                Text("Skip for now")
                    .font(.system(size: 14))
                    .foregroundColor(.mutedForeground)
            }
            .disabled(isLoading)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Location Step
    private var locationStep: some View {
        VStack(spacing: 32) {
            Text("Where are you located?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.foreground)
                .padding(.top, 60)
            
            Text("We'll use your location to find creatives near you")
                .font(.system(size: 16))
                .foregroundColor(.mutedForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            // Location Display
            if !location.isEmpty {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.primaryColor)
                    Text(location)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.foreground)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.card)
                .cornerRadius(12)
                .padding(.horizontal, 24)
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
                            .font(.system(size: 18))
                        Text(location.isEmpty ? "Get My Location" : "Update Location")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(locationService.isLoading ? Color.gray : Color.primaryColor)
                .cornerRadius(12)
            }
            .disabled(locationService.isLoading)
            .padding(.horizontal, 24)
            
            // Manual Input Option
            TextField("Or enter your city manually", text: $location)
                .textFieldStyle(CustomTextFieldStyle())
                .foregroundColor(.foreground)
                .padding(.horizontal, 24)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Button(action: {
                completeOnboarding()
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isLoading ? Color.gray : Color.primaryColor)
                .cornerRadius(12)
            }
            .disabled(isLoading)
            .padding(.horizontal, 24)
            
            Button(action: {
                completeOnboarding()
            }) {
                Text("Skip for now")
                    .font(.system(size: 14))
                    .foregroundColor(.mutedForeground)
            }
            .disabled(isLoading)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            // Richiedi permessi quando appare lo step
            if locationService.authorizationStatus == .notDetermined {
                locationService.requestAuthorization()
            }
        }
    }
    
    private func getLocation() {
        Task {
            do {
                if let city = try await locationService.getCurrentCity() {
                    await MainActor.run {
                        location = city
                        errorMessage = nil
                    }
                } else {
                    await MainActor.run {
                        errorMessage = "Could not determine your city. Please enter it manually."
                    }
                }
            } catch {
                await MainActor.run {
                    if let locationError = error as? LocationError,
                       locationError == .notAuthorized {
                        errorMessage = "Location permission denied. Please enable it in Settings or enter your city manually."
                    } else {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    // MARK: - Ready Step
    private var readyStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.primaryColor)
            
            Text("You are ready!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.foreground)
            
            Text("Welcome to Lymbo")
                .font(.system(size: 18))
                .foregroundColor(.mutedForeground)
            
            Spacer()
            
            Button(action: {
                currentStep = .tutorial
            }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primaryColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
        }
    }
    
    // MARK: - Tutorial Step
    private var tutorialStep: some View {
        TutorialCardsView()
            .environmentObject(authService)
    }
    
    // MARK: - Helper Functions
    private func handleGoogleSignIn() {
        isLoading = true
        errorMessage = nil
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            isLoading = false
            errorMessage = "Unable to get root view controller"
            return
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            isLoading = false
            errorMessage = "Google Sign-In configuration error"
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [self] result, error in
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.errorMessage = "Failed to get Google credentials"
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let displayName = user.profile?.name ?? ""
            let nameComponents = displayName.components(separatedBy: " ")
            let firstName = nameComponents.first ?? ""
            let lastName = nameComponents.dropFirst().joined(separator: " ")
            
            Task { @MainActor in
                do {
                    try await self.authService.signInWithGoogle(idToken: idToken, accessToken: accessToken)
                    
                    // Se Google ha fornito nome, mostra schermata di verifica
                    if !firstName.isEmpty {
                        self.firstName = firstName
                        self.lastName = lastName
                        // Google non fornisce direttamente la data di nascita, quindi lasciamo quella di default
                        self.currentStep = .verifyNameInfo
                    } else {
                        // Se non ci sono dati, vai direttamente al passo nome
                        self.currentStep = .nameInfo
                    }
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleAppleSignIn() {
        errorMessage = "Apple Sign-In coming soon"
    }
    
    private func handleEmailSignUp() {
        guard isValidEmailForm else {
            errorMessage = "Please fill all fields correctly"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signUp(
                    email: email,
                    password: password,
                    displayName: ""
                )
                
                await MainActor.run {
                    isLoading = false
                    currentStep = .nameInfo
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func completeOnboarding() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                guard let uid = Auth.auth().currentUser?.uid else {
                    throw NSError(domain: "OnboardingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
                }
                
                let displayName = useRealName ? "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces) : artistName
                
                if displayName.isEmpty {
                    throw NSError(domain: "OnboardingError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Please enter your name"])
                }
                
                // Upload immagini se presenti (non bloccare se fallisce)
                var profileImageURL: String?
                var profileImagePath: String?
                if let profileImage = profileImage {
                    do {
                        let targetPath = "profiles/\(uid)/profile.jpg"
                        let url = try await StorageService.shared.uploadProfileImage(
                            image: profileImage,
                            path: targetPath
                        )
                        profileImageURL = url.absoluteString
                        profileImagePath = targetPath
                    } catch {
                        print("Error uploading profile image: \(error)")
                        // Continua anche se l'upload fallisce
                    }
                }
                
                // Upload opere (non bloccare se fallisce)
                var workURLs: [String] = []
                var workPaths: [String] = []
                for (index, work) in selectedWorks.enumerated() {
                    do {
                        let workPath = "portfolios/\(uid)/image_\(index).jpg"
                        let url = try await StorageService.shared.uploadPortfolioImage(
                            image: work,
                            userID: uid,
                            imageIndex: index
                        )
                        workURLs.append(url.absoluteString)
                        workPaths.append(workPath)
                    } catch {
                        print("Error uploading work \(index): \(error)")
                        // Continua anche se l'upload fallisce
                    }
                }
                
                // Verifica se il profilo esiste già (da Google Sign-In)
                let existingProfile = try? await UserProfileService.shared.fetchUserProfile(uid: uid)
                
                if existingProfile == nil {
                    // Crea nuovo profilo solo se non esiste
                    try await UserProfileService.shared.createUserProfile(
                        uid: uid,
                        email: Auth.auth().currentUser?.email ?? "",
                        displayName: displayName
                    )
                }
                
                // Aggiorna con tutti i dati dell'onboarding
                var updates: [String: Any] = [
                    "displayName": displayName,
                    "profession": selectedCategory.isEmpty ? NSNull() : selectedCategory,
                    "bio": bio.isEmpty ? NSNull() : bio,
                    "dateOfBirth": Timestamp(date: dateOfBirth),
                    "hasCompletedOnboarding": true
                ]
                
                if !location.isEmpty {
                    updates["location"] = location
                }
                
                if let profileImageURL = profileImageURL {
                    updates["profileImageURL"] = profileImageURL
                    print("💾 Saving profileImageURL to Firestore: \(profileImageURL)")
                } else {
                    print("⚠️ profileImageURL is nil, not saving")
                }
                
                if let profileImagePath = profileImagePath {
                    updates["profileImagePath"] = profileImagePath
                }
                
                if !workURLs.isEmpty {
                    updates["portfolioURLs"] = workURLs
                    updates["portfolioPaths"] = workPaths
                    print("💾 Saving \(workURLs.count) portfolio URLs to Firestore")
                } else {
                    updates["portfolioPaths"] = NSNull()
                    print("⚠️ No portfolio URLs to save")
                }
                
                if useRealName {
                    updates["firstName"] = firstName
                    updates["lastName"] = lastName
                    updates["artistName"] = NSNull()
                } else {
                    updates["artistName"] = artistName
                    updates["firstName"] = NSNull()
                    updates["lastName"] = NSNull()
                }
                
                // Aggiorna tutto in una sola chiamata
                try await UserProfileService.shared.updateUserProfile(uid: uid, updates: updates)
                
                // Aggiorna lo stato in AuthService
                await MainActor.run {
                    authService.hasCompletedOnboarding = true
                    currentStep = .ready
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                    print("Error completing onboarding: \(error)")
                }
            }
        }
    }
    
    private let designerCategories = [
        "Graphic Designer",
        "UI/UX Designer",
        "Product Designer",
        "Fashion Designer",
        "Interior Designer",
        "Web Designer",
        "Motion Designer",
        "Illustrator",
        "Art Director",
        "Brand Designer",
        "Type Designer",
        "Packaging Designer"
    ]
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .foreground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.primaryColor : Color.card)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.primaryColor : Color.border, lineWidth: 1)
                )
        }
    }
}

#Preview {
    CreateAccountFlowView()
}
