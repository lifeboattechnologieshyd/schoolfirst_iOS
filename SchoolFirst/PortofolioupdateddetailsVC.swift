//
//  PortofolioupdateddetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 26/06/26.
//

import UIKit

class PortofolioupdateddetailsVC: UIViewController {

    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var TopView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopViewShadow()
        setupTableView()
    }

    @IBAction func BackButtonTapped(_ sender: UIButton) {

        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - TableView Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false

        // Cell 1

        tableview.register(
            UINib(
                nibName: "PortopoliodetailsTableViewCell1",
                bundle: nil
            ),
            forCellReuseIdentifier:
            "PortopoliodetailsTableViewCell1"
        )

        // Cell 2

        tableview.register(
            UINib(
                nibName: "PortopoliodetailsTableViewCell2",
                bundle: nil
            ),
            forCellReuseIdentifier:
            "PortopoliodetailsTableViewCell2"
        )

        // Cell 3

        tableview.register(
            UINib(
                nibName: "PortopoliodetailsTableViewCell3",
                bundle: nil
            ),
            forCellReuseIdentifier:
            "PortopoliodetailsTableViewCell3"
        )
    }

    // MARK: - TopView Shadow

    private func setupTopViewShadow() {

        TopView.layer.shadowColor =
        UIColor.lightGray.cgColor

        TopView.layer.shadowOpacity = 0.4

        TopView.layer.shadowOffset =
        CGSize(width: 0, height: 4)

        TopView.layer.shadowRadius = 2

        TopView.layer.masksToBounds = false
    }
}

// MARK: - UITableView Delegate & DataSource

extension PortofolioupdateddetailsVC:
UITableViewDelegate,
UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return 3
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath.row == 0 {

            let cell =
            tableView.dequeueReusableCell(
                withIdentifier:
                "PortopoliodetailsTableViewCell1",
                for: indexPath
            ) as! PortopoliodetailsTableViewCell1

            cell.selectionStyle = .none

            return cell

        } else if indexPath.row == 1 {

            let cell =
            tableView.dequeueReusableCell(
                withIdentifier:
                "PortopoliodetailsTableViewCell2",
                for: indexPath
            ) as! PortopoliodetailsTableViewCell2

            cell.selectionStyle = .none

            return cell

        } else {

            let cell =
            tableView.dequeueReusableCell(
                withIdentifier:
                "PortopoliodetailsTableViewCell3",
                for: indexPath
            ) as! PortopoliodetailsTableViewCell3

            cell.selectionStyle = .none

            return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        if indexPath.row == 0 {

            return 1000

        } else if indexPath.row == 1 {

            return 140

        } else {

            return 60
        }
    }
}
