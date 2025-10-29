//
//  AttendanceViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 28/10/25.
//

import UIKit
import FSCalendar

class AttendanceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblVw: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

         tblVw.register(UINib(nibName: "AttendanceCell", bundle: nil), forCellReuseIdentifier: "AttendanceCell")
        tblVw.register(UINib(nibName: "AttendanceTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceTableViewCell")
        tblVw.register(CalendarTableViewCell.self, forCellReuseIdentifier: "CalendarTableViewCell")

        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceCell", for: indexPath)
            cell.textLabel?.text = "Attendance Summary"
            cell.textLabel?.textAlignment = .center
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
        case 0:
            return 380
        case 1:
            return 34
        case 2:
            return 402
        default:
            return 60
        }
    }
}

