//
//  PaymentsuccessVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import UIKit
import SwiftUI

class PaymentsuccessVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    // Keeps nav bar hidden when returning to this screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupSwiftUIView() {
        //   Passed onBack and onViewReceipt closures to PaymentSuccessView
        let swiftUIView = PaymentSuccessView(
            onBack: { [weak self] in
                // ADDED: Handle back navigation (pop)
                self?.handleBackNavigation()
            },
            onViewReceipt: { [weak self] in
                //  Navigate to PaymentreceiptVC when "View detailed receipt" is tapped
                let receiptVC = PaymentreceiptVC()
                self?.navigationController?.pushViewController(receiptVC, animated: true)
            }
        )
        
        // 2. Wrap it in a UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // 3. Add the Hosting Controller as a child
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // 4. Setup Constraints to fill the entire View Controller
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Hide the default UINavigationController bar
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //  Handles pop navigation back to previous screen 
    private func handleBackNavigation() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
