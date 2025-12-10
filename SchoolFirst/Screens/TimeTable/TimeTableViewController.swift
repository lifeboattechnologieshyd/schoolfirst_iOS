//
//  TimeTableViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 12/11/25.
//

import UIKit

class TimeTableViewController: UIViewController {
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topView: UIView!
    var schedules = [ScheduleItem]()
    var selected_student = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.addBottomShadow()
        self.getTimeTable()
        tblVw.register(UINib(nibName: "TimeTableSessionCell", bundle: nil), forCellReuseIdentifier: "TimeTableSessionCell")
        tblVw.register(UINib(nibName: "TimeTablePeroidCell", bundle: nil), forCellReuseIdentifier: "TimeTablePeroidCell")
        tblVw.register(UINib(nibName: "TimeTableHeaderCell", bundle: nil), forCellReuseIdentifier: "TimeTableHeaderCell")
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.isHidden = true
        self.colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    func getTimeTable(){
        let grade = UserManager.shared.kids[selected_student].gradeID
        let url = API.ATTENDANCE_TIMETABLE + "date=\(Date().toddMMYYYY())&grade_id=\(grade)"
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<TimetableResponse>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.schedules = data.schedule
                        DispatchQueue.main.async {
                            self.tblVw.reloadData()
                            self.tblVw.isHidden = false
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1        // header static cell
        case 1:
            return self.schedules.count
        case 2:
            return 1        // footer static cell
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTableHeaderCell") as! TimeTableHeaderCell
            cell.lblName.text = "Schedule for Today"
            return cell
        case 1:
            let session = self.schedules[indexPath.row]
            if session.session_type == "Period" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTablePeroidCell") as! TimeTablePeroidCell
                
                cell.setupSession(session: session, isLast: indexPath.row == self.schedules.count - 1 )
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTableSessionCell") as! TimeTableSessionCell
                cell.setupSession(session: session)
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTableHeaderCell") as! TimeTableHeaderCell
            cell.lblName.text = "... Done for the Day ..."
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 50        // header static cell
        case 1:
            let session = self.schedules[indexPath.row]
            return session.session_type != "Period" ? 48 : 88
        case 2:
            return 50        // footer static cell
        default:
            return 0
        }
        
    }
}

extension TimeTableViewController  : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserManager.shared.kids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidSelectionCell", for: indexPath) as! KidSelectionCell
        cell.setup(student: UserManager.shared.kids[indexPath.row], isSelected: selected_student ==  indexPath.row)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected_student = indexPath.row
        colVw.reloadData()
        getTimeTable()
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        colVw.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width-10)/2
        return CGSize(width: width, height: 74)
    }
}
