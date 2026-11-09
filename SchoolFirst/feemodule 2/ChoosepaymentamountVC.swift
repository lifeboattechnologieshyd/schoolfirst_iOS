//
//  ChoosepaymentamountVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import UIKit
import SwiftUI

class ChoosepaymentamountVC: UIViewController {
    
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
        let swiftUIView = ChoosePaymentAmountView(
            feeData: feeResponse,
            onBack: { [weak self] in
                self?.handleBackNavigation()
            },
            onContinue: { [weak self] selectedAmount in
                // **** UPDATED: Navigate to ReviewpaymentVC and pass API data and selected amount ****
                let reviewVC = ReviewpaymentVC()
                reviewVC.feeResponse = self?.feeResponse
                reviewVC.selectedAmount = selectedAmount
                self?.navigationController?.pushViewController(reviewVC, animated: true)
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
