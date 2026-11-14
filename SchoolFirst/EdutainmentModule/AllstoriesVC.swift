//
//  AllstoriesVC.swift
//  SchoolFirst
//

import UIKit
import SwiftUI

final class AllstoriesVC: UIViewController {

    private var hostingController: UIHostingController<AllStoriesView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 1.0, alpha: 1.0)
        setupSwiftUIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupSwiftUIView() {
        guard hostingController == nil else { return }

        let root = AllStoriesView(
            onBack: { [weak self] in
                guard let self = self else { return }
                if let nav = self.navigationController, nav.viewControllers.count > 1 {
                    nav.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            },
            onSearchTap: {
                // TODO: Search
            },
            onStoryTap: { [weak self] story in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let detailVC = PicturestoryVC()
                    // Later: detailVC.storyId = story.id
                    if let nav = self.navigationController {
                        nav.pushViewController(detailVC, animated: true)
                    } else {
                        detailVC.modalPresentationStyle = .fullScreen
                        self.present(detailVC, animated: true)
                    }
                }
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
