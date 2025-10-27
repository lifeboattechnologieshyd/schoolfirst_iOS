//
//  AppDelegate.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 13/06/25.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        configureFirebase()
        setupNavigationBar()
        setupKeyboardManager()

         setupPushNotifications(application: application)

        Analytics.logEvent("app_launched", parameters: nil)
        Crashlytics.crashlytics().log("App started")

        return true
    }

     private func configureFirebase() {
        #if PROD
        let fileName = "GoogleService-Info-Prod"
        #else
        let fileName = "GoogleService-Info-dev"
        #endif

        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: filePath) else {
            print("Could not find \(fileName).plist. Make sure it's added to your target and the name matches exactly.")
            return
        }

        FirebaseApp.configure(options: options)
        Messaging.messaging().delegate = self

        print("Firebase configured with \(fileName).plist")
    }

     private func setupNavigationBar() {
        if #available(iOS 15.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = .white
            navBarAppearance.shadowColor = .lightGray
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]

            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
        }
    }

    private func setupKeyboardManager() {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }

     private func setupPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("Push permission granted: \(granted)")
            if let error = error {
                print("Error requesting push permissions: \(error.localizedDescription)")
            }
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }

     func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            print(" No FCM token received.")
            return
        }
        #if PROD
        print("PROD FCM token: \(token)")
        #else
        print("DEV FCM token: \(token)")
        #endif
    }

     func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }

     func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

