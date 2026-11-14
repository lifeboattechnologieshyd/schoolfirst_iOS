//
//  EdutainmenthomeVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 13/11/26.
//

import UIKit
import SwiftUI

class EdutainmenthomeVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupSwiftUIView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let swiftUIView = EdutainmentHomeView(
            onBack: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let navigationController = self.navigationController, navigationController.viewControllers.count > 1 {
                        navigationController.popViewController(animated: true)
                    } else {
                        self.dismiss(animated: true)
                    }
                }
            },
            onSeeAllExplore: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let allVC = AlledutainementVC()
                    if let navigationController = self.navigationController {
                        navigationController.pushViewController(allVC, animated: true)
                    } else {
                        allVC.modalPresentationStyle = .fullScreen
                        self.present(allVC, animated: true)
                    }
                }
            },
            onStoriesTap: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let storiesVC = StoriesVC()
                    if let navigationController = self.navigationController {
                        navigationController.pushViewController(storiesVC, animated: true)
                    } else {
                        storiesVC.modalPresentationStyle = .fullScreen
                        self.present(storiesVC, animated: true)
                    }
                }
            }
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
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
