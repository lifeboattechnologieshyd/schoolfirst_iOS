//
//  TRSPRTcantactdriverVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/07/26.
//

import UIKit

class TRSPRTcantactdriverVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    // MARK: - Back Button Action
    @IBAction func BackButtonTapped(_ sender: UIButton) {
        // If screen was pushed navigate back
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup TableView
    private func setupTableView() {
        tableview.delegate   = self
        tableview.dataSource = self

        tableview.register(
            UINib(
                nibName: "TRSPRTcantactdriverVCUITableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "TRSPRTcantactdriverVCUITableViewCell"
        )

        tableview.separatorStyle               = .none
        tableview.showsVerticalScrollIndicator = false
    }

    // MARK: - Navigation Helper
    private func navigateToChat() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "TRSPTchatVC"
        ) as? TRSPTchatVC else {
            print("❌ TRSPTchatVC not found in storyboard. Check Storyboard ID.")
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension TRSPRTcantactdriverVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TRSPRTcantactdriverVCUITableViewCell",
            for: indexPath
        ) as! TRSPRTcantactdriverVCUITableViewCell

        cell.selectionStyle = .none

        // ── Assign delegate so cell can trigger navigation ──────────────
        cell.delegate = self

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 1000
    }
}

// MARK: - TRSPRTcantactdriverCellDelegate
extension TRSPRTcantactdriverVC: TRSPRTcantactdriverCellDelegate {

    func didTapMessageButton() {
        navigateToChat()
    }
}
