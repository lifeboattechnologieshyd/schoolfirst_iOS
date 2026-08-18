//
//  HomeworkVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var NotificationButton: UIButton!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var Topview: UIView!

    // MARK: - Data Source
    private var homeworkList: [HomeworkModel] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        TableView.separatorStyle = .none

        setupUI()
        setupTableView()
        loadHomeworkData()
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

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        if let notificationVC =
            storyboard.instantiateViewController(
                withIdentifier: "NotificationVC"
            ) as? NotificationVC {

            notificationVC.hidesBottomBarWhenPushed = true

            navigationController?.pushViewController(
                notificationVC,
                animated: true
            )
        }
    }

    // MARK: - UI Setup

    private func setupUI() {

        Topview.layer.shadowColor =
        UIColor.gray.cgColor

        Topview.layer.shadowOpacity = 0.4

        Topview.layer.shadowOffset =
        CGSize(
            width: 0,
            height: 4
        )

        Topview.layer.shadowRadius = 2

        Topview.layer.masksToBounds = false
    }

    // MARK: - Table Setup

    private func setupTableView() {

        TableView.delegate = self
        TableView.dataSource = self

        TableView.separatorStyle = .none

        TableView.register(
            UINib(
                nibName: "HomeworkStudentTableViewCell1",
                bundle: nil
            ),
            forCellReuseIdentifier:
            "HomeworkStudentTableViewCell1"
        )

        TableView.register(
            UINib(
                nibName: "HomeworkwithsubTableViewCell2",
                bundle: nil
            ),
            forCellReuseIdentifier:
            "HomeworkwithsubTableViewCell2"
        )
    }

    // MARK: - Load Sample Data

    private func loadHomeworkData() {

        homeworkList = [

            HomeworkModel(
                priorityType: .highPriority,
                subject: .mathematics,
                title: "Fractions Exercise",
                description: "Complete the practice problems on pages 45-47 in the workbook. Focus on improper fractions and mixed numbers.",
                dueDate: "Due: Oct 24, 2023",
                teacherName: "Mrs. Smith"
            ),

            HomeworkModel(
                priorityType: .medPriority,
                subject: .science,
                title: "Solar System Model",
                description: "Create a scale model of the planets using recyclable materials.",
                dueDate: "Due: Oct 28, 2023",
                teacherName: "Mr. Johnson"
            ),

            HomeworkModel(
                priorityType: .done,
                subject: .history,
                title: "The Industrial Revolution",
                description: "Write a 200-word summary.",
                dueDate: "Finished: Oct 20",
                teacherName: "Ms. Davis"
            )
        ]

        TableView.reloadData()
    }
}

// MARK: - TableView

extension HomeworkVC:
UITableViewDelegate,
UITableViewDataSource {

    func numberOfSections(
        in tableView: UITableView
    ) -> Int {

        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return 1 + homeworkList.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath.row == 0 {

            let cell =
            tableView.dequeueReusableCell(
                withIdentifier:
                "HomeworkStudentTableViewCell1",
                for: indexPath
            ) as! HomeworkStudentTableViewCell1

            cell.selectionStyle = .none

            return cell
        }

        let cell =
        tableView.dequeueReusableCell(
            withIdentifier:
            "HomeworkwithsubTableViewCell2",
            for: indexPath
        ) as! HomeworkwithsubTableViewCell2

        cell.selectionStyle = .none

        let homework =
        homeworkList[
            indexPath.row - 1
        ]

    

        // MARK: View Details Navigation
        // FIXED: Changed 'onViewDetailsTap' to 'onViewDetailsTapped' to match the cell property
        cell.onViewDetailsTapped = { [weak self] in

            guard let self = self else {
                return
            }

            let storyboard =
            UIStoryboard(
                name: "Main",
                bundle: nil
            )

            if let vc =
                storyboard.instantiateViewController(
                    withIdentifier:
                    "HomeworkDetailsVC"
                ) as? HomeworkDetailsVC {

                self.navigationController?
                    .pushViewController(
                        vc,
                        animated: true
                    )
            }
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        if indexPath.row == 0 {
            return 140
        }

        return 290
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        guard indexPath.row > 0 else {
            return
        }

        let homework =
        homeworkList[
            indexPath.row - 1
        ]

        print(
            "Tapped: \(homework.title)"
        )
    }
}
