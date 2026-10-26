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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupSwiftUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupSwiftUIView() {
        // 1. Initialize the SwiftUI View with back & selection callbacks
        let swiftUIView = BulletinListView(
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onSelectBulletin: { [weak self] selectedBulletin in
                let detailVC = BulletindetailVC(bulletin: selectedBulletin)
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
        )
        
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
    }
}
