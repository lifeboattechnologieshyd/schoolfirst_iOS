//
//  QuerieshistoryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit

class QuerieshistoryVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {

        self.navigationController?.popViewController(animated: true)
    }


    // MARK: - TableView Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        // Register Query Cell
        tableview.register(
            UINib(
                nibName: "QueryTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "QueryTableViewCell"
        )

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension QuerieshistoryVC: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Number of Sections

    func numberOfSections(
        in tableView: UITableView
    ) -> Int {

        return 1
    }

    // MARK: - Number of Rows

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return 1
    }

    // MARK: - Cell For Row

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "QueryTableViewCell",
            for: indexPath
        ) as! QueryTableViewCell

        cell.selectionStyle = .none

        return cell
    }

    // MARK: - Cell Height

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 150
    }

    // MARK: - Cell Selection

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        // Remove selection highlight
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        // Navigate to ChatVC
        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        if let chatVC = storyboard.instantiateViewController(
            withIdentifier: "ChatVC"
        ) as? ChatVC {

            self.navigationController?.pushViewController(
                chatVC,
                animated: true
            )
        }
    }
}
