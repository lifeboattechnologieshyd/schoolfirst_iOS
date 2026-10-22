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
        // Initialize reacha bility
        _ = ReachabilityManager.shared

        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        // 1. Initialize UIWindow properly with the scene
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        self.window = window

        // 2. Check login state
        let isLoggedIn = UserDefaults.standard.bool(forKey: "LOGGEDIN")
        print("📱 SceneDelegate launch - LOGGEDIN status:", isLoggedIn)

        if isLoggedIn {
            self.setHomeScreen(targetWindow: window)
        } else {
            self.setLoginScreen(targetWindow: window)
        }

        window.makeKeyAndVisible()
    }

    // MARK: - Set Initial Screen (Fallback entry)
    func setInitialScreen(targetWindow: UIWindow? = nil) {
        DispatchQueue.main.async { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let initialVC = storyboard.instantiateInitialViewController() else {
                print("❌ Could not find Initial View Controller in Main.storyboard")
                self?.setLoginScreen(targetWindow: targetWindow)
                return
            }

            let win = targetWindow ?? self?.window
            win?.rootViewController = initialVC
            print("✅ Successfully set Initial ViewController from Main.storyboard")
        }
    }

    // MARK: - Set Home Screen (MainTabBarController)
    func setHomeScreen(targetWindow: UIWindow? = nil) {
        DispatchQueue.main.async { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let win = targetWindow ?? self?.window

            guard let tabBarController = storyboard.instantiateViewController(
                withIdentifier: "MainTabBarController"
            ) as? UITabBarController else {
                print("❌ Could not find MainTabBarController in Main.storyboard")
                self?.setLoginScreen(targetWindow: targetWindow)
                return
            }

            // Safe index selection: Only set to 2 if at least 3 tabs exist
            if let count = tabBarController.viewControllers?.count, count > 2 {
                tabBarController.selectedIndex = 2
            }

            win?.rootViewController = tabBarController
            print("✅ Successfully set MainTabBarController as rootViewController")
        }
    }

    // MARK: - Set Login Screen (Preserves Storyboard & OTP flow)
    func setLoginScreen(targetWindow: UIWindow? = nil) {
        DispatchQueue.main.async { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let win = targetWindow ?? self?.window

            // 1. Prefer Initial View Controller to preserve navigation flow to OTP
            if let initialVC = storyboard.instantiateInitialViewController() {
                win?.rootViewController = initialVC
                print("🔑 Set Storyboard Initial VC as Login rootViewController")
            } else if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? UIViewController {
                // 2. Fallback to LoginVC identifier inside navigation controller
                let nav = UINavigationController(rootViewController: loginVC)
                win?.rootViewController = nav
                print("🔑 Set LoginVC in NavigationController as rootViewController")
            } else {
                print("❌ Could not find LoginVC or Initial VC in Main.storyboard")
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}

    // MARK: - Deep Link / URL Handling
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
