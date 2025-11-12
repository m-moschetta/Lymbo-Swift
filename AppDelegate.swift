//
//  AppDelegate.swift
//  Lymbo
//
//  Created on 2025
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, @preconcurrency UNUserNotificationCenterDelegate, @preconcurrency MessagingDelegate {
    
    @MainActor
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        // Aggiorna location all'avvio se l'utente è autenticato
        Task {
            if Auth.auth().currentUser != nil {
                await LocationService.shared.updateAndSaveLocation()
            }
        }
        
        return true
    }
    
    @MainActor
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Aggiorna location quando l'app torna in foreground
        Task {
            if Auth.auth().currentUser != nil {
                await LocationService.shared.updateAndSaveLocation()
            }
        }
    }
    
    @MainActor
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    @MainActor
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let uid = Auth.auth().currentUser?.uid, let token = fcmToken {
            // Save FCM token to Firestore for push notifications
            let db = Firestore.firestore()
            db.collection("users").document(uid).updateData([
                "fcmToken": token,
                "fcmTokenUpdatedAt": Timestamp()
            ])
        }
    }
    
    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .sound]])
    }
    
    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

