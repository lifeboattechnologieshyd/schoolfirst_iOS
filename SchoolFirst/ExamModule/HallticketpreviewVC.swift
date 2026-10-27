import UIKit
import SwiftUI

// MARK: - View Controller Wrapper
class HallticketpreviewVC: UIViewController {
    
    // Primary exam ID (next exam) passed from ExamhomeVC
    var examID: String = ""
    
    // ✅ NEW: Other exam IDs to try if the primary exam has no hall ticket yet
    var candidateExamIDs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let swiftUIView = HallTicketView(
            examID: examID,
            candidateExamIDs: candidateExamIDs,
            onBack: { [weak self] in
                guard let self = self else { return }
                if let nav = self.navigationController, nav.viewControllers.count > 1 {
                    nav.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
