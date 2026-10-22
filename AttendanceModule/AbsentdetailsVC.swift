//
//  AbsentdetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 16/10/26.
//

import UIKit

class AbsentdetailsVC: UIViewController {

    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Academicyearandtermlabel: UILabel!
    @IBOutlet weak var Tableview: UITableView!

    // Received from the selected attendance row.
    var attendanceRecord: FetchStudentAttendanceRecord?
    var academicYear: FetchStudentAttendanceAcademicYear?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        Backbutton.addTarget(
            self,
            action: #selector(didTapBackButton),
            for: .touchUpInside
        )

        updateAcademicYear()
    }

    // MARK: - Back Button Action
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Academic Year
    private func updateAcademicYear() {
        let yearName = (academicYear?.name ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // The response provides academic year, but no term.
        Academicyearandtermlabel.text = yearName.isEmpty
            ? "Academic year: —"
            : "Academic year \(yearName)"
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false

        Tableview.register(
            UINib(nibName: "AbsentdetailsTBLVCLL", bundle: nil),
            forCellReuseIdentifier: "AbsentdetailsTBLVCLL"
        )
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension AbsentdetailsVC: UITableViewDelegate, UITableViewDataSource {

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
            withIdentifier: "AbsentdetailsTBLVCLL",
            for: indexPath
        ) as? AbsentdetailsTBLVCLL else {
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
        return 700
    }
}
