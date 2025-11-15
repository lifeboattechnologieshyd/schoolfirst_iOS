//
//  TimeTableViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 12/11/25.
//

import UIKit

class TimeTableViewController: UIViewController {
    @IBOutlet weak var tblVw: UITableView!
    
    @IBOutlet weak var topView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.addBottomShadow()
        getTimeTable()
        tblVw.register(UINib(nibName: "TimeTableSessionCell", bundle: nil), forCellReuseIdentifier: "TimeTableSessionCell")
        tblVw.register(UINib(nibName: "TimeTablePeroidCell", bundle: nil), forCellReuseIdentifier: "TimeTablePeroidCell")
        tblVw.delegate = self
        tblVw.dataSource = self

    }
    
    func getTimeTable(){
        guard let grade = UserManager.shared.kids.first?.gradeID else {
            return
        }
        var url = API.ATTENDANCE_TIMETABLE + "date=\(Date().toddMMYYYY())&grade_id=\(grade)"
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
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TimeTableViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTablePeroidCell") as! TimeTablePeroidCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTableSessionCell") as! TimeTableSessionCell
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 48 : 88
    }
}
