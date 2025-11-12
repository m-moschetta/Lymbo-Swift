//
//  LocationService.swift
//  Lymbo
//
//  Created on 2025
//

import Foundation
import CoreLocation
import Combine
import FirebaseAuth

@MainActor
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    nonisolated(unsafe) private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var currentCity: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var pendingCityContinuations: [CheckedContinuation<String?, Error>] = []
    private var isGeocoding = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Request Authorization
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Get Current Location
    
    func getCurrentCity() async throws -> String? {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            throw LocationError.notAuthorized
        }
        
        isLoading = true
        errorMessage = nil
        
        if let cachedCity = currentCity {
            isLoading = false
            return cachedCity
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            pendingCityContinuations.append(continuation)
            
            if let currentLocation = currentLocation {
                triggerReverseGeocode(location: currentLocation)
            } else {
                locationManager.requestLocation()
            }
        }
    }
    
    // MARK: - Reverse Geocoding
    
    private func triggerReverseGeocode(location: CLLocation) {
        guard !pendingCityContinuations.isEmpty else {
            return
        }
        
        if isGeocoding {
            return
        }
        isGeocoding = true
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            Task { @MainActor in
                self.isLoading = false
                self.isGeocoding = false
                
                if let error = error {
                    self.resolveContinuations(with: .failure(error))
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    self.resolveContinuations(with: .success(nil))
                    return
                }
                
                // Preferisci la città (locality), altrimenti usa il nome del luogo (name)
                let city = placemark.locality ?? placemark.administrativeArea ?? placemark.name ?? "Unknown"
                self.currentCity = city
                self.resolveContinuations(with: .success(city))
            }
        }
    }
    
    private func resolveContinuations(with result: Result<String?, Error>) {
        let continuations = pendingCityContinuations
        pendingCityContinuations.removeAll()
        
        for continuation in continuations {
            switch result {
            case .success(let city):
                continuation.resume(returning: city)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Update and Save Location Automatically
    
    /// Aggiorna la location e la salva automaticamente nel profilo utente
    func updateAndSaveLocation() async {
        // Controlla se i permessi sono stati concessi
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            // Se i permessi non sono stati concessi, non fare nulla (silent fail)
            return
        }
        
        // Controlla se c'è un utente autenticato
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        do {
            // Ottieni la città corrente
            if let city = try await getCurrentCity(), !city.isEmpty {
                // Salva nel profilo utente
                try await UserProfileService.shared.updateUserProfile(uid: uid, updates: [
                    "location": city
                ])
                print("📍 Location updated automatically: \(city)")
            }
        } catch {
            // Silent fail - non bloccare l'app se l'aggiornamento location fallisce
            print("⚠️ Failed to update location automatically: \(error.localizedDescription)")
        }
    }
    
    /// Richiede una nuova posizione senza geocoding (per aggiornare currentLocation)
    func requestLocationUpdate() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        locationManager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        Task { @MainActor in
            self.currentLocation = location
            self.triggerReverseGeocode(location: location)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            self.resolveContinuations(with: .failure(error))
            self.isGeocoding = false
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            
            // Se i permessi sono stati concessi e c'è un utente autenticato, aggiorna la location
            if (status == .authorizedWhenInUse || status == .authorizedAlways) && 
               Auth.auth().currentUser != nil {
                Task {
                    await self.updateAndSaveLocation()
                }
            }
        }
    }
}

// MARK: - Location Errors

enum LocationError: LocalizedError {
    case notAuthorized
    case locationNotFound
    case geocodingFailed
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Location permission not granted"
        case .locationNotFound:
            return "Could not determine your location"
        case .geocodingFailed:
            return "Could not determine your city"
        }
    }
}
