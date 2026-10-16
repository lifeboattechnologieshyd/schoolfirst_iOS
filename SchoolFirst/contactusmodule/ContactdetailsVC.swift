//
//  ContactdetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 15/09/26.
//

import UIKit

class ContactdetailsVC: UIViewController {

    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        // Add back button navigation
        Backbutton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }

    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - TableView Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(nibName: "ContactfulldetailsTBVCLL", bundle: nil),
            forCellReuseIdentifier: "ContactfulldetailsTBVCLL"
        )

        tableview.rowHeight = 1400

        tableview.separatorStyle = .none

        tableview.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource

extension ContactdetailsVC: UITableViewDataSource {

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

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ContactfulldetailsTBVCLL",
            for: indexPath
        ) as? ContactfulldetailsTBVCLL else {
            return UITableViewCell()
        }

        // Handle navigation to ChatVC
        cell.onChatButtonTapped = { [weak self] in
            guard let self = self else { return }
            let storyboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ContactdetailsVC: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 800
    }
}
