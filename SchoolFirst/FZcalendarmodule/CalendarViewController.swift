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
        
        // 2. Initialize your new SwiftUI View with Back Action + Month View Action
        let swiftUIView = LifeSkillsCalendarView(
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onMonthViewTap: { [weak self] in
                guard let self = self else { return }
                
                // Make sure we run on main thread
                DispatchQueue.main.async {
                    // ---------- WAY 1: Programmatic VC ----------
                    let monthVC = CalendarmonthviewVC()
                    
                    // ---------- WAY 2: If your VC is in Storyboard, use this instead ----------
                    // let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    // let monthVC = storyboard.instantiateViewController(withIdentifier: "CalendarmonthviewVC") as! CalendarmonthviewVC
                    
                    // Show navigation bar on the next screen
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    self.navigationController?.pushViewController(monthVC, animated: true)
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
        // Keep nav bar hidden when coming back to this screen
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
