//
//  StorydetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 14/11/26.
//

import UIKit
import SwiftUI

class StorydetailsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUI()
    }

    private func embedSwiftUI() {
        let hosting = UIHostingController(rootView: StoryDetailsScreen())
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hosting.didMove(toParent: self)
    }
}
