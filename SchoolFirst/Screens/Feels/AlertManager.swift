//
//  AlertManager.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 06/06/26.
//

// AlertManager.swift

import UIKit

final class AlertManager {

    static let shared = AlertManager()

    private init() {}

    func showNoInternetAlert() {

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        let alert = UIAlertController(
            title: "No Internet",
            message: "Please connect to internet and try again.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        rootVC.present(alert, animated: true)
    }
}
