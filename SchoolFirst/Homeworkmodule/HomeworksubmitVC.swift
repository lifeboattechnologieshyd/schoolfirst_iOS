
//  HomeworksubmitVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/09/26.
//

import UIKit

class HomeworksubmitVC: UIViewController {

    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Topview: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
    }

    // MARK: - UI Setup

    private func setupUI() {

        Topview.layer.shadowColor = UIColor.gray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(
            width: 0,
            height: 4
        )
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
    }

    // MARK: - TableView Setup

    private func setupTableView() {

        Tableview.delegate = self
        Tableview.dataSource = self

        Tableview.register(
            UINib(nibName: "SubmithomeworkTableViewCell", bundle: nil),
            forCellReuseIdentifier: "identifier"
        )

        Tableview.rowHeight = 1000
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension HomeworksubmitVC: UITableViewDelegate, UITableViewDataSource {

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

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "identifier",
            for: indexPath
        ) as? SubmithomeworkTableViewCell else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 800
    }
}

