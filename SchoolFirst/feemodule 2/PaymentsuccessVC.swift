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
    
    private func setupSwiftUIView() {
        // 1. Create the SwiftUI View
        let swiftUIView = PaymentSuccessView()
        
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
}
