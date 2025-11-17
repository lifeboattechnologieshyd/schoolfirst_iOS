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
        topVw.addBottomShadow(shadowOpacity: 0.15, shadowRadius: 3, shadowHeight: 4)
        self.setupTableView()
        self.getAttandanceReport()
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
    
    
    func getAttandanceReport() {
        var url = API.ATTENDANCE_STATS + "student_id=\(UserManager.shared.kids.first?.studentID ?? "")"
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[GradeModel]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {

                        }
                    }
                }else{
                    print(info.description)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case .noaccess:
                        self.handleLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
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
        case 0: return 295
        case 1: return 50
        case 2: return 480
        default: return 60
        }
    }
     
     @IBAction func backButtonTapped(_ sender: UIButton) {
         navigationController?.popViewController(animated: true)
     }
 }


