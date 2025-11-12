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
        tblVw.delegate = self
        tblVw.dataSource = self
//        HOMEWORK
    }
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getHomework(){
//        var url = API.HOMEWORK
        var url = API.HOMEWORK_PAST
        if let gradeId = UserManager.shared.user?.schools.first?.students.first?.gradeID {
            url += "grade_id=\(gradeId)"
        }
        url += "&start_date=2025-07-01&end_date=2025-10-31"
        NetworkManager.shared.request(urlString: url,method: .GET) { (result: Result<APIResponse<[Homework]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                       
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
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
        return 8
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HWHeaderCell") as? HWHeaderCell
            return cell!
        } else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HWFooterCell") as? HWFooterCell
            return cell!
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HWSubjectWiseCell") as? HWSubjectWiseCell
            return cell!
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 66 : indexPath.row == 7 ? 80 : UITableView.automaticDimension
    }
}
