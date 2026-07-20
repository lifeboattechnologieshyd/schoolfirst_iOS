//
//  PaymentsuccessRecieptVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/06/26.
//

import UIKit

class PaymentsuccessRecieptVC: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                nibName: "PaymentsuccessRecieptVCTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "PaymentsuccessRecieptVCTableViewCell"
        )
    }
}

// MARK: - UITableView Delegate & DataSource

extension PaymentsuccessRecieptVC:
UITableViewDelegate,
UITableViewDataSource {

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
            withIdentifier: "PaymentsuccessRecieptVCTableViewCell",
            for: indexPath
        ) as! PaymentsuccessRecieptVCTableViewCell

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
