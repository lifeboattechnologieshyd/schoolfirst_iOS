//
//  P&TmeetingVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 02/06/26.
//

import UIKit

class P_TmeetingVC: UIViewController {

    @IBOutlet weak var NotificationButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var BackButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    @IBAction func NotificationButtonTapped(_ sender: UIButton) {
        navigateToNotificationVC()
    }
    private func navigateToNotificationVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let notificationVC = storyboard.instantiateViewController(
            withIdentifier: "NotificationVC"
        ) as? NotificationVC {

            notificationVC.hidesBottomBarWhenPushed = true

            navigationController?.pushViewController(
                notificationVC,
                animated: true
            )
        }
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
                nibName: "P_TmeetTableViewCell1",
                bundle: nil
            ),
            forCellReuseIdentifier: "P_TmeetTableViewCell1"
        )

        tableview.separatorStyle = .none
    }
}

// MARK: - UITableView Delegate & DataSource

extension P_TmeetingVC: UITableViewDelegate, UITableViewDataSource {

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
            withIdentifier: "P_TmeetTableViewCell1",
            for: indexPath
        ) as! P_TmeetTableViewCell1

        cell.selectionStyle = .none

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 1500
    }
}
