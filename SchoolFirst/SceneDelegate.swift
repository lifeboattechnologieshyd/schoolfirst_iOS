
//
//  SceneDelegate.swift
//  SchoolFirst
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        _ = ReachabilityManager.shared

        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        // 1. Initialize UIWindow properly with the scene
        let window = UIWindow(windowScene: windowScene)

        window.overrideUserInterfaceStyle = .light

        self.window = window

        // 2. Check if user is logged in
        let isLoggedIn = UserDefaults.standard.bool(forKey: "LOGGEDIN")

        print("📱 SceneDelegate launch - LOGGEDIN status:", isLoggedIn)

        if isLoggedIn {

            // ✅ Load Initial ViewController from Main.storyboard
            self.setInitialScreen(targetWindow: window)

        } else {

            // ✅ Set Login screen if NOT logged in
            self.setLoginScreen(targetWindow: window)
        }

        window.makeKeyAndVisible()
    }

    // MARK: - Set Initial Screen

    func setInitialScreen(targetWindow: UIWindow? = nil) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let initialVC = storyboard.instantiateInitialViewController() else {

            print("❌ Could not find Initial View Controller in Main.storyboard")

            setLoginScreen(targetWindow: targetWindow)

            return
        }

        let win = targetWindow ?? self.window ?? UIApplication.shared.windows.first

        win?.rootViewController = initialVC

        print("✅ Successfully set Initial ViewController from Main.storyboard")
    }

    // MARK: - Set Home Screen (MainTabBarController)

    func setHomeScreen(targetWindow: UIWindow? = nil) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let tabBarController = storyboard.instantiateViewController(
            withIdentifier: "MainTabBarController"
        ) as? MainTabBarController else {

            print("❌ Could not find MainTabBarController in Main.storyboard")

            setLoginScreen(targetWindow: targetWindow)

            return
        }

        tabBarController.selectedIndex = 2

        let win = targetWindow ?? self.window ?? UIApplication.shared.windows.first

        win?.rootViewController = tabBarController

        print("✅ Successfully set MainTabBarController as rootViewController")
    }

    // MARK: - Set Login Screen (Fallback when not logged in)

    func setLoginScreen(targetWindow: UIWindow? = nil) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let win = targetWindow ?? self.window ?? UIApplication.shared.windows.first

        // Try to load initial view controller from Main.storyboard
        if let initialVC = storyboard.instantiateInitialViewController() {

            win?.rootViewController = initialVC

        } else if let loginVC = storyboard.instantiateViewController(
            withIdentifier: "LoginVC"
        ) as? UIViewController {

            let nav = UINavigationController(rootViewController: loginVC)

            win?.rootViewController = nav

        } else {

            print("❌ Could not find LoginVC or Initial VC in Main.storyboard")
        }

        print("🔑 Set Login screen as rootViewController")
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}

    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {

        guard let url = URLContexts.first?.url else {
            return
        }

        let handled = PhonePePaymentManager.shared.handleDeeplink(url)

        if handled {

            print("✅ PhonePe SDK handled the URL: \(url)")

            return
        }

        print("📱 Unhandled URL: \(url)")
    }
}
