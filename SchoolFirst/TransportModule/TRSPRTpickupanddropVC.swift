//
//  TRSPRTpickupanddropVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/07/26.
//

import UIKit

class TRSPRTpickupanddropVC: UIViewController {

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
            UINib(
                nibName: "TRSPRTpickupanddropUITableviewcell",
                bundle: nil
            ),
            forCellReuseIdentifier: "TRSPRTpickupanddropUITableviewcell"
        )

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension TRSPRTpickupanddropVC: UITableViewDelegate, UITableViewDataSource {

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
            withIdentifier: "TRSPRTpickupanddropUITableviewcell",
            for: indexPath
        ) as! TRSPRTpickupanddropUITableviewcell

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
