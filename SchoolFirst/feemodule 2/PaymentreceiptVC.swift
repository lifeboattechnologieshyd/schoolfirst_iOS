//
//  PaymentreceiptVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 06/11/26.
//

import UIKit
import SwiftUI

class PaymentreceiptVC: UIViewController {
    
    // Injected API Data
    var feeResponse: PendingFeeResponse?
    var paymentCreationData: FeePaymentCreationResponse?
    var verifyPaymentData: FeeVerifyPaymentData?
    
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
        // Passed onBack closure and API models to PaymentReceiptView
        let swiftUIView = PaymentReceiptView(
            feeData: feeResponse,
            creationData: paymentCreationData,
            verifyData: verifyPaymentData,
            onBack: { [weak self] in
                self?.handleBackNavigation()
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
    
    // Handles pop navigation back to previous screen
    private func handleBackNavigation() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
