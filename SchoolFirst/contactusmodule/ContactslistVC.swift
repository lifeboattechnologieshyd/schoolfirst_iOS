//
//  ContactslistVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 11/09/26.
//

import UIKit

class ContactslistVC: UIViewController {

    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.separatorStyle = .none

        setupTableView()

        // Add back button navigation
        Backbutton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }

    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - TableView Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.rowHeight = 176

        tableview.register(
            UINib(nibName: "ContactdetailsTBVCLL", bundle: nil),
            forCellReuseIdentifier: "ContactdetailsTBVCLL"
        )

        tableview.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource

extension ContactslistVC: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 2
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ContactdetailsTBVCLL",
            for: indexPath
        ) as? ContactdetailsTBVCLL else {
            return UITableViewCell()
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ContactslistVC: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 180
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let storyboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ContactdetailsVC") as? ContactdetailsVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
