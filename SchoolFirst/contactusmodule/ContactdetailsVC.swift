//
//  ContactdetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 15/09/26.
//

import UIKit

class ContactdetailsVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
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
