//
//  FeedetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import UIKit
import SwiftUI

class FeedetailsVC: UIViewController {
    
    var feeResponse: PendingFeeResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupSwiftUIView() {
        let swiftUIView = FeeDetailsView(
            feeData: feeResponse,
            onBack: { [weak self] in
                self?.handleBackNavigation()
            },
            onChoosePaymentAmount: { [weak self] in
                let paymentAmountVC = ChoosepaymentamountVC()
                // **** ADDED: Pass the API response to the Choose Payment Amount screen ****
                paymentAmountVC.feeResponse = self?.feeResponse
                self?.navigationController?.pushViewController(paymentAmountVC, animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
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
