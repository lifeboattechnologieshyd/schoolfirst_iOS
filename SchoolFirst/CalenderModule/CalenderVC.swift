//
//  CalenderVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/05/26.
//

import UIKit

class CalenderVC: UIViewController {

    @IBOutlet weak var ProfileButton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    // MARK: - Profile Button Action

    @IBAction func ProfileButtonTapped(_ sender: UIButton) {
        navigateToStudentProfileVC()
    }

    // MARK: - TableView Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(nibName: "CalenderVCTableViewCell1", bundle: nil),
            forCellReuseIdentifier: "CalenderVCTableViewCell1"
        )

        tableview.separatorStyle = .none
    }

    // MARK: - Navigation Methods

    private func navigateToStudentProfileVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let profileVC = storyboard.instantiateViewController(
            withIdentifier: "StudentprofileVC"
        ) as? StudentprofileVC {

            navigationController?.pushViewController(profileVC, animated: true)
        }
    }

    private func navigateToFeeEventVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let feeEventVC = storyboard.instantiateViewController(
            withIdentifier: "FeeEventVC"
        ) as? FeeEventVC {

            navigationController?.pushViewController(feeEventVC, animated: true)
        }
    }

    private func navigateToAnnualSportsDayVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let sportsVC = storyboard.instantiateViewController(
            withIdentifier: "AnnualsportsdayVC"
        ) as? AnnualsportsdayVC {

            navigationController?.pushViewController(sportsVC, animated: true)
        }
    }

    private func navigateToExamEventVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let examVC = storyboard.instantiateViewController(
            withIdentifier: "ExameventVC"
        ) as? ExameventVC {

            navigationController?.pushViewController(examVC, animated: true)
        }
    }

    private func navigateToPTMeetingVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let ptVC = storyboard.instantiateViewController(
            withIdentifier: "P_TmeetingVC"
        ) as? P_TmeetingVC {

            navigationController?.pushViewController(ptVC, animated: true)
        }
    }
    
    // MARK: - NEW: Navigate to Multiple Events
    
    private func navigateToMultipleEventsVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let multiVC = storyboard.instantiateViewController(
            withIdentifier: "MultipleeventsVC"
        ) as? MultipleeventsVC {

            navigationController?.pushViewController(multiVC, animated: true)
        }
    }
}

// MARK: - UITableView Delegate & DataSource

extension CalenderVC: UITableViewDelegate, UITableViewDataSource {

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
            withIdentifier: "CalenderVCTableViewCell1",
            for: indexPath
        ) as! CalenderVCTableViewCell1

        cell.selectionStyle = .none

        // 🟠 Orange → Fee Event
        cell.onFeeEventDateTapped = { [weak self] in
            self?.navigateToFeeEventVC()
        }

        // 🟢 Green → Annual Sports Day
        cell.onAnnualSportsDayTapped = { [weak self] in
            self?.navigateToAnnualSportsDayVC()
        }

        // 🔴 Red → Exam Event
        cell.onExamEventTapped = { [weak self] in
            self?.navigateToExamEventVC()
        }

        // 🔵 Blue → P-T Meeting
        cell.onPTMeetingTapped = { [weak self] in
            self?.navigateToPTMeetingVC()
        }
        
        // 🎨 Multi-Color (Day 15) → Multiple Events
        cell.onMultipleEventsTapped = { [weak self] in
            self?.navigateToMultipleEventsVC()
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 1200
    }
}
