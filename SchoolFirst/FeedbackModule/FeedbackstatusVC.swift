//
//  FeedbackstatusVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbackstatusVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Backbutton: UIButton!

    // MARK: - ✅ Passed-in Feedback Data
    // didSet ensures table reloads automatically whenever feedback is assigned,
    // regardless of whether it's set before or after viewDidLoad.
    var feedback: Feedback? {
        didSet {
            print("📦 FeedbackstatusVC — feedback set:", feedback?.subject ?? "nil")
            Tableview?.reloadData()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBackButton()

        if feedback == nil {
            print("⚠️ FeedbackstatusVC — viewDidLoad: feedback is nil. Make sure caller sets vc.feedback before pushing.")
        } else {
            print("✅ FeedbackstatusVC — viewDidLoad: feedback already set →", feedback?.subject ?? "")
        }

        Tableview.reloadData()
    }

    // MARK: - Setup Methods
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.showsVerticalScrollIndicator = false

        Tableview.register(UINib(nibName: "FeedbacksummuryTBLVWCell", bundle: nil), forCellReuseIdentifier: "FeedbacksummuryTBLVWCell")
    }

    private func setupBackButton() {
        Backbutton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }

    // MARK: - Back Action (Pop / Dismiss)
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FeedbackstatusVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeedbacksummuryTBLVWCell",
            for: indexPath
        ) as! FeedbacksummuryTBLVWCell

        // ── Populate cell with API feedback data ──
        if let feedback = feedback {
            cell.configure(with: feedback)
        } else {
            print("❌ cellForRowAt — feedback is nil, cell will show static/default values")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1000
    }
}
