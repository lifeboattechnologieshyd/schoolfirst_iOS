import UIKit
import SwiftUI

class StoriesVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }

    private func setupSwiftUIView() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        let root = StoriesHomeView(
            onBack: { [weak self] in
                guard let self else { return }
                if let nav = self.navigationController, nav.viewControllers.count > 1 {
                    nav.popViewController(animated: true)
                } else { self.dismiss(animated: true) }
            },
            onDIYTap: { [weak self] in
                guard let self, let nav = self.navigationController else { return }
                if let i = nav.viewControllers.firstIndex(where: { $0 is EdutainmenthomeVC }) {
                    nav.popToViewController(nav.viewControllers[i], animated: true)
                } else {
                    nav.pushViewController(EdutainmenthomeVC(), animated: true)
                }
            },
            onSeeAllRecent: { [weak self] in
                guard let self else { return }
                let vc = AlledutainementVC()
                if let nav = self.navigationController { nav.pushViewController(vc, animated: true) }
                else { vc.modalPresentationStyle = .fullScreen; self.present(vc, animated: true) }
            }
        )

        let host = UIHostingController(rootView: root)
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
