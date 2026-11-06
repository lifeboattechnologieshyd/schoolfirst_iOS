//
//  ChoosepaymentamountVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import UIKit
import SwiftUI

class ChoosepaymentamountVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        let swiftUIView = ChoosePaymentAmountView()
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
}
