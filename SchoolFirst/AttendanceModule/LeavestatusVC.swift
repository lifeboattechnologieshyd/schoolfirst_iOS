//
//  LeavestatusVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 13/08/26.
//

import UIKit

class LeavestatusVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var Topview: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopViewShadow()
        setupTableView()
    }

    private func setupTopViewShadow() {
        Topview.layer.shadowColor = UIColor.lightGray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
    }

    // MARK: - TableView Setup
    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(
                nibName: "ATDNCLeavestatusUITableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "ATDNCLeavestatusUITableViewCell"
        )

        tableview.register(
            UINib(
                nibName: "ATDNCLeavestatusUITableViewCell2",
                bundle: nil
            ),
            forCellReuseIdentifier: "ATDNCLeavestatusUITableViewCell2"
        )

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension LeavestatusVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        // Index 0, 1, 2, 3
        return 4
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        // MARK: - Index 0
        if indexPath.row == 0 {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ATDNCLeavestatusUITableViewCell",
                for: indexPath
            ) as! ATDNCLeavestatusUITableViewCell

            cell.selectionStyle = .none

            return cell
        }

        // MARK: - Index 1, 2, 3
        if indexPath.row == 1 ||
           indexPath.row == 2 ||
           indexPath.row == 3 {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ATDNCLeavestatusUITableViewCell2",
                for: indexPath
            ) as! ATDNCLeavestatusUITableViewCell2

            cell.selectionStyle = .none

            return cell
        }

        return UITableViewCell()
    }

    // MARK: - Cell Height
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        // Index 0
        if indexPath.row == 0 {
            return 120
        }

        // Index 1, 2, 3
        if indexPath.row == 1 ||
           indexPath.row == 2 ||
           indexPath.row == 3 {

            return 160
        }

        return UITableView.automaticDimension
    }
}
