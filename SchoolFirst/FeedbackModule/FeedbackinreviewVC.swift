//
//  FeedbackinreviewVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 13/10/26.
//

import UIKit

class FeedbackinreviewVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Backbutton: UIButton!
    
    var feedback: Feedback? {
        didSet {
            print("📦 FeedbackinreviewVC — feedback set:", feedback?.subject ?? "nil")
            Tableview?.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Tableview.separatorStyle = .none
        
        setupTableView()
        
        if feedback == nil {
            print("⚠️ FeedbackinreviewVC — viewDidLoad: feedback is nil. Make sure caller sets vc.feedback before pushing.")
        } else {
            print("✅ FeedbackinreviewVC — viewDidLoad: feedback already set →", feedback?.subject ?? "")
        }

        Tableview.reloadData()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        // Set delegates
        Tableview.delegate = self
        Tableview.dataSource = self
        
        Tableview.rowHeight = UITableView.automaticDimension
        Tableview.estimatedRowHeight = 500
        
        // Register the Custom XIB/Nib Cell
        let nib = UINib(nibName: "FeedbackinreviewTBLVWCell", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: "FeedbackinreviewTBLVWCell")
        
        // Remove extra empty cell separators below
        Tableview.tableFooterView = UIView()
    }
    
  
    // MARK: - Back Navigation Action
    @IBAction func backButtonTapped(_ sender: UIButton) {
        popOrDismiss()
    }
    
  
    private func popOrDismiss() {
        // Pops if pushed on a NavigationController, otherwise dismisses if presented modally
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FeedbackinreviewVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return your dynamic count or 1 for preview
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackinreviewTBLVWCell", for: indexPath) as? FeedbackinreviewTBLVWCell else {
            return UITableViewCell()
        }
        
        // ── Populate cell with API feedback data ──
        if let feedback = feedback {
            cell.configure(with: feedback)
        } else {
            print("❌ cellForRowAt — feedback is nil, cell will show static/default values")
        }
        
        return cell
    }
    
    // MARK: - Cell Height (Dynamic)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
