//
//  StudentportfolioVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/06/26.
//

import UIKit

class StudentportfolioVC: UIViewController {
    
    @IBOutlet weak var NotificationButton: UIButton!
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

    // MARK: - TABLEVIEW SETUP

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false

        tableview.register(
            UINib(
                nibName: "StudentportfolioVCTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier:
            "StudentportfolioVCTableViewCell"
        )
    }

    // MARK: - TOPVIEW SHADOW

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

// MARK: - TABLEVIEW DELEGATE & DATASOURCE

extension StudentportfolioVC:
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

        let cell =
        tableView.dequeueReusableCell(
            withIdentifier:
            "StudentportfolioVCTableViewCell",
            for: indexPath
        ) as! StudentportfolioVCTableViewCell

        cell.selectionStyle = .none

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 496
    }

    // MARK: - Cell Tap Navigation

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        let storyboard =
        UIStoryboard(
            name: "Main",
            bundle: nil
        )

        if let vc =
            storyboard.instantiateViewController(
                withIdentifier:
                "PortofolioupdateddetailsVC"
            ) as? PortofolioupdateddetailsVC {

            vc.hidesBottomBarWhenPushed = true

            navigationController?.pushViewController(
                vc,
                animated: true
            )
        }
    }
}
