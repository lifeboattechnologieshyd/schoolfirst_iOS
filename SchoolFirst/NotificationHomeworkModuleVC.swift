//
//  NotificationHomeworkModuleVC.swift
//  SchoolFirst
//

import UIKit

class NotificationHomeworkModuleVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var TopView: UIView!

    var notifications: [[String: String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopViewShadow()
        setupTableView()
        loadDummyData()
    }

    private func setupTopViewShadow() {
        TopView.layer.shadowColor = UIColor.gray.cgColor
        TopView.layer.shadowOpacity = 4
        TopView.layer.shadowOffset = CGSize(width: 0, height: 4)
        TopView.layer.shadowRadius = 4
        TopView.layer.masksToBounds = false
    }

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.separatorStyle = .none

        tableview.register(
            UINib(
                nibName: "NotificationTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "NotificationTableViewCell"
        )
    }

    private func loadDummyData() {

        notifications = [

            [
                "title" : "New Homework Assigned",
                "description" : "Mathematics: Complete Exercise 4.2 on Quadratic Equations. Due by Friday.",
                "time" : "10:30 AM",
                "image" : "book.fill"
            ],

            [
                "title" : "Attendance Alert",
                "description" : "Leo was marked absent for the 1st Period today.",
                "time" : "2 hr ago",
                "image" : "exclamationmark.triangle.fill"
            ],

            [
                "title" : "Fee Reminder",
                "description" : "Q4 Tuition Fee payment is due in 5 days.",
                "time" : "9:15 AM",
                "image" : "creditcard.fill"
            ],

            [
                "title" : "Annual Sports Day",
                "description" : "The schedule for next month's Sports Day has been published.",
                "time" : "Yesterday",
                "image" : "sportscourt.fill"
            ],

            [
                "title" : "Results Published",
                "description" : "Mid-term results are now available in the portal.",
                "time" : "Yesterday",
                "image" : "star.fill"
            ]
        ]
    }
}

// MARK: - UITableView

extension NotificationHomeworkModuleVC:
UITableViewDelegate,
UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return notifications.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "NotificationTableViewCell",
            for: indexPath
        ) as! NotificationTableViewCell

        let item = notifications[indexPath.row]

        cell.Notificationtitle.text = item["title"]
        cell.Description.text = item["description"]
        cell.Timebadge.text = item["time"]

        if #available(iOS 13.0, *) {
            cell.NotificationImage.image = UIImage(
                systemName: item["image"] ?? "bell.fill"
            )
        }

        switch indexPath.row {

        case 0:
            cell.ImageBackgroundView.backgroundColor =
                UIColor.systemBlue.withAlphaComponent(0.15)
            cell.NotificationImage.tintColor = .systemBlue

        case 1:
            cell.ImageBackgroundView.backgroundColor =
                UIColor.systemRed.withAlphaComponent(0.15)
            cell.NotificationImage.tintColor = .systemRed

        case 2:
            cell.ImageBackgroundView.backgroundColor =
                UIColor.systemGray5
            cell.NotificationImage.tintColor = .gray

        default:
            cell.ImageBackgroundView.backgroundColor =
                UIColor.systemBlue.withAlphaComponent(0.15)
            cell.NotificationImage.tintColor = .systemBlue
        }

        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 150
    }
}
