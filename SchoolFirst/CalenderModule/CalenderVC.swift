//
//  CalenderVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/05/26.
//

//
//  CalenderVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/05/26.
//

import UIKit

class CalenderVC: UIViewController {

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
            UINib(nibName: "CalenderVCTableViewCell1", bundle: nil),
            forCellReuseIdentifier: "CalenderVCTableViewCell1"
        )

        tableview.separatorStyle = .none
    }
}

// MARK: - UITableView Delegate & DataSource

extension CalenderVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CalenderVCTableViewCell1",
            for: indexPath
        ) as! CalenderVCTableViewCell1

        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1000
    }
}
