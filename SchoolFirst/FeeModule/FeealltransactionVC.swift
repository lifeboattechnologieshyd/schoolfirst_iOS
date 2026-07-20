//
//  FeealltransactionVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/06/26.
//

import UIKit

class FeealltransactionVC: UIViewController {
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var TopView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopViewShadow()
        setupTableView()
    }

    // MARK: - Back Button Action

    @IBAction func BackButtonTapped(_ sender: UIButton) {

        if let nav = navigationController {

            nav.popViewController(
                animated: true
            )

        } else {

            dismiss(
                animated: true
            )
        }
    }

    // MARK: - TableView Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false

        tableview.register(
            UINib(
                nibName: "FeetransactionTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "FeetransactionTableViewCell"
        )
    }

    // MARK: - TopView Shadow

    private func setupTopViewShadow() {

        TopView.layer.shadowColor = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity = 0.4
        TopView.layer.shadowOffset = CGSize(
            width: 0,
            height: 4
        )

        TopView.layer.shadowRadius = 2
        TopView.layer.masksToBounds = false
    }
}

// MARK: - UITableView Delegate & DataSource

extension FeealltransactionVC:
UITableViewDelegate,
UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return 15
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeetransactionTableViewCell",
            for: indexPath
        ) as! FeetransactionTableViewCell

        cell.selectionStyle = .none

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 140
    }
}
