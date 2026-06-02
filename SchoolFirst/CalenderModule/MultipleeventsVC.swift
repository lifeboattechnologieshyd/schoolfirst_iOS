//
//  MultipleeventsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/05/26.
//


import UIKit

class MultipleeventsVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(nibName: "MultipleeventsTableViewCell", bundle: nil),
            forCellReuseIdentifier: "MultipleeventsTableViewCell"
        )

        tableview.register(
            UINib(nibName: "TuitionfeeTableViewCell", bundle: nil),
            forCellReuseIdentifier: "TuitionfeeTableViewCell"
        )

        tableview.register(
            UINib(nibName: "AnualPTAMeetingTableViewCell", bundle: nil),
            forCellReuseIdentifier: "AnualPTAMeetingTableViewCell"
        )

        tableview.separatorStyle = .none
    }
}

// MARK: - UITableView Delegate & DataSource

extension MultipleeventsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "MultipleeventsTableViewCell",
                for: indexPath
            ) as! MultipleeventsTableViewCell

            cell.selectionStyle = .none
            return cell

        } else if indexPath.row == 1 {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TuitionfeeTableViewCell",
                for: indexPath
            ) as! TuitionfeeTableViewCell

            cell.selectionStyle = .none
            return cell

        } else {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "AnualPTAMeetingTableViewCell",
                for: indexPath
            ) as! AnualPTAMeetingTableViewCell

            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 0 {
            return 160
        } else if indexPath.row == 1 {
            return 180
        } else {
            return 180
        }
    }
}
