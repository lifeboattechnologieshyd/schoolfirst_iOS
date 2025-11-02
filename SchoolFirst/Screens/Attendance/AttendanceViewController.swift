//
//  AttendanceViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 28/10/25.
//

import UIKit
import FSCalendar

 

class AttendanceViewController: UIViewController {

    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        setupTableView()
    }

    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.allowsSelection = false

        tblVw.register(UINib(nibName: "AttendanceCell", bundle: nil), forCellReuseIdentifier: "AttendanceCell")
        tblVw.register(UINib(nibName: "AttendanceTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceTableViewCell")
        tblVw.register(UINib(nibName: "CalendarTableViewCell", bundle: nil), forCellReuseIdentifier: "CalendarTableViewCell")
    }
}

 extension AttendanceViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceCell", for: indexPath) as! AttendanceCell
             cell.delegate = self
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceTableViewCell", for: indexPath) as! AttendanceTableViewCell
            cell.colVw.reloadData()
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableViewCell", for: indexPath) as! CalendarTableViewCell
            return cell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 390
        case 1: return 50
        case 2: return 480
        default: return 60
        }
    }
}
extension AttendanceViewController: AttendanceCellDelegate {
    func didTapRequestLeave() {
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SubmitLeaveViewController") as? SubmitLeaveViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func didTapLeaveHistory() {
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "LeaveHistoryViewController") as? LeaveHistoryViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

