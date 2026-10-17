//
//  FeedbackResolvedVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 13/10/26.
//

import UIKit

class FeedbackResolvedVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Backbutton: UIButton!

    var feedback: Feedback? {
        didSet {
            print("📦 FeedbackResolvedVC — feedback set:", feedback?.subject ?? "nil")
            Tableview?.reloadData()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        Tableview.separatorStyle = .none

        if feedback == nil {
            print("⚠️ FeedbackResolvedVC — viewDidLoad: feedback is nil. Make sure caller sets vc.feedback before pushing.")
        } else {
            print("✅ FeedbackResolvedVC — viewDidLoad: feedback already set →", feedback?.subject ?? "")
        }

        Tableview.reloadData()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.showsVerticalScrollIndicator = false
        
        // Register Cell
        let nib = UINib(nibName: "FeedbackresolvedTBLVCll", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: "FeedbackresolvedTBLVCll")
        
        Tableview.tableFooterView = UIView()
    }
    
   
    // MARK: - Back Navigation Action (Pop / Dismiss)
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FeedbackResolvedVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeedbackresolvedTBLVCll",
            for: indexPath
        ) as! FeedbackresolvedTBLVCll

        // ── Populate cell with API feedback data ──
        if let feedback = feedback {
            cell.configure(with: feedback)
        } else {
            print("❌ cellForRowAt — feedback is nil, cell will show static/default values")
        }

        return cell
    }
    
    // MARK: - Height for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
}
