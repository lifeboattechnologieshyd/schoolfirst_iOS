//
//  BulletinlistVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/10/26.
//

import UIKit
import SwiftUI

class BulletinlistVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Initialize the SwiftUI View
        let swiftUIView = BulletinListView()
        
        // 2. Create the Hosting Controller
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // 3. Add as a child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // 4. Set constraints to fill the screen
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        
        // Hide standard navigation bar if you have one, as SwiftUI has the custom purple one
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
