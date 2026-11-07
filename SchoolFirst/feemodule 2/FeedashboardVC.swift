//
//  FeedashboardVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import UIKit
import SwiftUI

class FeedashboardVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    // Keeps the navigation bar hidden when returning from FeedetailsVC
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupSwiftUIView() {
        // 1. Create the SwiftUI View with Callbacks
        let swiftUIView = FeeDashboardView(
            onBack: { [weak self] in
                self?.handleBackNavigation()
            },
            onPayFees: { [weak self] in
                let detailsVC = FeedetailsVC()
                if let nav = self?.navigationController {
                    nav.pushViewController(detailsVC, animated: true)
                } else {
                    self?.present(detailsVC, animated: true)
                }
            },
            
            onViewHistory: { [weak self] in
                let historyVC = PaymenthistoryVC()
                if let nav = self?.navigationController {
                    nav.pushViewController(historyVC, animated: true)
                } else {
                    self?.present(historyVC, animated: true)
                }
            }
        )
        
        // 2. Wrap it in a UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // 3. Add the Hosting Controller as a child
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // 4. Setup Constraints to fill the entire VC
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Hide the default navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func handleBackNavigation() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
