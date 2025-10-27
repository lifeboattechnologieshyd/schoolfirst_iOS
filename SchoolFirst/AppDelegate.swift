//
//  AppDelegate.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 13/06/25.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        configureFirebase()

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

        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.resignOnTouchOutside = true

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
        print("Firebase configured with \(fileName).plist")
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

