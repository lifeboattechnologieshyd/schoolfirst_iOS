//
//  PresentdetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 16/10/26.
//

import UIKit

class PresentdetailsVC: UIViewController {

    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Tableview: UITableView!

    // Received from the tapped Present attendance row.
    var attendanceRecord: FetchStudentAttendanceRecord?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        Backbutton.addTarget(
            self,
            action: #selector(didTapBackButton),
            for: .touchUpInside
        )

        // Configure the controller's date label.
        updateDateLabel()
    }

    // MARK: - Back Button Action
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Navigate to Weekly Attendance
    private func navigateToWeeklyAttendance() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Try storyboard first; fall back to plain init
        if let weeklyVC = storyboard.instantiateViewController(
            withIdentifier: "WeaklyattendanceVC"
        ) as? WeaklyattendanceVC {
            navigationController?.pushViewController(weeklyVC, animated: true)
            return
        }

        // Fallback if not in storyboard / different ID
        let weeklyVC = WeaklyattendanceVC()
        navigationController?.pushViewController(weeklyVC, animated: true)
    }

    // MARK: - Configure Controller Date Label
    private func updateDateLabel() {
        let dateString = (attendanceRecord?.attendanceDate ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !dateString.isEmpty else {
            DateLabel.text = "—"
            return
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: dateString) else {
            DateLabel.text = dateString
            return
        }

        formatter.dateFormat = "EEEE, dd MMM yyyy"
        DateLabel.text = formatter.string(from: date)
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false

        Tableview.register(
            UINib(nibName: "PresentdetailsTBLVCLL", bundle: nil),
            forCellReuseIdentifier: "PresentdetailsTBLVCLL"
        )
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension PresentdetailsVC: UITableViewDelegate, UITableViewDataSource {

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
            withIdentifier: "PresentdetailsTBLVCLL",
            for: indexPath
        ) as? PresentdetailsTBLVCLL else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none
        cell.configure(with: attendanceRecord)

        // Wire the weekly attendance button → navigate
        cell.onWeeklyAttendanceTapped = { [weak self] in
            self?.navigateToWeeklyAttendance()
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 800
    }
}
