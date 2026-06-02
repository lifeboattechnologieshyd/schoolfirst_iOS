//
//  FeeEventVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 01/06/26.
//

import UIKit

class FeeEventVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    // MARK: - Setup TableView

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(nibName: "FeeEventTableViewCell1", bundle: nil),
            forCellReuseIdentifier: "FeeEventTableViewCell1"
        )

        tableview.separatorStyle = .none
    }
}

// MARK: - UITableView Delegate & DataSource

extension FeeEventVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeeEventTableViewCell1",
            for: indexPath
        ) as! FeeEventTableViewCell1

        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1000
    }
}
