//
//  attendedhistoryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/07/26.
//

import UIKit

class attendedhistoryVC: UIViewController {

    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopViewShadow()
        setupTableView()
    }

    // MARK: - TableView Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false

        tableview.register(
            UINib(
                nibName: "PTMpastmeetingTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "PTMpastmeetingTableViewCell"
        )
    }

    // MARK: - TopView Shadow

    private func setupTopViewShadow() {

        TopView.layer.shadowColor = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity = 0.4
        TopView.layer.shadowOffset = CGSize(width: 0, height: 4)
        TopView.layer.shadowRadius = 2
        TopView.layer.masksToBounds = false
    }
}

// MARK: - UITableView Delegate & DataSource

extension attendedhistoryVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PTMpastmeetingTableViewCell",
            for: indexPath
        ) as! PTMpastmeetingTableViewCell

        cell.selectionStyle = .none

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 150
    }
}
