import UIKit
import SwiftUI

class EdutainmenthomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("⚪️ EdutainmenthomeVC viewDidLoad")
        setupSwiftUIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // ✅ NEW: once the view is in the window, stop parent tap gestures from eating SwiftUI taps
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fixBlockingGestures()
    }

    // ✅ NEW: Any UITapGestureRecognizer above this screen (keyboard-dismiss etc.)
    // cancels SwiftUI button touches by default. This makes them pass touches through.
    private func fixBlockingGestures() {
        var current: UIView? = view
        while let v = current {
            v.gestureRecognizers?.forEach { gesture in
                if gesture is UITapGestureRecognizer {
                    gesture.cancelsTouchesInView = false
                    print("🔧 Fixed blocking tap gesture on:", type(of: v))
                }
            }
            current = v.superview
        }
        view.window?.gestureRecognizers?.forEach { gesture in
            if gesture is UITapGestureRecognizer {
                gesture.cancelsTouchesInView = false
                print("🔧 Fixed blocking tap gesture on window")
            }
        }
    }

    // ✅ NEW: Create StoriesVC correctly (XIB / Storyboard / code)
    private func makeStoriesVC() -> UIViewController {
        // If StoriesVC is designed in a STORYBOARD, uncomment the next 2 lines
        // (set Storyboard ID = "StoriesVC" in Identity Inspector, change "Main" if needed):
        // let sb = UIStoryboard(name: "Main", bundle: nil)
        // return sb.instantiateViewController(withIdentifier: "StoriesVC")

        // If StoriesVC has a XIB file named StoriesVC.xib
        if Bundle.main.path(forResource: "StoriesVC", ofType: "nib") != nil {
            return StoriesVC(nibName: "StoriesVC", bundle: nil)
        }

        // Pure code VC
        return StoriesVC()
    }

    // MARK: - Single navigation helper (push if in a nav stack, otherwise present)
    private func navigate(to destination: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("🟢 navigate to:", type(of: destination),
                  "| has nav controller:", self.navigationController != nil)

            if let navigationController = self.navigationController {
                navigationController.pushViewController(destination, animated: true)
            } else {
                destination.modalPresentationStyle = .fullScreen
                self.present(destination, animated: true)
            }
        }
    }

    private func setupSwiftUIView() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        let swiftUIView = EdutainmentHomeView(
            onBack: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let navigationController = self.navigationController,
                       navigationController.viewControllers.count > 1 {
                        navigationController.popViewController(animated: true)
                    } else {
                        self.dismiss(animated: true)
                    }
                }
            },
            onSeeAllExplore: { [weak self] in
                self?.navigate(to: AlledutainementVC())
            },
            onStoriesTap: { [weak self] in
                guard let self = self else { return }
                print("🟠 onStoriesTap closure called")
                self.navigate(to: self.makeStoriesVC())   // ✅ CHANGED
            },
            onSeeAllTrending: { [weak self] in
                self?.navigate(to: TrendingVC())
            },
            onSeeAllRecentlyAdded: { [weak self] in
                self?.navigate(to: RecentlyaddedVC())
            },
            onFeaturedPlayTap: { [weak self] in
                self?.navigate(to: DIYdetailsVC())
            }
        )

        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.isUserInteractionEnabled = true

        addChild(hostingController)
        view.addSubview(hostingController.view)
        view.bringSubviewToFront(hostingController.view)

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
