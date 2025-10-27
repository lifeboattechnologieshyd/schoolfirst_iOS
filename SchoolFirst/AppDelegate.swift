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

         FirebaseApp.configure()

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

        return true
    }

     func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
     }
}

