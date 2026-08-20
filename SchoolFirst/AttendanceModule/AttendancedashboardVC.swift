//
//  AttendancedashboardVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/08/26.
//

import UIKit
import QuartzCore

class AttendancedashboardVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var tableview: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBottomCornerRadius()
        setupTableView()
    }

    // MARK: - Bottom Corner Radius
    private func setupBottomCornerRadius() {
        TopView.layer.cornerRadius = 32

        // Round only bottom-left and bottom-right corners
        TopView.layer.maskedCorners = [
            .layerMinXMaxYCorner, // Bottom-left
            .layerMaxXMaxYCorner  // Bottom-right
        ]

        TopView.layer.masksToBounds = true
        TopView.layer.cornerCurve = .continuous
    }

    // MARK: - TableView Setup
    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        // Register custom UITableViewCell
        tableview.register(
            UINib(nibName: "ATDNCdashboardUITableViewCell1", bundle: nil),
            forCellReuseIdentifier: "ATDNCdashboardUITableViewCell1"
        )

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension AttendancedashboardVC: UITableViewDelegate, UITableViewDataSource {

    // MARK: Number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // MARK: Number of Rows
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1
    }

    // MARK: Cell For Row
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ATDNCdashboardUITableViewCell1",
            for: indexPath
        ) as! ATDNCdashboardUITableViewCell1

        cell.selectionStyle = .none

        // ✅ Stat cards (replace with API values later)
        cell.configure(present: 18, absent: 5, leave: 2, attendancePercent: 72)

        return cell
    }

    // MARK: Row Height
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        // collectionview top area (~say collectionview ends at 60 in XIB)
        // + 16 (calendar top space)
        // + 426 (calendar height)
        // + 16 bottom breathing space
        return 1000 // keep your existing height — calendar sits within it
    }
}
