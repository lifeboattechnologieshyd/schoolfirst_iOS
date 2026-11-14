//
//  TrendingVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 13/11/26.
//

import UIKit
import SwiftUI

final class TrendingVC: UIViewController {

    private var hostingController: UIHostingController<TrendingView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 1.0, alpha: 1.0)
        setupSwiftUIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupSwiftUIView() {
        guard hostingController == nil else { return }

        let root = TrendingView(
            onBack: { [weak self] in
                guard let self = self else { return }
                if let nav = self.navigationController, nav.viewControllers.count > 1 {
                    nav.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            },
            onSearchTap: {
                // TODO: Open Search screen
            },
            onItemTap: { item in
                // TODO: Open DIY / Activity detail using item.id
                print("Open trending item:", item.id)
            },
            onPlayTap: { item in
                // TODO: Play video / open detail using item.id
                print("Play trending item:", item.id)
            }
        )

        let host = UIHostingController(rootView: root)
        hostingController = host
        host.view.backgroundColor = .clear

        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        host.didMove(toParent: self)
    }
}
