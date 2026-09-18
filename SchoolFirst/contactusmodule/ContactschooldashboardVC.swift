//
//  ContactschooldashboardVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/09/26.
//

import UIKit

class ContactschooldashboardVC: UIViewController {

    @IBOutlet weak var Tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register XIB cell
        let nib = UINib(nibName: "ContactdashboardTBLVCLL", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: "ContactdashboardTBLVCLL")

        // TableView setup
        Tableview.delegate = self
        Tableview.dataSource = self

        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ContactschooldashboardVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ContactdashboardTBLVCLL",
            for: indexPath
        )

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
