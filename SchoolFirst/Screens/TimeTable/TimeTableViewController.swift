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
    
    var selected_student = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.addBottomShadow()
        getTimeTable()
        tblVw.register(UINib(nibName: "TimeTableSessionCell", bundle: nil), forCellReuseIdentifier: "TimeTableSessionCell")
        tblVw.register(UINib(nibName: "TimeTablePeroidCell", bundle: nil), forCellReuseIdentifier: "TimeTablePeroidCell")
        tblVw.delegate = self
        tblVw.dataSource = self
        
        self.colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")

        colVw.delegate = self
        colVw.dataSource = self

    }
    
    func getTimeTable(){
        guard let grade = UserManager.shared.kids.first?.gradeID else {
            return
        }
        let url = API.ATTENDANCE_TIMETABLE + "date=\(Date().toddMMYYYY())&grade_id=\(grade)"
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
