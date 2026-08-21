//
//  ChatVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit

class ChatVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var backButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    // MARK: - Table View Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false

        // Dynamic row height
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 100

        // Register sender message cell
        tableview.register(
            UINib(
                nibName: "ChatsenderUITableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "ChatsenderUITableViewCell"
        )

        // Register staff message cell
        tableview.register(
            UINib(
                nibName: "ChatstaffUITableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "ChatstaffUITableViewCell"
        )
    }

    // MARK: - Actions

    @IBAction func backButtonTapped(_ sender: UIButton) {

        if let navigationController = navigationController {
            navigationController.popViewController(
                animated: true
            )
        } else {
            dismiss(
                animated: true
            )
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ChatVC:
    UITableViewDataSource,
    UITableViewDelegate {

    func numberOfSections(
        in tableView: UITableView
    ) -> Int {

        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        // Index 0: Sender message
        // Index 1: Staff message
        return 2
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        // MARK: - Index 0: Sender Message

        if indexPath.row == 0 {

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChatsenderUITableViewCell",
                for: indexPath
            ) as? ChatsenderUITableViewCell else {

                return UITableViewCell()
            }

            cell.selectionStyle = .none

            return cell
        }

        // MARK: - Index 1: Staff Message

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChatstaffUITableViewCell",
            for: indexPath
        ) as? ChatstaffUITableViewCell else {

            return UITableViewCell()
        }

        cell.selectionStyle = .none

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 100
    }
}
