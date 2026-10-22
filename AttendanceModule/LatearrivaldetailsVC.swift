//
//  LatearrivalVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 16/10/26.
//

import UIKit

class LatearrivaldetailsVC: UIViewController {

    @IBOutlet weak var Latedatelabel: UILabel!
    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Tableview: UITableView!

    // Received from the tapped Late attendance row.
    var attendanceRecord: FetchStudentAttendanceRecord?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        Backbutton.addTarget(
            self,
            action: #selector(didTapBackButton),
            for: .touchUpInside
        )

        updateDateLabel()
    }

    // MARK: - Back Button Action
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Selected Attendance Date
    private func updateDateLabel() {
        guard let dateString = attendanceRecord?.attendanceDate?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !dateString.isEmpty else {
            Latedatelabel.text = "—"
            return
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: dateString) else {
            Latedatelabel.text = dateString
            return
        }

        formatter.dateFormat = "EEEE, dd MMM yyyy"
        Latedatelabel.text = formatter.string(from: date)
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false

        Tableview.register(
            UINib(nibName: "LatearrivaldetailsTBLVCLL", bundle: nil),
            forCellReuseIdentifier: "LatearrivaldetailsTBLVCLL"
        )
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension LatearrivaldetailsVC: UITableViewDelegate, UITableViewDataSource {

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
            withIdentifier: "LatearrivaldetailsTBLVCLL",
            for: indexPath
        ) as? LatearrivaldetailsTBLVCLL else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none
        cell.configure(with: attendanceRecord)

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 800
    }
}
