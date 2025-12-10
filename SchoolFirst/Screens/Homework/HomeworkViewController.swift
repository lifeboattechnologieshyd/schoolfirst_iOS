//
//  HomeworkViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 22/09/25.
//

import UIKit

class HomeworkViewController: UIViewController {
    @IBOutlet weak var lblTItle: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var colVw: UICollectionView!
    var homework = [Homework]()
    var past_homework = [Homework]()
    var selected_student = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")
        
        colVw.delegate = self
        colVw.dataSource = self
        
        
        getHomework()
        
        self.tblVw.delegate = self
        self.tblVw.dataSource = self

        
        self.lblTItle.text = "HomeWork"
        self.segmentControl.applyCustomStyle()
        segmentControl.selectedSegmentIndex = 1
        topView.addBottomShadow()
        tblVw.register(UINib(nibName: "HWHeaderCell", bundle: nil), forCellReuseIdentifier: "HWHeaderCell")
        tblVw.register(UINib(nibName: "HWSubjectWiseCell", bundle: nil), forCellReuseIdentifier: "HWSubjectWiseCell")
        tblVw.register(UINib(nibName: "HWFooterCell", bundle: nil), forCellReuseIdentifier: "HWFooterCell")
    }
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickChangeSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.getPastHomework()
        }else if sender.selectedSegmentIndex == 1 {
            self.getHomework()
        } else {
            
        }
    }
    func getHomework(){
        homework.removeAll()
        var url = API.HOMEWORK
        url += "?grade_id=\(UserManager.shared.kids[selected_student].gradeID)"
        NetworkManager.shared.request(urlString: url,method: .GET) { (result: Result<APIResponse<[Homework]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.homework = data
                            self.tblVw.reloadData()
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.tblVw.reloadData()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
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
    
    
    func getPastHomework(){
        self.past_homework.removeAll()
        var url = API.HOMEWORK_PAST
        url += "grade_id=\(UserManager.shared.kids[selected_student].gradeID)"
        NetworkManager.shared.request(urlString: url,method: .GET) { (result: Result<APIResponse<[Homework]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.past_homework = data
                            self.tblVw.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.tblVw.reloadData()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
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

extension HomeworkViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if segmentControl.selectedSegmentIndex == 0 {
            return past_homework.count
        }else {
            return homework.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentControl.selectedSegmentIndex == 0 {
            return 2 + past_homework[section].homeworkDetails.count
        }
        return 2 + homework[section].homeworkDetails.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var current_homework : Homework!
        if segmentControl.selectedSegmentIndex == 0 {
            current_homework = past_homework[indexPath.section]
        }else {
            current_homework = homework[indexPath.section]
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HWHeaderCell") as? HWHeaderCell
            cell?.lbldate.text = "Homework Given on \(current_homework.homeworkDate.toddMMMyyyy())"
            cell?.lbldeadline.text = "Submit Before: \(current_homework.deadline.toddMMMyyyy())"
            return cell!
        } else if indexPath.row == current_homework.homeworkDetails.count + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HWFooterCell") as? HWFooterCell
            return cell!
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HWSubjectWiseCell") as? HWSubjectWiseCell
            let details = current_homework.homeworkDetails[indexPath.row-1]
            cell?.lblSubject.text = details.subject
            let cleantext = details.description.replacingOccurrences(of: "\n", with: "\n")
            cell?.lblDescription.text = cleantext
            cell?.lblDescription.font = .lexend(.regular, size: 14)
            cell?.lblSubject.font = .lexend(.semiBold, size: 14)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var current_homework : Homework!
        if segmentControl.selectedSegmentIndex == 0 {
            current_homework = past_homework[indexPath.section]
        }else {
            current_homework = homework[indexPath.section]
        }
        return indexPath.row == 0 ? 66 : indexPath.row == current_homework.homeworkDetails.count + 1 ? 80 : UITableView.automaticDimension
    }
}
extension HomeworkViewController  : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
        if segmentControl.selectedSegmentIndex == 0 {
            self.getPastHomework()
        }else{
            self.getHomework()
        }
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
