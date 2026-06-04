//
//  AnnualsportsdayVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 02/06/26.
//

import UIKit

class AnnualsportsdayVC: UIViewController {

    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    // MARK: - Back Button Action

    @IBAction func BackButtonTapped(_ sender: UIButton) {

        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Setup TableView

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(
                nibName: "AnualsportsTableViewCell1",
                bundle: nil
            ),
            forCellReuseIdentifier: "AnualsportsTableViewCell1"
        )

        tableview.separatorStyle = .none
        tableview.allowsSelection = false
    }
}

// MARK: - UITableView Delegate & DataSource

extension AnnualsportsdayVC: UITableViewDelegate, UITableViewDataSource {

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

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AnualsportsTableViewCell1",
            for: indexPath
        ) as! AnualsportsTableViewCell1

        cell.selectionStyle = .none

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 1000
    }
}
