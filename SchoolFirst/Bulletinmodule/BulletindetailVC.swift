//
//  BulletindetailVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 26/10/26.
//

import UIKit
import SwiftUI

class BulletindetailVC: UIViewController {
    
    var bulletin: BulletinEntry?
    
    // MARK: - Initializers
    init(bulletin: BulletinEntry? = nil) {
        self.bulletin = bulletin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
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
        let detailView = BulletinDetailView(
            bulletin: bulletin,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onShare: { [weak self] shareText in
                self?.shareAnnouncement(text: shareText)
            }
        )
        
        let hostingController = UIHostingController(rootView: detailView)
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
    
    private func shareAnnouncement(text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(activityVC, animated: true)
    }
}
