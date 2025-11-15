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
    var homework : Homework!
    override func viewDidLoad() {
        super.viewDidLoad()
        getHomework()
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
//            self.getPastHomework()
        }else if sender.selectedSegmentIndex == 1 {
            guard let hw = homework else {
                print("api for today homework")
                return
            }
        } else {
            
        }
    }
    func getHomework(){
        var url = API.HOMEWORK
        if let gradeId = UserManager.shared.user?.schools.first?.students.first?.gradeID {
            url += "?grade_id=\(gradeId)"
        }
        NetworkManager.shared.request(urlString: url,method: .GET) { (result: Result<APIResponse<[Homework]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            if data.count > 0 {
                                self.homework = data[0]
                                self.tblVw.delegate = self
                                self.tblVw.dataSource = self
                                self.tblVw.reloadData()
                            }
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
    
    
    func getPastHomework(){
        var url = API.HOMEWORK_PAST
        if let gradeId = UserManager.shared.user?.schools.first?.students.first?.gradeID {
            url += "grade_id=\(gradeId)"
        }
        NetworkManager.shared.request(urlString: url,method: .GET) { (result: Result<APIResponse<[Homework]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            if data.count > 0 {
                                self.homework = data[0]
                                self.tblVw.delegate = self
                                self.tblVw.dataSource = self
                                self.tblVw.reloadData()
                            }
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

extension HomeworkViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + homework.homeworkDetails.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HWHeaderCell") as? HWHeaderCell
            cell?.lbldate.text = "Homework Given on \(homework.homeworkDate.toddMMMyyyy())"
            cell?.lbldeadline.text = "Submit Before: \(homework.deadline.toddMMMyyyy())"
            return cell!
        } else if indexPath.row == homework.homeworkDetails.count + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HWFooterCell") as? HWFooterCell
            return cell!
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HWSubjectWiseCell") as? HWSubjectWiseCell
            let details = homework.homeworkDetails[indexPath.row-1]
            cell?.lblSubject.text = details.subject
            let cleantext = details.description.replacingOccurrences(of: "\n", with: "\n")
            cell?.lblDescription.text = cleantext
            cell?.lblDescription.font = .lexend(.regular, size: 14)
            cell?.lblSubject.font = .lexend(.semiBold, size: 14)
            return cell!
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 66 : indexPath.row == homework.homeworkDetails.count + 1 ? 80 : UITableView.automaticDimension
    }
}
