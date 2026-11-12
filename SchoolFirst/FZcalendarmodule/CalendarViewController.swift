import UIKit
import SwiftUI

// =====================================================
// MARK: - CalendarViewController (UIKit Host)
// =====================================================
class CalendarViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Hide the UIKit Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // 2. Initialize SwiftUI View with Back + Month View + View All Action
        let swiftUIView = LifeSkillsCalendarView(
            onBack: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let nav = self.navigationController, nav.viewControllers.count > 1 {
                        nav.popViewController(animated: true)
                    } else if self.presentingViewController != nil {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        // Came directly from TabBar (no nav stack) -> go to Home tab
                        self.tabBarController?.selectedIndex = 2
                    }
                }
            },
            onMonthViewTap: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let monthVC = CalendarmonthviewVC()
                    monthVC.hidesBottomBarWhenPushed = true
                    monthVC.modalPresentationStyle = .fullScreen
                    
                    if let nav = self.navigationController {
                        nav.pushViewController(monthVC, animated: true)
                    } else {
                        self.present(monthVC, animated: true, completion: nil)
                    }
                }
            },
            onViewAllTap: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let pastVC = PastdatesactivitiesVC()
                    pastVC.hidesBottomBarWhenPushed = true
                    pastVC.modalPresentationStyle = .fullScreen
                    
                    if let nav = self.navigationController {
                        nav.pushViewController(pastVC, animated: true)
                    } else {
                        // TabBar case: navigationController is nil, so present
                        self.present(pastVC, animated: true, completion: nil)
                    }
                }
            }
        )
        
        // 3. Wrap it in a UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear
        
        // 4. Add the hosting controller to the current view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // 5. Set up AutoLayout constraints so the SwiftUI view fills the entire screen
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 6. Notify the hosting controller that it was added
        hostingController.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
